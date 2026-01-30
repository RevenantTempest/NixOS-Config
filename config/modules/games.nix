{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.gamemode.enable = true;

  # Gaming utilities (stable - system level)
  environment.systemPackages = with pkgs; [
    mangohud
    xsettingsd
    xorg.xrdb
  ];
}
