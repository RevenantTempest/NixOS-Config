{ pkgs, pkgs-unstable, vars, ... }:

{
  environment.systemPackages = with pkgs; [
  # Stable Packages
  # Core utilities
    alacritty
    vim
    nano
    wget
    git
    ripgrep
    fastfetch
    python3
    desktop-file-utils
    vlc
    psmisc
    p7zip
    file



  # Unstable Packages
  ] ++ (with pkgs-unstable; [
    tree

  ]);

  programs.chromium.enable = true;

  environment.shellAliases = vars.aliases;

  programs.bash = {
    interactiveShellInit = ''
      if [ -z "$FASTFETCH_RAN" ]; then
        export FASTFETCH_RAN=1
        ${pkgs.fastfetch}/bin/fastfetch
      fi
    '';
  };
}
