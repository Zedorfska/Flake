{ self, ... }: {
  flake.nixosModules.cli-bundle = { ... }: {
    imports = [
      self.nixosModules.fastfetch
      self.nixosModules.cli-base
      self.nixosModules.rmpc
      self.nixosModules.tty-clock
      self.nixosModules.nvf
      self.nixosModules.yt-dlp
      self.nixosModules.networkmanager
      self.nixosModules.gitui
      self.nixosModules.sshfs
    ];
  };
}
