{ config, lib, pkgs, pkgs-unstable, username, homeDirectory, configDirectory, ... }:

let
  # Helper to prepend a directory path to a list of filenames
  fromDir = dir: files: map (f: dir + "/${f}") files;
in

{
  imports =
    [ ./hardware-configuration.nix ]
    ++ fromDir ./system-config [
      "appmods.nix"
      "nixbackup.nix"
      "routes.nix"
    ]
    ++ fromDir ./modules [
      "vm.nix"
      "games.nix"
      "obs.nix"
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "amdgpu" ];
  boot.resumeDevice = "/dev/mapper/cryptswap";
  boot.kernelParams = [
   "video=DP-1:3840x2160@240"
   "video=DP-3:3840x2160@144"
   "video=HDMI-A-1:3840x2160@60"
  ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Detroit";

  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    updateDbusEnvironment = true;
  };

  services.displayManager.sddm = {
    enable = true;
    settings.General.DisplayServer = "wayland";
  };

  services.desktopManager.plasma6.enable = true;
  programs.xwayland.enable = true;

  environment.pathsToLink = [ "/share/applications" ];

  environment.extraInit = ''
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:/run/current-system/sw/share"
  '';

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    vim
    nano
    wget
    git
    fastfetch
    python3
    desktop-file-utils
    vlc
    google-chrome
    psmisc

    # Create the custom desktop entry
  (makeDesktopItem {
      name = "chrome-stable"; # Changed ID to force a fresh index
      desktopName = "Google Chrome"; # Changed Name slightly
      genericName = "Web Browser";
      exec = "google-chrome-stable --force-device-scale-factor=1.25 --enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo --ozone-platform-hint=auto %U";
      icon = "google-chrome";
      categories = [ "Network" "WebBrowser" ];
      terminal = false;
      mimeTypes = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
      extraConfig = {
        StartupWMClass = "google-chrome";
      };
    })
  ];

  programs.firefox.enable = true;
  programs.chromium.enable = true;

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    KWIN_DRM_ALLOW_TEAR = "1";
    NIXOS_OZONE_WL = "1";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  system.activationScripts.refresh-desktop-database = {
    text = ''
      ${pkgs.desktop-file-utils}/bin/update-desktop-database /run/current-system/sw/share/applications || true
    '';
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };

  system.stateVersion = "25.11";
}
