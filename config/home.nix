{ config, pkgs, pkgs-unstable, username, homeDirectory, configDirectory, inputs, lib, dms, dgop, ... }:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };

  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];


  # Fixes "small words" in GTK apps like Faugus Launcher
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 12;
    };
  };


  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    GDK_DPI_SCALE = "1.25";
    NIXOS_OZONE_WL = "1";
  };


  programs.dank-material-shell = {
    enable = true;
    dgop.package = inputs.dgop.packages.${pkgs.system}.default;
  };


  programs.git.enable = true;


}
