{ pkgs, vars, ... }:
{
  systemd.services.nixos-config-backup = {
    description = "Auto backup NixOS config to GitHub";
    serviceConfig = {
      Type = "oneshot";
      User = vars.user.name;
      WorkingDirectory = vars.paths.backup;
      ExecStart = "${pkgs.bash}/bin/bash -c 'PATH=${pkgs.git}/bin:${pkgs.openssh}/bin:$PATH /etc/nixos-backup-script.sh'";
    };
  };

  environment.etc."nixos-backup-script.sh" = {
    mode = "0755";
    text = ''
      #!/usr/bin/env bash
      export GIT_SSH_COMMAND="ssh -i ${vars.user.home}/.ssh/id_ed25519 -o IdentitiesOnly=yes"
      cd "${vars.paths.backup}"
      git add .
      git commit -m "Auto backup: $(date -Iseconds)"
      git push origin main
    '';
  };
}
