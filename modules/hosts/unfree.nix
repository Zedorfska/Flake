{ self, ... }: {
  flake.nixosModules.unfree = { lib, ... }: {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "aseprite"
      "nvidia-x11"
      "nvidia-settings"
      #"nvidia-persistenced"
      "nvidia-kernel-modules"
      "discord"
      "discord-gamesdk"
      "steam"
      "steam-unwrapped"
      "steamcmd"
      "vscode"
      "vscode-extension-ms-dotnettools-csharp"
      "vital"
      "obsidian"

      "vintagestory"
    ];
    nixpkgs.config.permittedInsecurePackages = [
      "librewolf-151.0.2-1"
      "librewolf-unwrapped-151.0.2-1"
    ];
  };
}
