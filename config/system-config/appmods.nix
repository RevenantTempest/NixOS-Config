{ config, pkgs, pkgs-unstable, ... }:

let
  # Use unstable Chrome for latest features
  chromeScaled = pkgs.makeDesktopItem {
    name = "google-chrome-scaled";
    desktopName = "Google Chrome (Scaled)";
    genericName = "Web Browser";
    exec = "${pkgs-unstable.google-chrome}/bin/google-chrome-stable --ozone-platform=wayland --enable-features=UseOzonePlatform --force-device-scale-factor=1.25 %U";
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

  # User applications (unstable)
  environment.systemPackages = [
    pkgs-unstable.google-chrome
    chromeScaled
    pkgs.virt-manager  # Keep virt-manager on stable since it's system-level
  ];
}
