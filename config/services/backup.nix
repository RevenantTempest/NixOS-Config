{ pkgs, vars, ... }:
let
  backupScript = pkgs.writeShellScript "nixos-backup-script" ''
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

    "$GIT" add -A

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

    "$GIT" commit -m "Auto backup: $("$DATE" -Iseconds)"
    "$GIT" push --set-upstream origin "$current_branch"
  '';
in
{
  systemd.services.nixos-config-backup = {
    description = "Auto backup NixOS config to GitHub";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = vars.user.name;
      WorkingDirectory = vars.paths.backup;
      ExecStart = "${backupScript}";
    };
  };

  systemd.timers.nixos-config-backup = {
    description = "Run NixOS config backup periodically";
    wantedBy = [ "timers.target" ];
    partOf = [ "nixos-config-backup.service" ];
    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "1h";
      Persistent = true;
      Unit = "nixos-config-backup.service";
    };
  };
}
