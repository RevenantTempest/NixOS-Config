{ pkgs, pkgs-unstable, vars, ... }:
{
  programs.steam = {
    enable = true;
    package = pkgs-unstable.steam;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${vars.user.home}/.steam/root/compatibilitytools.d";
  };

  environment.systemPackages = with pkgs-unstable; [
    faugus-launcher
    protonplus
    mangohud
    gamescope
    winetricks
    wineWowPackages.unstableFull
  ];
}
