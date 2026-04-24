{ ... }:
{
  boot.kernelModules = [ "ntsync" ];
  imports = [
    ./gaming.nix
    ./obs.nix
  ];
}
