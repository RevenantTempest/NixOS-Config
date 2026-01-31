{ pkgs, pkgs-unstable, ... }:

{
  programs.steam = {
    enable = true;
    # Using unstable for the Steam package itself and its session
    package = pkgs-unstable.steam;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.gamemode.enable = true;

  # Gaming utilities and Heroic (All from Unstable)
  environment.systemPackages = with pkgs-unstable; [
    # The Launcher
    heroic

    # Essential for managing GE-Proton versions in Heroic/Steam
    protonup-qt

    # Performance and Overlay
    mangohud
    gamescope

    # System requirements for many Heroic/Epic games
    winetricks
    wineWowPackages.unstableFull # Using unstable full wine for best compatibility

    # Extra
    xsettingsd
    xorg.xrdb
  ];
}
