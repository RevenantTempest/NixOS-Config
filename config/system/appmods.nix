{ vars, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      google-chrome = prev.google-chrome.override {
        commandLineArgs = vars.flags.chrome;
      };
      chromium = prev.chromium.override {
        commandLineArgs = vars.flags.chrome;
      };
    })
  ];
}
