# Modular NixOS Configuration

This repository contains a modular NixOS + Home Manager setup that supports two profile styles:

- **Gaming desktop** (default)
- **Server**

The default values are currently set for your existing AMD gaming PC, so current behavior is preserved.

## Folder structure

```text
config/
├── flake.nix                          # Flake entrypoint and module wiring
├── flake.lock                         # Locked input versions
├── variables.nix                      # Shared variables, profile selection, feature flags
├── home.nix                           # Home Manager user entrypoint
├── hosts/
│   └── nixos/
│       ├── default.nix                # Main host module imports + conditional logic
│       └── hardware-configuration.nix # Generated hardware/disk config for this machine
├── system/
│   ├── boot.nix                       # Bootloader, kernel package, resume, gaming kernel params
│   ├── networking.nix                 # Network config
│   ├── display.nix                    # Desktop/display stack
│   ├── audio.nix                      # Audio config
│   ├── printing.nix                   # Printing support
│   ├── users.nix                      # User account(s)
│   ├── appmods.nix                    # Package overlays (Chrome/Chromium flags)
│   ├── cpu/
│   │   ├── amd.nix                    # AMD microcode + kvm-amd + amdgpu defaults
│   │   └── intel.nix                  # Intel microcode + kvm-intel defaults
│   ├── labwc/                         # LabWC files/assets
│   └── themes/                        # Theme assets
├── programs/
│   ├── standard/
│   │   ├── default.nix                # Always-imported standard program modules
│   │   ├── applications.nix           # Core packages for both systems
│   │   └── programming.nix            # Home Manager dev tooling and VS Code profiles
│   ├── gaming/
│   │   ├── default.nix                # Imported only when profile.systemType = gaming
│   │   ├── gaming.nix                 # Steam, gamemode, launchers, wine, Krita
│   │   ├── obs.nix                    # OBS + plugins
│   │   └── vm.nix                     # Virt-manager/libvirt virtualization stack
│   └── server/
│       ├── default.nix                # Imported only when profile.systemType = server
│       └── vm.nix                     # Server virtualization module (currently same as gaming/vm.nix)
└── services/
    ├── backup.nix                     # GitHub backup service + timer + backup script
    └── routes.nix                     # Additional route/service config
```

## variables.nix reference

All existing variables are preserved, and profile controls were added.

### Existing variables

- `sys.system`: Target architecture (`x86_64-linux`)
- `sys.stateVersion`: NixOS state version
- `sys.channel`: Current channel name
- `user.name`: Primary user
- `user.home`: User home path
- `git.username`: Git commit username for backups
- `git.email`: Git commit email for backups
- `git.repoName`: Repository name metadata
- `paths.config`: Config path used by flake rebuild alias
- `paths.backup`: Repo root that backup script commits/pushes
- `labwcFiles`: Path to LabWC config files
- `aliases.rebuild`: Rebuild command alias
- `flags.chrome`: Chromium/Chrome command-line flags
- `pkgs`: Stable nixpkgs set with unfree enabled
- `pkgs-unstable`: Unstable nixpkgs set with unfree enabled

### New profile variables

- `profile.systemType`: `"gaming"` or `"server"`
- `profile.cpuVendor`: `"amd"` or `"intel"`

### New feature flags

- `features.enableGaming`
- `features.enableServer`
- `features.enableOBS`
- `features.enableVirtualization` (`"off"`, `"gaming"`, or `"server"`; legacy `false` is treated as `"off"`)
- `features.enableBackup`
- `features.enableRoutes`
- `features.enablePrinting`

`features.enableVirtualization` is an independent manual setting and is **not** auto-derived from `profile.systemType`.

- `profile.systemType` controls which app/module profile is loaded (gaming vs server apps).
- `features.enableVirtualization` controls which VM module is loaded (`"off"`, `"gaming"`, or `"server"`).

Default is set to `enableVirtualization = "gaming"` to preserve your current setup, but you should manually choose the value you want.

## How modular import logic works

In `hosts/nixos/default.nix`:

- `programs/standard/default.nix` is **always imported**
- `programs/gaming/default.nix` is imported only when `systemType == "gaming"`
- `programs/server/default.nix` is imported only when `systemType == "server"`
- Virtualization module selection is conditional via `features.enableVirtualization` (independent of `systemType`):
  - `"gaming"` → imports `programs/gaming/vm.nix`
  - `"server"` → imports `programs/server/vm.nix`
  - `"off"` (or legacy `false`) → imports no VM module
- CPU module selection is conditional:
  - `system/cpu/amd.nix` when `cpuVendor == "amd"`
  - `system/cpu/intel.nix` when `cpuVendor == "intel"`

Assertions are included to enforce valid values for `systemType`, `cpuVendor`, and `enableVirtualization`.

## Configuring `systemType` and `enableVirtualization`

Edit `variables.nix` and choose each setting separately:

```nix
profile = {
  systemType = "gaming"; # or "server"
  cpuVendor = "amd";     # or "intel"
};

features = {
  # Independent from systemType:
  # "off"    = no VM module
  # "gaming" = programs/gaming/vm.nix
  # "server" = programs/server/vm.nix
  enableVirtualization = "gaming";
};
```

These two choices are independent, so combinations like these are valid:

- **Gaming PC with server VMs**: `systemType = "gaming"`, `enableVirtualization = "server"`
- **Server with gaming VMs**: `systemType = "server"`, `enableVirtualization = "gaming"`
- **Gaming or server with no VMs**: `enableVirtualization = "off"`

Rebuild after changing values:

```bash
sudo nixos-rebuild switch --flake path:/home/<user>/nixos-config/config#nixos
```

## Add or remove apps by category

### Standard apps (both systems)

- File: `programs/standard/applications.nix`
- Add/remove packages in `environment.systemPackages`

### Gaming/creative apps

- File(s): `programs/gaming/gaming.nix`, `programs/gaming/obs.nix`
- These are active only in gaming profile
- `programs/gaming/vm.nix` is activated when `features.enableVirtualization = "gaming"`

### Server apps

- Add modules under `programs/server/` (example: `docker.nix`, `cockpit.nix`)
- Import them in `programs/server/default.nix`
- They become active only in server profile
- `programs/server/vm.nix` is activated when `features.enableVirtualization = "server"`

## Backup system behavior

File: `services/backup.nix`

Three backup services are defined:

1. `nixos-config-backup-full.service`
   - Scope: full repository backup (entire config repo)
   - Staging behavior: `git add -A`
   - Commit message format: `Full backup: TIMESTAMP`
   - Trigger: **manual only** (no timer)

2. `nixos-config-backup-gaming.service`
   - Scope: gaming profile backup
   - Staged paths:
     - `programs/gaming/`
     - `programs/standard/`
     - `system/`
     - `services/`
     - `variables.nix`
     - `flake.nix`
     - `flake.lock`
     - `hosts/`
     - `README.md`
   - Commit message format: `Gaming profile backup: TIMESTAMP`

3. `nixos-config-backup-server.service`
   - Scope: server profile backup
   - Staged paths:
     - `programs/server/`
     - `programs/standard/`
     - `system/`
     - `services/`
     - `variables.nix`
     - `flake.nix`
     - `flake.lock`
     - `hosts/`
     - `README.md`
   - Commit message format: `Server profile backup: TIMESTAMP`

### Automatic timers (every 12 hours)

Both profile timers use:

- `OnBootSec=10min`
- `OnUnitActiveSec=12h`
- `Persistent=true`

Conditional enablement:

- `nixos-config-backup-gaming.timer` is enabled only when `profile.systemType == "gaming"`
- `nixos-config-backup-server.timer` is enabled only when `profile.systemType == "server"`
- Full backup has no timer and is manual-only.

### Manual trigger commands

```bash
# Full backup (always manual)
sudo systemctl start nixos-config-backup-full.service

# Gaming backup
sudo systemctl start nixos-config-backup-gaming.service

# Server backup
sudo systemctl start nixos-config-backup-server.service
```

### Common backup script flow

For each backup type, the script:

1. Enters `vars.paths.backup`
2. Verifies directory is a git repo
3. Sets git identity from `vars.git.username` and `vars.git.email`
4. Stages files for that backup type
5. Exits cleanly if there is nothing to commit
6. Detects current branch robustly (including fallback from origin HEAD)
7. Commits with timestamped backup-type message
8. Pushes using `git push --set-upstream origin <branch>`

## Deploying on a new machine (step-by-step)

1. **Install NixOS** on target machine.
2. **Clone this repo** to your desired path (for example `~/nixos-config`).
3. **Generate hardware config** on the new machine:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
   ```
4. **Set profile values** in `variables.nix`:
   - `systemType = "gaming"` or `"server"`
   - `cpuVendor = "amd"` or `"intel"`
5. **Set virtualization mode** in `variables.nix` (`features.enableVirtualization`) as a separate choice from `systemType`:
   - `"off"`, `"gaming"`, or `"server"`
6. **(Optional) adjust packages/modules** in `programs/standard`, `programs/gaming`, and `programs/server`.
7. **Ensure git remote + SSH key** are configured for backup pushes.
8. **Apply config**:
   ```bash
   sudo nixos-rebuild switch --flake path:$(pwd)#nixos
   ```
9. **Verify backup services/timers**:
   ```bash
   # Full backup is manual only (service exists, no timer)
   systemctl status nixos-config-backup-full.service

   # Gaming profile systems
   systemctl status nixos-config-backup-gaming.timer

   # Server profile systems
   systemctl status nixos-config-backup-server.timer

   # List all backup timers currently active on this host
   systemctl list-timers | grep nixos-config-backup
   ```

## Notes

- `hosts/nixos/hardware-configuration.nix` remains machine-specific and should be regenerated per machine.
- Server profile module folder is intentionally scaffolded and ready for Docker/Cockpit modules.
