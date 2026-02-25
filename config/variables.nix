{ inputs, nixpkgs, nixpkgs-unstable }:

let
  system = "x86_64-linux";
in
{
  # Core System Info
  sys = {
    inherit system;
    stateVersion = "25.11";
    channel = "nixos-25.11";
  };

  # User Info
  user = {
    name = "nate";
    home = "/home/${name}";
  };

  # Git & Backup Info
  git = {
    username = "RevenantTempest";
    email = "nathanielh030@gmail.com";
    repoName = "NixOS-Config";
  };

  # Paths
  paths = {
    config = "/home/${name}/nixos-config/config";
    backup = "/home/${name}/nixos-config";
  };

  # Shared Flags
  flags = {
    chrome = [
      "--force-device-scale-factor=1.25"
      "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo"
      "--ozone-platform-hint=auto"
    ];
  };

  # Package Sets
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  pkgs-unstable = import nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
}
