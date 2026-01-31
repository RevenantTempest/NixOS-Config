{ config, pkgs, pkgs-unstable, lib, ... }:

let
  # Define all your flags in one place
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

  # User applications (unstable)
  environment.systemPackages = [
    pkgs-unstable.google-chrome
    pkgs.virt-manager  # Keep virt-manager on stable since it's system-level
  ];
}
