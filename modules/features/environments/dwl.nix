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

    # -- workspaces: fully driven by whatever wsN/scN keys exist in twm.nix --
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
    mkScratchBind = name: let key = kb.workspaces.${name}; in
      "\t{ ${mkMod [ kb.mod ]}, ${unshiftedXkb key}, togglescratch, SHCMD(\"${d.terminal} --title ${name}\") },\n";
    scratchC = lib.concatMapStrings mkScratchBind scNames;

    mkAppBind = name: cmd: let
      a = kb.apps.${name};
      mods = if a ? mod2 then mkMod [ a.mod1 a.mod2 ] else mkMod [ a.mod1 ];
    in "\t{ ${mods}, XKB_KEY_${lib.toLower a.key}, spawn, SHCMD(\"${cmd}\") },\n";
    appsC = lib.concatStrings [
      (mkAppBind "terminal" d.terminal) (mkAppBind "menu" d.menu)
      (mkAppBind "file_manager" d.file_manager) (mkAppBind "screenshot" d.screenshot)
    ];

    # kept defined but NOT wired into generatedKeys — see DEFERRED note below
    mkDirBinds = mod: fn: lib.concatStrings (lib.mapAttrsToList (dname: _:
      "\t{ ${mkMod [ mod ]}, XKB_KEY_${dirKeyToXkb.${dname}}, /* VERIFY */ ${fn}, {.i = DIR_${lib.toUpper dname}} },\n"
    ) kb.directions);
    focusDirC = mkDirBinds kb.mod "focusdir";
    swapC     = mkDirBinds kb.swapMod "swapdir";
    resizeC   = mkDirBinds kb.resizeMod "resizeclient";

    # opacity keybinds — these are client-opacity-focus's own default binds
    # (from its config.def.h hunk that applies cleanly); wired in here since
    # generatedKeys already owns the "right after keys[] opens" insertion
    # point, same reasoning as everything else in this block.
    opacityKeysC = ''
      	{ ${mkMod [ kb.mod "CONTROL" ]}, XKB_KEY_k, setopacityunfocus, {.f = +0.1f} },
      	{ ${mkMod [ kb.mod "CONTROL" ]}, XKB_KEY_j, setopacityunfocus, {.f = -0.1f} },
      	{ ${mkMod [ kb.mod "CONTROL" "SHIFT" ]}, XKB_KEY_K, setopacityfocus, {.f = +0.1f} },
      	{ ${mkMod [ kb.mod "CONTROL" "SHIFT" ]}, XKB_KEY_J, setopacityfocus, {.f = -0.1f} },
    '';

    generatedKeys = pkgs.writeText "dwl-generated-keys.h" ''
      ${tagKeysC}${scratchC}${appsC}${opacityKeysC}
    '';

    mkPatch = name: filename: hash: pkgs.fetchpatch {
      name = "dwl-${name}.patch";
      url = "${baseUrl}/${name}/${filename}";
      inherit hash;
    };

    # applied manually in postPatch, not via `patches` — 4 of its 15 hunks
    # conflict with namedscratchpads' struct extensions; see chat.
    clientOpacityFocusPatch = mkPatch "client-opacity-focus" "client-opacity-focus.patch" "sha256-+0gaZ5vbZSuoGfxGsMnQcKd8rm44zSvNYI5G5bX864g=";

    dwlPatches = [
      (mkPatch "namedscratchpads" "namedscratchpads-0.8.patch" "sha256-o2+iSnlloZY1/GzEH1EIFurmM/j4I9qQ1LrVGIQA7nQ=")
      (mkPatch "dwindle" "dwindle.patch" "sha256-fwzvqhHXEPx44dOeTzluFRsIXiXRGZR9FA0db/dZVfM=")
      #./dwl-singletagset.patch
      (mkPatch "smartborders" "smartborders.patch" "sha256-5vsBsvdwQ4Vj1aEQgKkhOIv1Huk+taAtXFw6s25Ld6M=")

      # blur: no scenefx patch exists anymore — dropped, see chat

      # deferred — separate patch-conflict issue
      # (mkPatch "focusdir" "focusdir.patch" "sha256-IY8NKUAJoK6lBPCl6CgQ1gFcMkqic9H4RmVs422yp7A=")
      # (mkPatch "swapandfocusdir" "swapandfocusdir.patch" "sha256-Xq3n8dqc3TJ11L10sWZpTBEbPs7g4DHHmtkd7yZbSw0=")
      # (mkPatch "moveresizekb" "moveresizekb.patch" "sha256-EeKap8sg8E7BMAQq8+/Q9QSoCFiU//EfN6rM/VXNjBY=")
    ];

    dwlPackage = pkgs.dwl.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ dwlPatches;
      postPatch = (old.postPatch or "") + ''
        # apply client-opacity-focus permissively — 11 of its 15 hunks
        # (opacity-rendering logic, Rule typedef extension, etc.) apply
        # cleanly against the namedscratchpads-modified tree; the other 4
        # conflict with namedscratchpads' own struct extensions and are
        # hand-patched below instead. Watch for any NEW "FAILED" lines
        # beyond the 4 known ones if dwl's nixpkgs version ever bumps.
        patch -p1 < ${clientOpacityFocusPatch} || true

        cp config.def.h config.h
        sed -i 's/#define MODKEY WLR_MODIFIER_[A-Z]*/#define MODKEY ${modToC.${kb.mod}}/' config.h
        sed -i "s|static const char \*tags\[\] = {.*};|${tagsArrayC}|" config.h
        sed -i '/static const Key keys\[\] = {/r ${generatedKeys}' config.h

        # dwindle+smartborders drift fix: dwindle() predates smartborders'
        # 4-arg resize() signature and never adopted the draw_borders logic
        # tile() already has. Mirror it using dwindle's own client count.
        sed -i 's/unsigned int i, n = 0;/unsigned int i, n = 0, draw_borders = 1;/' dwl.c
        sed -i '/nx = m->w.x;/i\	if (n == smartborders) draw_borders = 0;' dwl.c
        sed -i 's/resize(c, (struct wlr_box){nx, ny, nw, nh}, 0);/resize(c, (struct wlr_box){nx, ny, nw, nh}, 0, draw_borders);/' dwl.c
        sed -i 's/resize(c, (struct wlr_box){nx, ny, w, nh}, 0);/resize(c, (struct wlr_box){nx, ny, w, nh}, 0, draw_borders);/' dwl.c
        sed -i 's/resize(c, (struct wlr_box){nx, ny, nw, h}, 0);/resize(c, (struct wlr_box){nx, ny, nw, h}, 0, draw_borders);/' dwl.c

        # client-opacity-focus gaps (hand-patched — see chat):
        # Client struct — add opacity fields after scratchkey
        sed -i 's/\tchar scratchkey;/\tchar scratchkey;\n\tfloat opacity;\n\tfloat opacity_focus;\n\tfloat opacity_unfocus;/' dwl.c
        # applyrules() — assign them after scratchkey assignment
        sed -i 's/c->scratchkey = r->scratchkey;/c->scratchkey = r->scratchkey;\n\t\t\tc->opacity_focus = r->opacity_focus;\n\t\t\tc->opacity_unfocus = r->opacity_unfocus;/' dwl.c
        # rules[] — insert opacity columns between isfloating and monitor
        sed -i 's|{ "Gimp_EXAMPLE",     NULL,         0,            1,           -1,     0   },|{ "Gimp_EXAMPLE",     NULL,         0,            1,           1.00,  0.20,  -1,     0   },|' config.h
        sed -i 's|{ "firefox_EXAMPLE",  NULL,         1 << 8,       0,           -1,     0   },|{ "firefox_EXAMPLE",  NULL,         1 << 8,       0,           1.00,  1.00,  -1,     0   },|' config.h
        sed -i "s|{ NULL,               \"scratchpad\", 0,            1,           -1,     's' },|{ NULL,               \"scratchpad\", 0,            1,           1.00,  1.00,  -1,     's' },|" config.h
      '';
    });
  in {
    options.device.features.environments.dwl.enable = lib.mkEnableOption "dwl compositor";
    config = lib.mkIf cfg.enable {
      programs.dwl = { enable = true; package = dwlPackage; };
    };
  };
}
