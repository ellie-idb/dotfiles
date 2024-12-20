{
  lib,
  pkgs,
  config,
  user,
  stateVersion,
  ...
}:
{
  config = {
    programs = {
      home-manager.enable = true;
      zsh.enable = true;
      fish = {
        enable = true;
        # TODO: don't do this anymore
        shellInit = builtins.readFile ../fish/init.fish;
      };

      starship = {
        enable = true;
        # TODO: don't do this anymore
        settings = builtins.fromTOML (builtins.readFile ../starship.toml);
      };

      git = {
        enable = true;
        extraConfig = builtins.readFile ../git/gitconfig;
      };

      tmux = {
        enable = true;
        baseIndex = 1;
        newSession = true;
        shell = "${pkgs.fish}/bin/fish";
        historyLimit = 100000;
        plugins = with pkgs; [
          tmuxPlugins.better-mouse-mode
        ];
      };

      neovim = {
        enable = true;
        vimAlias = true;
        vimdiffAlias = true;
        withNodeJs = true;
        plugins = with pkgs.vimPlugins; [
          lazy-nvim
          LazyVim
          vim-terraform
          nerdtree
          tokyonight-nvim
        ];
        extraLuaConfig = ''
          -- Enable Lua syntax highlighting in the initialization files
          vim.api.nvim_set_var("vimsyn_embed", "l")

          -- Some basic defaults that I like
          vim.g.mapleader = " "
          vim.g.maplocalleader = "\\"
          vim.o.softtabstop = 2
          vim.o.tabstop = 2
          vim.o.shiftwidth = 2
          vim.o.expandtab = true
          vim.o.smartindent = true
          vim.o.autoindent = true
          vim.o.encoding = "utf-8"
          vim.wo.cursorline = true

          -- No clue why we have to go through nvim_exec for these
          vim.cmd("syntax on")
          vim.cmd("filetype plugin on")
          require("lazy").setup({
            performance = {
              reset_packpath = false,
              rtp = {
                reset = false,
              },
            },
            spec = {
              { import = "plugins" },
            },
            dev = {
              path = "${pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start",
            },
            install = {
              missing = false,
            },
          })
        '';
      };
    };

    home = {
      username = "${user}";
      homeDirectory = lib.mkDefault "/home/${user}";
      packages = with pkgs; [
        nodejs_18
        go_1_23
        git
        # pkgs.rust-bin.stable.latest.default
        (pkgs.rust-bin.nightly."2024-07-21".default.override {
          extensions = [ "rust-src" ];
        })
        eza
        bat
        gnupg
        sccache
        nil
        nixfmt-rfc-style
        packer
        buf
        graphviz
        bazelisk
        jujutsu
      ];

      stateVersion = "${stateVersion}";
    };

    xdg.configFile."nvim/lua" = {
      recursive = true;
      source = ../nvim/lua;
    };
  };
}
