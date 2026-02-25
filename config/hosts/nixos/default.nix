{ vars, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # System
    ../../system/boot.nix
    ../../system/networking.nix
    ../../system/display.nix
    ../../system/audio.nix
    ../../system/printing.nix
    ../../system/users.nix
    ../../system/appmods.nix

    # Programs
    ../../programs/applications.nix
    ../../programs/gaming.nix
    ../../programs/obs.nix
    ../../programs/vm.nix

    # Services
    ../../services/backup.nix
    ../../services/routes.nix
  ];

  networking.hostName = "nixos";
  time.timeZone = "America/Detroit";
  system.stateVersion = vars.sys.stateVersion;

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };
}
