{ inputs, nixpkgs, nixpkgs-unstable }:

rec {
  ##########################################################################
  # System
  ##########################################################################
  sys = {
    system = "x86_64-linux";
    stateVersion = "25.11";
    channel = "nixos-25.11";
  };

  ##########################################################################
  # Profile (high-level machine role + hardware vendor)
  ##########################################################################
  profile = {
    systemType = "gaming"; # "gaming" or "server"
    cpuVendor = "amd"; # "amd" or "intel"
  };

  ##########################################################################
  # Features (derived from profile)
  ##########################################################################
  features = {
    enableGaming = profile.systemType == "gaming";
    enableServer = profile.systemType == "server";

    # Preserve existing gaming PC functionality by default
    enableOBS = profile.systemType == "gaming";

    # Virtualization mode is a MANUAL choice and is independent from profile.systemType.
    # Pick one of the three options below based on how you want VM support configured:
    #   "off"    -> No virtualization module is imported.
    #   "gaming" -> Imports programs/gaming/vm.nix (desktop/gaming VM stack).
    #   "server" -> Imports programs/server/vm.nix (server VM stack).
    #
    # You should explicitly choose the value you want, even if systemType changes.
    enableVirtualization = "gaming";

    # Shared services/features
    enableBackup = true;
    enableRoutes = profile.systemType == "gaming";
    enablePrinting = profile.systemType == "gaming";
  };

  ##########################################################################
  # User
  ##########################################################################
  user = {
    name = "nate";
    home = "/home/${user.name}";
  };

  ##########################################################################
  # Network
  # NOTE: Centralized network variables are currently defined in module files.
  ##########################################################################

  ##########################################################################
  # Git / Backup metadata
  ##########################################################################
  git = {
    username = "RevenantTempest";
    email = "nathanielh030@gmail.com";
    repoName = "NixOS-Config";
  };

  ##########################################################################
  # Paths
  ##########################################################################
  paths = {
    config = "${user.home}/nixos-config/config";
    backup = "${user.home}/nixos-config";
  };

  ##########################################################################
  # Display / WM-specific paths and app behavior
  ##########################################################################
  labwcFiles = "${paths.config}/system/labwc/files";

  flags = {
    chrome = [
      "--force-device-scale-factor=1.25"
      "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo"
      "--ozone-platform-hint=wayland"
    ];
  };

  ##########################################################################
  # Shell
  ##########################################################################
  aliases = {
    rebuild = "sudo nixos-rebuild switch --flake path:${paths.config}#nixos";
  };

  ##########################################################################
  # Package sets
  ##########################################################################
  pkgs = import nixpkgs {
    system = sys.system;
    config.allowUnfree = true;
  };

  pkgs-unstable = import nixpkgs-unstable {
    system = sys.system;
    config.allowUnfree = true;
  };
}
