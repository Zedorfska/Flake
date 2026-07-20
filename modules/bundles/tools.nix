{ self, ... }: {
  flake.nixosModules.tools-bundle = { ... }: {
    imports = [
      self.nixosModules.ffmpeg
      self.nixosModules.hyprshot
      self.nixosModules.portals
      self.nixosModules.mpv
      self.nixosModules.qemu
      self.nixosModules.wshowkeys
      self.nixosModules.protonhax
    ];
  };
}
