{ config, pkgs, pkgs-unstable, username, homeDirectory, configDirectory, ... }:

{
  # System-wide applications
  environment.systemPackages = with pkgs; [

    # LabWC Packages
# Core UI
    labwc
    waybar
    rofi
    dunst
    swww
    foot

    # Lock & Idle
    hyprlock
    swayidle

    # Theming & Graphics
    matugen
    imagemagick
    papirus-icon-theme
    adw-gtk3
    qt5.qtwayland
    qt6.qtwayland
    libsForQt5.qt5ct
    kdePackages.qt6ct

    # Utilities
    wl-clipboard
    cliphist
    wl-clip-persist
    playerctl
    pavucontrol
    pamixer
    brightnessctl
    jq
    netcat-gnu
    python311Packages.watchdog
    alsa-utils

    # Screenshots & Recording
    grim
    slurp
    wf-recorder

    # File Manager & Tools
    xfce.thunar
    xfce.xfce4-taskmanager
    swayimg
    mpv
    ffmpeg
    ffmpegthumbnailer
    gammastep

    # System Dialogs
    networkmanagerapplet
    lxqt.lxqt-policykit


    kdePackages.konsole




    # Core utilities
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
    #google-chrome

    # Unstable packages
    pkgs-unstable.tree
    pkgs-unstable.discord-ptb
    pkgs-unstable.onlyoffice-desktopeditors
    pkgs-unstable.zoom-us

    # Custom Desktop Entries
/*    (makeDesktopItem {
      name = "chrome-stable";
      desktopName = "Google Chrome";
      genericName = "Web Browser";
      exec = "google-chrome-stable --force-device-scale-factor=1.25 --enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo --ozone-platform-hint=auto %U";
      icon = "google-chrome";
      categories = [ "Network" "WebBrowser" ];
      terminal = false;
      mimeTypes = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
      extraConfig = {
        StartupWMClass = "google-chrome";
      };
    }) */
  ];

  # Enable Firefox and Chromium programs
  programs.firefox.enable = true;
  programs.chromium.enable = true;

  # Shell aliases
  environment.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake path:${configDirectory}#nixos";
  };

  # Bash configuration for all users
  programs.bash = {
    # interactiveShellInit only runs when you open a terminal
    interactiveShellInit = ''
      # Run fastfetch on shell start
      # We use a check to ensure it doesn't loop if you nest shells
      if [ -z "$FASTFETCH_RAN" ]; then
        export FASTFETCH_RAN=1
        ${pkgs.fastfetch}/bin/fastfetch
      fi
    '';
  };
}
