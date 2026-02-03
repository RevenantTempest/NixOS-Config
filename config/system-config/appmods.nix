{ config, pkgs, pkgs-unstable, lib, ... }:

{
  nixpkgs.overlays = [
    # 1. The Chrome Overlay: Bakes flags directly into the package
    (final: prev: {
      google-chrome = prev.google-chrome.override {
        commandLineArgs = [
          "--force-device-scale-factor=1.25"
          "--enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo"
          "--ozone-platform-hint=auto"
        ];
      };
    })
  ];

  environment.systemPackages = [
    pkgs.google-chrome
  ];
}
