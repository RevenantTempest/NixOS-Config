{ pkgs, vars, config, lib, ... }:

let
  sharedExtensions = with pkgs.vscode-extensions; [
    ms-vscode-remote.remote-ssh
    tobiasalthoff.atom-material-theme
  ];

  sharedSettings = {
    "workbench.colorTheme" = "Atom Material Theme";
    "window.zoomLevel" = 1;

    # AI Agent
    "chat.disableAIFeatures" = true;
    "github.copilot.chat.welcomeMessage" = false;
    "chat.editor.agent.enabled" = false;
    "chat.welcomeMessage" = false;

    # C/C++ Configuration
    "C_Cpp.default.compilerPath" = "${pkgs.gcc}/bin/gcc";
    "C_Cpp.default.cppStandard" = "c++17";
    "C_Cpp.default.cStandard" = "c11";
    "C_Cpp.default.intelliSenseMode" = "linux-gcc-x64";
    "C_Cpp.updateChannel" = "none"; # Prevents extension from trying to auto-update itself

  };
in
{

  home.file."Documents/Projects" = {
    source = config.lib.file.mkOutOfStoreSymlink "${vars.paths.backup}/Coding";
    force = true;
  };

  home.packages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
    gcc
    gnumake
    cmake
    gdb
    pkg-config
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        extensions = sharedExtensions;
        userSettings = sharedSettings;
      };

      python = {
        extensions = sharedExtensions ++ (with pkgs.vscode-extensions; [
          ms-python.python
          ms-python.vscode-pylance
        ]);
        userSettings = sharedSettings // {
          "python.defaultInterpreterPath" = "${pkgs.python3}/bin/python";
        };
      };

      cpp = {
        extensions = sharedExtensions ++ (with pkgs.vscode-extensions; [
          ms-vscode.cpptools
          ms-vscode.cpptools-extension-pack
        ]);
        userSettings = sharedSettings;
      };
    };
  };
}
