{ pkgs }:
let
  src = pkgs.fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    rev = "ee24ded1770c7a4f7a8cbb8e22aac9812e151feb";
    fetchSubmodules = true;
    hash = "sha256-w1mPi1CxmOsQAo6ruQAb7s+omrdG+Pnn0jZd7mt0yQA=";
  };
in pkgs.buildNpmPackage rec {
  pname = "playwright-cli";
  version = "0.1.9";
  inherit src;
  npmDepsHash = "sha256-garaR0SHwpMBedIWb4CSBP5ZCfmm1eetufFyjQaipEE=";
  npmBuildHook = "";
  makeCacheWritable = true;
  meta = {
    description = "Playwright CLI with SKILLS";
    homepage = "https://github.com/microsoft/playwright-cli";
    license = pkgs.lib.licenses.mit;
  };
}
