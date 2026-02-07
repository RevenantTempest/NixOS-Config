{ config, lib, pkgs, pkgs-unstable, username, homeDirectory, configDirectory, ... }:

let
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
      "applications.nix"
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

  nixpkgs.config.allowUnfree = true;

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
    wayland.enable = true;
    settings = {
      General = {
        DisplayServer = "wayland";
        GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell";
      };
    };
  };

  programs.labwc.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.xwayland.enable = true;

  # Force NixOS to link the applications folder into the system profile
  environment.pathsToLink = [ "/share/applications" ];

  # Tell Plasma 6 to explicitly look at the NixOS system profile for desktop files
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

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
      brlaser
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.variables = {
    CHROME_FLAGS = "--force-device-scale-factor=1.25 --enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo";
    CHROMIUM_FLAGS = "--force-device-scale-factor=1.25 --enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo";
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    KWIN_DRM_ALLOW_TEAR = "1";
    NIXOS_OZONE_WL = "1";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${username}/.steam/root/compatibilitytools.d";
  };


  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };

  system.stateVersion = "25.11";
}
