{ lib, config, pkgs, ... }:

let
  skillsHttpsUrl = "https://github.com/ano333333/skills";
  skillsSshUrl = "git@github.com:ano333333/skills.git";
  skillsRef = "main";

  claudeSkillsPath = "${config.home.homeDirectory}/.claude/skills";
  agentsSkillsPath = "${config.home.homeDirectory}/.agents/skills";
in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  # .claude/skills のセットアップ
  if [ ! -d "${claudeSkillsPath}" ]; then
    echo "Setting up Claude skills repository..."
    ${pkgs.git}/bin/git clone -b ${skillsRef} ${skillsHttpsUrl} "${claudeSkillsPath}"
    cd "${claudeSkillsPath}"
    ${pkgs.git}/bin/git remote set-url origin ${skillsSshUrl}
  else
    echo "Updating Claude skills repository..."
    cd "${claudeSkillsPath}"
    ${pkgs.git}/bin/git remote set-url origin ${skillsHttpsUrl}
    ${pkgs.git}/bin/git pull origin ${skillsRef}
    ${pkgs.git}/bin/git remote set-url origin ${skillsSshUrl}
  fi

  # .agents/skills のセットアップ
  if [ ! -d "${agentsSkillsPath}" ]; then
    echo "Setting up agents skills repository..."
    ${pkgs.git}/bin/git clone -b ${skillsRef} ${skillsHttpsUrl} "${agentsSkillsPath}"
    cd "${agentsSkillsPath}"
    ${pkgs.git}/bin/git remote set-url origin ${skillsSshUrl}
  else
    echo "Updating agents skills repository..."
    cd "${agentsSkillsPath}"
    ${pkgs.git}/bin/git remote set-url origin ${skillsHttpsUrl}
    ${pkgs.git}/bin/git pull origin ${skillsRef}
    ${pkgs.git}/bin/git remote set-url origin ${skillsSshUrl}
  fi
''
