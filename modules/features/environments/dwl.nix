# modules/features/environments/dwl.nix
{ self, inputs, ... }: {
  flake.nixosModules.dwl = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.environments.dwl;
    twm = config.device.twm;
    kb  = twm.keybinds;
    d   = twm.defaults;

    baseUrl = "https://codeberg.org/dwl/dwl-patches/raw/branch/main/patches";

    modToC = {
      SUPER = "WLR_MODIFIER_LOGO"; SHIFT = "WLR_MODIFIER_SHIFT";
      CONTROL = "WLR_MODIFIER_CTRL"; ALT = "WLR_MODIFIER_ALT";
    };
    mkMod = names: lib.concatMapStringsSep "|" (n: modToC.${n}) names;

    digitShiftSymbol = {
      "1" = "exclam"; "2" = "at"; "3" = "numbersign"; "4" = "dollar";
      "5" = "percent"; "6" = "asciicircum"; "7" = "ampersand";
      "8" = "asterisk"; "9" = "parenleft";
    };
    unshiftedXkb = key: if builtins.match "[0-9]" key != null then "XKB_KEY_${key}" else "XKB_KEY_${lib.toLower key}";
    shiftedXkb   = key: if builtins.match "[0-9]" key != null
      then "XKB_KEY_${digitShiftSymbol.${key} or (throw "no shift-symbol for digit '${key}'")}"
      else "XKB_KEY_${lib.toUpper key}";

    dirKeyToXkb = { up = "Up"; down = "Down"; left = "Left"; right = "Right"; };
    # confirmed from config.h itself: stock focusmon/tagmon already use these
    # exact symbolic names, so focusdir uses them too instead of raw ints —
    # one Arg value now works for both.
    dirToC = { left = "WLR_DIRECTION_LEFT"; right = "WLR_DIRECTION_RIGHT"; up = "WLR_DIRECTION_UP"; down = "WLR_DIRECTION_DOWN"; };

    wsNums = lib.sort (a: b: a < b) (map lib.toInt
      (map (n: lib.removePrefix "ws" n)
        (builtins.filter (n: lib.hasPrefix "ws" n) (builtins.attrNames kb.workspaces))));

    tagsArrayC = "static const char *tags[] = { ${lib.concatMapStringsSep ", " (i: "\"${toString i}\"") wsNums} };";

    mkTagBind = i: let key = kb.workspaces."ws${toString i}"; idx = i - 1; in ''
      	{ ${mkMod [ kb.mod ]}, ${unshiftedXkb key}, view, {.ui = 1 << ${toString idx}} },
      	{ ${mkMod [ kb.mod "CONTROL" ]}, ${unshiftedXkb key}, toggleview, {.ui = 1 << ${toString idx}} },
      	{ ${mkMod [ kb.mod "SHIFT" ]}, ${shiftedXkb key}, tag, {.ui = 1 << ${toString idx}} },
      	{ ${mkMod [ kb.mod "CONTROL" "SHIFT" ]}, ${shiftedXkb key}, toggletag, {.ui = 1 << ${toString idx}} },
    '';
    tagKeysC = lib.concatMapStrings mkTagBind wsNums;

    scNames = builtins.filter (n: lib.hasPrefix "sc" n) (builtins.attrNames kb.workspaces);
    # fixed Arg shape: element [0] = scratchkey ("s", matched against the
    # rule's scratchkey char below), elements [1..] = real argv for
    # execvp (spawnscratch starts reading from index 1), NULL-terminated.
    # No SHCMD — that produced {"/bin/sh","-c",...}, whose first char is
    # '/', never 's', which is why togglescratch never matched anything.
    mkScratchBind = name: let key = kb.workspaces.${name}; in
      "\t{ ${mkMod [ kb.mod ]}, ${unshiftedXkb key}, togglescratch, {.v = (const char*[]){ \"s\", \"${d.terminal}\", \"--title\", \"${name}\", NULL } } },\n";
    scratchC = lib.concatMapStrings mkScratchBind scNames;

    scratchName = builtins.head scNames;
    scratchAutostart = [
      [ d.terminal "--title" scratchName "rmpc" ]
      [ d.terminal "--title" scratchName "tty-clock" ]
      [ d.terminal "--hold" "--title" scratchName "fastfetch" ]
    ];
    autostartC = pkgs.writeText "dwl-autostart.h" (lib.concatMapStrings
      (argv: lib.concatMapStrings (a: "\t\"${a}\",\n") argv + "\tNULL,\n")
      scratchAutostart);

    mkAppBind = name: cmd: let
      a = kb.apps.${name};
      mods = if a ? mod2 then mkMod [ a.mod1 a.mod2 ] else mkMod [ a.mod1 ];
    in "\t{ ${mods}, XKB_KEY_${lib.toLower a.key}, spawn, SHCMD(\"${cmd}\") },\n";
    appsC = lib.concatStrings [
      (mkAppBind "terminal" d.terminal) (mkAppBind "menu" d.menu)
      (mkAppBind "file_manager" d.file_manager) (mkAppBind "screenshot" d.screenshot)
    ];

    mkDirBinds = mod: fn: lib.concatStrings (lib.mapAttrsToList (dname: _:
      "\t{ ${mkMod [ mod ]}, XKB_KEY_${dirKeyToXkb.${dname}}, ${fn}, {.i = ${dirToC.${dname}}} },\n"
    ) kb.directions);
    focusDirC = mkDirBinds kb.mod "focusdir";
    swapC     = mkDirBinds kb.swapMod "swapdir";
    resizeC   = mkDirBinds kb.resizeMod "resizeclient";

    opacityKeysC = ''
      	{ ${mkMod [ kb.mod "CONTROL" ]}, XKB_KEY_k, setopacityunfocus, {.f = +0.1f} },
      	{ ${mkMod [ kb.mod "CONTROL" ]}, XKB_KEY_j, setopacityunfocus, {.f = -0.1f} },
      	{ ${mkMod [ kb.mod "CONTROL" "SHIFT" ]}, XKB_KEY_K, setopacityfocus, {.f = +0.1f} },
      	{ ${mkMod [ kb.mod "CONTROL" "SHIFT" ]}, XKB_KEY_J, setopacityfocus, {.f = -0.1f} },
    '';

    killKeyC = "\t{ ${mkMod [ kb.mod ]}, XKB_KEY_q, killclient, {0} },\n";

    generatedKeys = pkgs.writeText "dwl-generated-keys.h" ''
      ${tagKeysC}${scratchC}${appsC}${opacityKeysC}${focusDirC}${killKeyC}
    '';

    singletagsetApplyRulesFix = pkgs.writeText "singletagset-applyrules-fix.h" ''
      	wl_list_for_each(m, &mons, link) {
      		// tag with different monitor selected by rules
      		if (m->tagset[m->seltags] & newtags) {
      			mon = m;
      			break;
      		}
      	}
    '';

    # confirmed against real config.h: stock focusmon takes {.i =
    # WLR_DIRECTION_*}. On no local match, fall through to focusmon(arg)
    # directly instead of reimplementing dirtomon-selection ourselves —
    # reuses its already-correct cursor/focus handling.
    focusdirBodyC = pkgs.writeText "focusdir-body.h" ''
      void focusdir(const Arg *arg)
      {
      	/* Focus the left, right, up, down client relative to the current
      	 * focused client on selmon. Falls through to focusmon (stock dwl
      	 * function) to cross to the adjacent monitor if nothing local matches. */
        Client *c, *sel = focustop(selmon);
      	if (!sel || sel->isfullscreen)
      		return;

        int dist=INT_MAX;
        Client *newsel = NULL;
        int newdist=INT_MAX;
        wl_list_for_each(c, &clients, link) {
          if (!VISIBLEON(c, selmon))
            continue;

          if (arg->i == WLR_DIRECTION_LEFT && sel->geom.x <= c->geom.x)
            continue;
          if (arg->i == WLR_DIRECTION_RIGHT && sel->geom.x >= c->geom.x)
            continue;
          if (arg->i == WLR_DIRECTION_UP && sel->geom.y <= c->geom.y)
            continue;
          if (arg->i == WLR_DIRECTION_DOWN && sel->geom.y >= c->geom.y)
            continue;

          dist=abs(sel->geom.x-c->geom.x)+abs(sel->geom.y-c->geom.y);
          if (dist < newdist){
            newdist = dist;
            newsel=c;
          }
        }
        if (newsel != NULL){
          focusclient(newsel, 1);
          return;
        }

        focusmon(arg);
      }
    '';

    mkPatch = name: filename: hash: pkgs.fetchpatch {
      name = "dwl-${name}.patch";
      url = "${baseUrl}/${name}/${filename}";
      inherit hash;
    };

    clientOpacityFocusPatch = mkPatch "client-opacity-focus" "client-opacity-focus.patch" "sha256-+0gaZ5vbZSuoGfxGsMnQcKd8rm44zSvNYI5G5bX864g=";
    singletagsetPatch = mkPatch "singletagset" "singletagset-v0.7.patch" "sha256-ppyLAdYIHOFCZ53/dBpxR3T3jSx5TfSApo0GI18M0tE=";
    focusdirPatch = mkPatch "focusdir" "focusdir.patch" "sha256-IY8NKUAJoK6lBPCl6CgQ1gFcMkqic9H4RmVs422yp7A=";

    dwlPatches = [
      (mkPatch "namedscratchpads" "namedscratchpads-0.8.patch" "sha256-o2+iSnlloZY1/GzEH1EIFurmM/j4I9qQ1LrVGIQA7nQ=")
      (mkPatch "dwindle" "dwindle.patch" "sha256-fwzvqhHXEPx44dOeTzluFRsIXiXRGZR9FA0db/dZVfM=")
      (mkPatch "smartborders" "smartborders.patch" "sha256-5vsBsvdwQ4Vj1aEQgKkhOIv1Huk+taAtXFw6s25Ld6M=")
      (mkPatch "autostart" "autostart-0.8.patch" "sha256-q5wdOMZKVD1FH+ApUiC8/lmOEKIC9PrgrWYxHmNrZ6A=")
    ];

    dwlPackage = pkgs.dwl.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ dwlPatches;
      postPatch = (old.postPatch or "") + ''
        patch -p1 < ${clientOpacityFocusPatch} || true
        patch -p1 < ${singletagsetPatch} || true
        patch -p1 < ${focusdirPatch} || true

        cp config.def.h config.h
        sed -i 's/#define MODKEY WLR_MODIFIER_[A-Z]*/#define MODKEY ${modToC.${kb.mod}}/' config.h
        sed -i "s|static const char \*tags\[\] = {.*};|${tagsArrayC}|" config.h
        sed -i '/static const Key keys\[\] = {/r ${generatedKeys}' config.h
        sed -i '/static const char \*const autostart\[\] = {/r ${autostartC}' config.h

        sed -i 's/unsigned int i, n = 0;/unsigned int i, n = 0, draw_borders = 1;/' dwl.c
        sed -i '/nx = m->w.x;/i\	if (n == smartborders) draw_borders = 0;' dwl.c
        sed -i 's/resize(c, (struct wlr_box){nx, ny, nw, nh}, 0);/resize(c, (struct wlr_box){nx, ny, nw, nh}, 0, draw_borders);/' dwl.c
        sed -i 's/resize(c, (struct wlr_box){nx, ny, w, nh}, 0);/resize(c, (struct wlr_box){nx, ny, w, nh}, 0, draw_borders);/' dwl.c
        sed -i 's/resize(c, (struct wlr_box){nx, ny, nw, h}, 0);/resize(c, (struct wlr_box){nx, ny, nw, h}, 0, draw_borders);/' dwl.c

        sed -i 's/\tchar scratchkey;/\tchar scratchkey;\n\tfloat opacity;\n\tfloat opacity_focus;\n\tfloat opacity_unfocus;/' dwl.c
        sed -i 's/c->scratchkey = r->scratchkey;/c->scratchkey = r->scratchkey;\n\t\t\tc->opacity_focus = r->opacity_focus;\n\t\t\tc->opacity_unfocus = r->opacity_unfocus;/' dwl.c
        sed -i 's|{ "Gimp_EXAMPLE",     NULL,         0,            1,           -1,     0   },|{ "Gimp_EXAMPLE",     NULL,         0,            1,           1.00,  0.20,  -1,     0   },|' config.h
        sed -i 's|{ "firefox_EXAMPLE",  NULL,         1 << 8,       0,           -1,     0   },|{ "firefox_EXAMPLE",  NULL,         1 << 8,       0,           1.00,  1.00,  -1,     0   },|' config.h
        # title matched to what we actually spawn (was "scratchpad" on
        # both sides in the version that just built — check this line is
        # actually present after you save)
        sed -i "s|{ NULL,               \"scratchpad\", 0,            1,           -1,     's' },|{ NULL,               \"${scratchName}\", 0,            1,           1.00,  1.00,  -1,     's' },|" config.h

        sed -i '/c->isfloating |= client_is_float_type(c);/r ${singletagsetApplyRulesFix}' dwl.c
        sed -i 's/setmon(c, mon, newtags);/setmon(c, mon, newtags);\n\tattachclients(mon);/' dwl.c
        sed -i '/static void applyrules(Client \*c);/a\static void attachclients(Monitor *m);' dwl.c
        sed -i '/static void attachclients(Monitor \*m);/a\static void focusdir(const Arg *arg);' dwl.c
        cat ${focusdirBodyC} >> dwl.c
      '';
    });
  in {
    options.device.features.environments.dwl.enable = lib.mkEnableOption "dwl compositor";
    config = lib.mkIf cfg.enable {
      programs.dwl = { enable = true; package = dwlPackage; };
    };
  };
}
