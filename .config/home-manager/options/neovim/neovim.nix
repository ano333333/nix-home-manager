{ neovimPlugins, ... }: {
  enable = true;
  defaultEditor = true;
  plugins = neovimPlugins;
  extraLuaConfig = builtins.readFile ./init.lua;
}
