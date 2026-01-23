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
  comment-nvim
  vim-sandwich
  (nvim-treesitter.withPlugins (p: [
    p.lua
    p.go
    p.rust
    p.nix
    p.typescript
    p.javascript
    p.tsx
    p.html
    p.svelte
  ]))
  nvim-treesitter-textobjects
  nvim-treesitter-context
  rainbow-delimiters-nvim
  indent-blankline-nvim
] ++
(with pkgs-yazi.vimPlugins; [
  yazi-nvim
])
