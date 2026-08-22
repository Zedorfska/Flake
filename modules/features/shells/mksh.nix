{ self, ... }: {
  flake.nixosModules.mksh = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.shells.mksh;
    name = config.internal.username;

    # environment.shellAliases only gets wired into bash/zsh automatically via
    # their own NixOS modules; mksh has no such module, so translate the same
    # attrset by hand. Any alias added anywhere else in the config (e.g. the
    # tty-clock module) now reaches mksh too, with no extra edits here.
    mkshAliases = lib.concatStringsSep "\n" (
      lib.mapAttrsToList
        (aliasName: aliasValue: "alias ${aliasName}=${lib.escapeShellArg aliasValue}")
        config.environment.shellAliases
    );

    # PS1: bold green user@host:path$, path shrunk to ~ under $HOME, single
    # trailing space, blank line before each prompt. Raw mksh syntax (no bash
    # \u \h \w escapes -- mksh re-evaluates PS1 via live parameter/command
    # substitution on every prompt draw), escaped once for a Nix double-quoted
    # string: \$ \" \\ below.
    mkshPS1 = "export PS1=\$'\\1\\n\\r\\e[1;32m\\1''\${USER}@\$(hostname):\${PWD/#\$HOME/'\"'~'\"'}\$ '\$'\\1\\e[0m\\1'";
  in {
    options.device.features.shells.mksh.enable = lib.mkEnableOption "mksh as the primary user's login shell";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.mksh ];
      environment.shells = [ "${pkgs.mksh}/bin/mksh" ];
      users.users.${name}.shell = pkgs.mksh;

      home-manager.users.${name}.home.file.".mkshrc".text = ''
        ${mkshAliases}
        ${mkshPS1}
      '';
    };
  };
}
