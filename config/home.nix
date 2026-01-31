{ config, pkgs, pkgs-unstable, username, homeDirectory, configDirectory, ... }:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };

  programs.git.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos, btw";
      rebuild = "sudo nixos-rebuild switch --flake path:${configDirectory}#nixos";
    };
    initExtra = ''
      fastfetch
    '';
  };

  # Use pkgs-unstable for all your user packages
  home.packages = with pkgs-unstable; [
    tree
    discord-ptb
    onlyoffice-desktopeditors
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };
}
