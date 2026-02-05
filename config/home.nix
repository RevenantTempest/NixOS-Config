{ config, pkgs, pkgs-unstable, username, homeDirectory, configDirectory, ... }:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };

  # Fixes "small words" in GTK apps like Faugus Launcher and Virt-Manager
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 12;
    };
  };

  programs.git.enable = true;

  # Minimal home.nix - most config is now in modules/applications.nix
  home.sessionVariables = {
    GDK_DPI_SCALE = "1.25";
    NIXOS_OZONE_WL = "1";
  };
}
