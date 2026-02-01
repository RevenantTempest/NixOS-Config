{ pkgs, pkgs-unstable, ... }:

{
  programs.steam = {
    enable = true;
    package = pkgs-unstable.steam;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.gamemode.enable = true;

  # Gaming utilities and Faugus (All from Unstable)
  environment.systemPackages = with pkgs-unstable; [
    # The Launcher
    faugus-launcher

    # Managing GE-Proton versions in Faugus/Steam
    protonplus

    # Performance and Overlay
    mangohud
    gamescope

    # Possible System Requirements
    winetricks
    wineWowPackages.unstableFull

    # Extra
    xsettingsd
    xorg.xrdb
  ];
}
