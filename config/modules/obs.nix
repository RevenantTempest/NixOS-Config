{ config, pkgs, pkgs-unstable, ... }:

{
  programs.obs-studio.enableVirtualCamera = true;

  # OBS from unstable for latest features
  environment.systemPackages = [
    (pkgs-unstable.wrapOBS {
      plugins = with pkgs-unstable.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-vaapi
        obs-gstreamer
        obs-vkcapture
      ];
    })
  ];
}
