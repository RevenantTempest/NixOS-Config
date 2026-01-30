{ config, pkgs, username, backupDirectory, ... }:

{
  environment.systemPackages = with pkgs; [
    git
  ];

  environment.etc."nixos-backup-script.sh" = {
    mode = "0755";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      # --- CONFIGURATION ---
      REPO_DIR="${backupDirectory}"
      GITHUB_USERNAME="RevenantTempest"
      GITHUB_EMAIL="nathanielh030@gmail.com"
      REPO_NAME="NixOS-Config"
      REMOTE_URL="git@github.com:''${GITHUB_USERNAME}/''${REPO_NAME}.git"
      BRANCH="main"

      # --- GIT IDENTITY (No-write method) ---
      export GIT_AUTHOR_NAME="${username}"
      export GIT_AUTHOR_EMAIL="''${GITHUB_EMAIL}"
      export GIT_COMMITTER_NAME="${username}"
      export GIT_COMMITTER_EMAIL="''${GITHUB_EMAIL}"

      # --- SSH CONFIG ---
      export GIT_SSH_COMMAND="ssh -i /home/${username}/.ssh/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"

      cd "$REPO_DIR"

      # 1. Ensure .gitignore exists
      if [ ! -f ".gitignore" ]; then
        cat << 'EOF' > .gitignore
.env
*.key
*.pem
*.age
secrets.nix
result
EOF
      fi

      # 2. Initialize or update repo
      if [ ! -d ".git" ]; then
        git init
        git checkout -b "$BRANCH"
        git remote add origin "$REMOTE_URL"
      else
        git remote set-url origin "$REMOTE_URL" 2>/dev/null || git remote add origin "$REMOTE_URL"
      fi

      git checkout "$BRANCH" >/dev/null 2>&1 || true

      # 3. Commit and Push
      if [ -n "$(git status --porcelain)" ]; then
        git add .
        git commit -m "Auto backup: $(date -Iseconds)"
        git push -u origin "$BRANCH"
      fi
    '';
  };

  systemd.services.nixos-config-backup = {
    description = "Auto backup NixOS config to GitHub";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      User = username;
      WorkingDirectory = backupDirectory;
      # Inject the PATH to git here
      ExecStart = "${pkgs.bash}/bin/bash -c 'PATH=${pkgs.git}/bin:${pkgs.openssh}/bin:$PATH /etc/nixos-backup-script.sh'";
    };
  };

  systemd.timers.nixos-config-backup = {
    description = "Run NixOS config backup hourly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
