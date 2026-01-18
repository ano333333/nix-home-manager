{
  pkgs,
  pkgs-yazi,
  ...
}: 
with pkgs.vimPlugins; [
  vim-airline
  vim-airline-themes
  vim-devicons
  fzf-lua
  vim-gitgutter
  nerdtree
  nerdtree-git-plugin
  tint-nvim
  nvim-web-devicons
  barbar-nvim
  nvim-autopairs
  mason-nvim
  nvim-lspconfig
  mason-lspconfig-nvim
  quicker-nvim
  typescript-tools-nvim
] ++
(with pkgs-yazi.vimPlugins; [
  yazi-nvim
])
