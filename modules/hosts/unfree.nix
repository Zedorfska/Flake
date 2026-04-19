{ self, ... }: {
  flake.nixosModules.unfree = { lib, ... }: {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "discord"
      "discord-gamesdk"
      "steam"
      "steam-unwrapped"
      "steamcmd"
      "vscode"
      "vscode-extension-ms-dotnettools-csharp"
      "vital"
      "obsidian"
    ];
  };
}
