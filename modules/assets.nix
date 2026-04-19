#
# IMPORTANT
#

# This is some bullshit I am doing right here, this file has to stay in ./modules/
# As it points to the wallpaper via path

{ self, ... }: {
  flake = {
    assets = {
      wallpapers = {
        default = ../wallpapers/wallpaper.png;
        scav    = ../wallpapers/scav.mp4;
        scavImage = ../wallpapers/scav.png;
      };
    };
  };
}
