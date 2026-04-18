{ lib, vars, ... }:

let
  isGaming = vars.profile.systemType == "gaming";
  isServer = vars.profile.systemType == "server";
  isAMD = vars.profile.cpuVendor == "amd";
  virtualizationMode =
    if vars.features.enableVirtualization == false
    then "off"
    else vars.features.enableVirtualization;
in
{
  imports = [
    ./hardware-configuration.nix

    # System
    ../../system/boot.nix
    ../../system/networking.nix
    ../../system/display.nix
    ../../system/audio.nix
    ../../system/users.nix
    ../../system/appmods.nix

    # Programs
    ../../programs/standard/default.nix
  ]
  ++ lib.optionals vars.features.enablePrinting [
    ../../system/printing.nix
  ]
  ++ lib.optionals vars.features.enableBackup [
    ../../services/backup.nix
  ]
  ++ lib.optionals vars.features.enableRoutes [
    ../../services/routes.nix
  ]
  ++ lib.optionals isGaming [
    ../../programs/gaming/default.nix
  ]
  ++ lib.optionals isServer [
    ../../programs/server/default.nix
  ]
  ++ lib.optionals (virtualizationMode == "gaming") [
    ../../programs/gaming/vm.nix
  ]
  ++ lib.optionals (virtualizationMode == "server") [
    ../../programs/server/vm.nix
  ]
  ++ lib.optionals isAMD [
    ../../system/cpu/amd.nix
  ]
  ++ lib.optionals (!isAMD) [
    ../../system/cpu/intel.nix
  ];

  assertions = [
    {
      assertion = builtins.elem vars.profile.systemType [ "gaming" "server" ];
      message = "vars.profile.systemType must be either \"gaming\" or \"server\".";
    }
    {
      assertion = builtins.elem vars.profile.cpuVendor [ "amd" "intel" ];
      message = "vars.profile.cpuVendor must be either \"amd\" or \"intel\".";
    }
    {
      assertion =
        (vars.features.enableVirtualization == false)
        || (builtins.elem vars.features.enableVirtualization [ "off" "gaming" "server" ]);
      message = ''
        vars.features.enableVirtualization must be one of "off", "gaming", or "server".
        Legacy boolean false is also accepted and treated as "off".
      '';
    }
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
