{ neovimPlugins, ... }: {
  enable = true;
  defaultEditor = true;
  withRuby = true;
  withPython3 = true;
  plugins = neovimPlugins;
  initLua = builtins.readFile ./init.lua;
}
