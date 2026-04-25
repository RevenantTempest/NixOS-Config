{ lib, vars, pkgs, ... }:

{
  # `linuxPackages_latest` can jump to very new kernels (e.g. 7.x) that may
  # temporarily miss modules expected by initrd (such as aes_generic).
  # Pin to LTS for stable module availability during early boot.
  boot.kernelPackages = pkgs.linuxPackages_6_19;

  # Ensure encryption-related modules are available in initrd for LUKS unlock.
  boot.initrd.kernelModules = [ "aes" "dm-crypt" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.resumeDevice = "/dev/mapper/cryptswap";

  # Multi-monitor kernel parameters are only needed on the gaming desktop profile.
  boot.kernelParams = lib.mkIf (vars.profile.systemType == "gaming") [
    "video=DP-1:3840x2160@240"
    "video=DP-3:3840x2160@144"
    "video=HDMI-A-1:3840x2160@60"
  ];
}
