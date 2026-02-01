{ config, pkgs, pkgs-unstable, lib, ... }:

{
  # No chrome overlay here anymore

  nixpkgs.overlays = [
    # Keep only what you actually need, e.g. virt-manager wrapper
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
    pkgs.virt-manager
  ];
}
