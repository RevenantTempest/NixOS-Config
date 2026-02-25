{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "amdgpu" ];
  boot.resumeDevice = "/dev/mapper/cryptswap";
  boot.kernelParams = [
   "video=DP-1:3840x2160@240"
   "video=DP-3:3840x2160@144"
   "video=HDMI-A-1:3840x2160@60"
  ];
}
