{ self, ... }: {
  flake.nixosModules.services-bundle = { ... }: {
    imports = [
      self.nixosModules.dunst
      self.nixosModules.gpu-screen-recorder
      self.nixosModules.kanshi #
      #self.nixosModules.mpd
      self.nixosModules.pipewire
      self.nixosModules.swww #
      self.nixosModules.mpvpaper
      self.nixosModules.mprisence
      self.nixosModules.phonto
      self.nixosModules.hyprpolkitagent
    ];
  };
}
