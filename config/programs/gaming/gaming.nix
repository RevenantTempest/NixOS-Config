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

  environment.systemPackages = [
    pkgs.krita
  ] ++ (with pkgs-unstable; [
    prismlauncher
    faugus-launcher
    protonplus
    mangohud
    gamescope
    winetricks
    wineWow64Packages.unstableFull
  ]);
}
