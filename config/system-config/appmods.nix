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

    # 2. Your existing virt-manager overlay
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

  environment.systemPackages = [
    pkgs.google-chrome
    pkgs.virt-manager
  ];
}
