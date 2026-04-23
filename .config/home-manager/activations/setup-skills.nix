{ lib, config, pkgs, skills, ... }:

let
  skillsHttpsUrl = "https://github.com/ano333333/skills";
  skillsSshUrl = "git@github.com:ano333333/skills.git";
  claudeSkillsPath = "${config.home.homeDirectory}/.claude/skills";
  agentsSkillsPath = "${config.home.homeDirectory}/.agents/skills";
in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  # .claude/skills のセットアップ(未cloneの場合のみ)
  if [ ! -d "${claudeSkillsPath}/.git" ]; then
    echo "Setting up Claude skills repository..."
    ${pkgs.git}/bin/git clone ${skillsHttpsUrl} "${claudeSkillsPath}"
    cd "${claudeSkillsPath}"
    ${pkgs.git}/bin/git remote set-url origin ${skillsSshUrl}
  fi

  # .agents/skills のセットアップ(未cloneの場合のみ)
  if [ ! -d "${agentsSkillsPath}/.git" ]; then
    echo "Setting up agents skills repository..."
    ${pkgs.git}/bin/git clone ${skillsHttpsUrl} "${agentsSkillsPath}"
    cd "${agentsSkillsPath}"
    ${pkgs.git}/bin/git remote set-url origin ${skillsSshUrl}
  fi
''
