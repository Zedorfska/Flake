{ self, ... }: {
  flake.nixosModules.qemu = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.tools.qemu;
    user = config.internal.username;
  in {
    options.device.features.tools.qemu.enable = lib.mkEnableOption "QEMU VM";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [ 
        virt-manager
        virt-viewer
        virtio-win
        freerdp
        libnotify
        netcat-openbsd
      ];

      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true;
        };
      };

      networking.firewall.allowedTCPPorts = [ 3389 ];

      programs.dconf.enable = true;
      users.extraGroups.libvirtd.members = [ "${user}" ];
      users.extraGroups.kvm.members = [ "${user}" ];
    };
  };
}
