{ pkgs, pkgs-unstable, vars, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core utilities
    alacritty
    vim
    nano
    wget
    git
    fastfetch
    python3
    desktop-file-utils
    vlc
    psmisc
    wlr-randr
    p7zip

    # Browsers
    chromium
    google-chrome

    # Unstable packages
    pkgs-unstable.tree
    pkgs-unstable.discord-ptb
    pkgs-unstable.onlyoffice-desktopeditors
    pkgs-unstable.zoom-us
  ];

  programs.chromium.enable = true;

  environment.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake path:${vars.paths.config}#nixos";
  };

  programs.bash = {
    interactiveShellInit = ''
      if [ -z "$FASTFETCH_RAN" ]; then
        export FASTFETCH_RAN=1
        ${pkgs.fastfetch}/bin/fastfetch
      fi
    '';
  };
}
