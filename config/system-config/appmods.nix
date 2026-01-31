{ config, pkgs, pkgs-unstable, ... }:

let
  chromeDesktop = pkgs.makeDesktopItem {
    name = "google-chrome";
    desktopName = "Google Chrome";
    genericName = "Web Browser";
    exec = "${pkgs-unstable.google-chrome}/bin/google-chrome-stable --ozone-platform=wayland --enable-features=UseOzonePlatform,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,VaapiVideoDecodeLinuxGL --use-gl=desktop %U";
    icon = "google-chrome";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    mimeTypes = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };
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

  environment.systemPackages = [
    pkgs-unstable.google-chrome
    chromeDesktop
    pkgs.virt-manager
  ];
}
