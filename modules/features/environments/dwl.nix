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

    generatedKeys = pkgs.writeText "dwl-generated-keys.h" ''
      ${tagKeysC}${scratchC}${appsC}
    '';

    mkPatch = name: filename: hash: pkgs.fetchpatch {
      name = "dwl-${name}.patch";
      url = "${baseUrl}/${name}/${filename}";
      inherit hash;
    };

    dwlPatches = [
      (mkPatch "namedscratchpads" "namedscratchpads-0.8.patch" "sha256-o2+iSnlloZY1/GzEH1EIFurmM/j4I9qQ1LrVGIQA7nQ=")
      (mkPatch "dwindle" "dwindle.patch" "sha256-fwzvqhHXEPx44dOeTzluFRsIXiXRGZR9FA0db/dZVfM=")
      #./dwl-singletagset.patch

      # names confirmed against the real repo now — just need exact filenames
      #(mkPatch "client-opacity" "client-opacity.patch" "sha256-5vsBsvdwQ4Vj1aEQgKkhOIv1Huk+taAtXFw6s25Ld6M=")
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
      '';
    });
  in {
    options.device.features.environments.dwl.enable = lib.mkEnableOption "dwl compositor";
    config = lib.mkIf cfg.enable {
      programs.dwl = { enable = true; package = dwlPackage; };
    };
  };
} 
