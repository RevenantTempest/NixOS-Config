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

  environment.systemPackages = with pkgs; [
    krita
    chromium
    google-chrome


  ] ++ (with pkgs-unstable; [
    discord-ptb
    onlyoffice-desktopeditors
    zoom-us
    prismlauncher
    faugus-launcher
    protonplus
    mangohud
    gamescope
    winetricks
    wineWow64Packages.unstableFull
  ]);
}
