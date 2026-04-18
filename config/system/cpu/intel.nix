{ config, lib, ... }:

{
  boot.kernelModules = [ "kvm-intel" ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.updateMicrocode = lib.mkForce false;

  services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];
}
