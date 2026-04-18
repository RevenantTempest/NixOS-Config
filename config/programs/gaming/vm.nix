{ pkgs, vars, ... }:

{
  programs.virt-manager.enable = true;
  users.users.${vars.user.name}.extraGroups = [ "libvirtd" ];
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    qemu.swtpm.enable = true;
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    dnsmasq
    virtio-win
    win-spice
    swtpm
    libtpms
  ];

  nixpkgs.overlays = [
    (final: prev: {
      virt-manager = prev.virt-manager.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.makeWrapper ];
        postFixup = (old.postFixup or "") + ''
          wrapProgram "$out/bin/virt-manager" \
            --set GDK_SCALE 2 \
            --set GDK_DPI_SCALE 1 \
            --set XCURSOR_SIZE 48
        '';
      });
    })
  ];
}
