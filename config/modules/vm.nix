{ config, pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    qemu.swtpm.enable = true;
  };

  programs.virt-manager.enable = true;

  users.users.nate.extraGroups = [ "libvirtd" ];

  # VM packages (stable - system level)
  environment.systemPackages = with pkgs; [
    dnsmasq
    virtio-win
    win-spice
    swtpm
    libtpms
  ];

  networking.firewall.trustedInterfaces = [ "virbr0" ];

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}
