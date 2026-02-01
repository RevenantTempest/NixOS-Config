{ config, pkgs, pkgs-unstable, lib, ... }:

let
  chromeFlags = [
    "--ozone-platform=wayland"
    "--force-device-scale-factor=1.25"
    "--enable-features=UseOzonePlatform,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,VaapiVideoDecoder"
    "--use-gl=desktop"
    "--ignore-gpu-blocklist"
    "--enable-gpu-rasterization"
    "--enable-zero-copy"
  ];
in
{
  nixpkgs.overlays = [
    # This modifies the package so the icon and flags are baked in correctly
    (final: prev: {
      google-chrome = prev.google-chrome.override {
        commandLineArgs = lib.concatStringsSep " " chromeFlags;
      };
    })

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
    # 1. Put Chrome back here (System level handles icons better)
    pkgs-unstable.google-chrome
    pkgs.virt-manager
  ];
}
