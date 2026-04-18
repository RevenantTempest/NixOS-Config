{ pkgs, vars, lib, ... }:
let
  mkBackupScript = {
    scriptName,
    commitPrefix,
    stageCommand,
  }:
    pkgs.writeShellScript scriptName ''
      set -euo pipefail

      GIT="${pkgs.git}/bin/git"
      DATE="${pkgs.coreutils}/bin/date"
      SSH="${pkgs.openssh}/bin/ssh"

      export GIT_SSH_COMMAND="$SSH -i ${vars.user.home}/.ssh/id_ed25519 -o IdentitiesOnly=yes -o BatchMode=yes"

      cd "${vars.paths.backup}"

      if ! "$GIT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "${vars.paths.backup} is not a git repository; skipping backup."
        exit 0
      fi

      "$GIT" config user.name "${vars.git.username}"
      "$GIT" config user.email "${vars.git.email}"

      ${stageCommand}

      if "$GIT" diff --cached --quiet; then
        echo "No changes to commit."
        exit 0
      fi

      current_branch="$("$GIT" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
      if [ -z "$current_branch" ]; then
        current_branch="$("$GIT" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
      fi
      if [ -z "$current_branch" ] || [ "$current_branch" = "HEAD" ]; then
        current_branch="$("$GIT" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true)"
        current_branch="''${current_branch#origin/}"
      fi
      if [ -z "$current_branch" ]; then
        current_branch="main"
      fi

      "$GIT" commit -m "${commitPrefix}: $("$DATE" -Iseconds)"
      "$GIT" push --set-upstream origin "$current_branch"
    '';

  backupScriptFull = mkBackupScript {
    scriptName = "nixos-backup-script-full";
    commitPrefix = "Full backup";
    stageCommand = ''
      "$GIT" add -A
    '';
  };

  backupScriptGaming = mkBackupScript {
    scriptName = "nixos-backup-script-gaming";
    commitPrefix = "Gaming profile backup";
    stageCommand = ''
      # Stage everything except server-only paths.
      # This avoids hard failures when specific directories are missing or empty.
      "$GIT" add -A -- . \
        ":(exclude)programs/server/" \
        ":(exclude)programs/server/**" || true
    '';
  };

  backupScriptServer = mkBackupScript {
    scriptName = "nixos-backup-script-server";
    commitPrefix = "Server profile backup";
    stageCommand = ''
      # Stage everything except gaming-only paths.
      # This avoids hard failures when specific directories are missing or empty.
      "$GIT" add -A -- . \
        ":(exclude)programs/gaming/" \
        ":(exclude)programs/gaming/**" || true
    '';
  };
in
{
  systemd.services = {
    nixos-config-backup-full = {
      description = "Manual full backup of NixOS config to GitHub";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = vars.user.name;
        WorkingDirectory = vars.paths.backup;
        ExecStart = "${backupScriptFull}";
      };
    };

    nixos-config-backup-gaming = {
      description = "Gaming profile backup of NixOS config to GitHub";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = vars.user.name;
        WorkingDirectory = vars.paths.backup;
        ExecStart = "${backupScriptGaming}";
      };
    };

    nixos-config-backup-server = {
      description = "Server profile backup of NixOS config to GitHub";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = vars.user.name;
        WorkingDirectory = vars.paths.backup;
        ExecStart = "${backupScriptServer}";
      };
    };
  };

  systemd.timers =
    (lib.optionalAttrs (vars.profile.systemType == "gaming") {
      nixos-config-backup-gaming = {
        description = "Run gaming profile backup every 12 hours";
        wantedBy = [ "timers.target" ];
        partOf = [ "nixos-config-backup-gaming.service" ];
        timerConfig = {
          OnBootSec = "10min";
          OnUnitActiveSec = "12h";
          Persistent = true;
          Unit = "nixos-config-backup-gaming.service";
        };
      };
    })
    // (lib.optionalAttrs (vars.profile.systemType == "server") {
      nixos-config-backup-server = {
        description = "Run server profile backup every 12 hours";
        wantedBy = [ "timers.target" ];
        partOf = [ "nixos-config-backup-server.service" ];
        timerConfig = {
          OnBootSec = "10min";
          OnUnitActiveSec = "12h";
          Persistent = true;
          Unit = "nixos-config-backup-server.service";
        };
      };
    });
}
