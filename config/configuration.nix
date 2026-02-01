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

  };

  services.displayManager.sddm = {
    enable = true;
    settings.General.DisplayServer = "wayland";
  };

  services.desktopManager.plasma6.enable = true;
  programs.xwayland.enable = true;

  environment.pathsToLink = [ "/share/icons" "/share/applications" ];

  # This ensures KDE/Plasma can see the icons installed by Home Manager
  environment.sessionVariables = {
    XDG_DATA_DIRS = [
      "$HOME/.nix-profile/share"
      "/run/current-system/sw/share"
      "/usr/share"
    ];
  };



  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    KWIN_DRM_ALLOW_TEAR = "1";
    NIXOS_OZONE_WL = "1";

  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    nano
    wget
    git
    fastfetch
    python3
    vlc
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };
  system.stateVersion = "25.11";
}
