# NixOS WSL Configuration


This document covers my NixOS configuration on WSL using nix flake and home manager, as well as my Neovim setup. The entire configuration is
intended to be generated with [Neorg](https://github.com/nvim-neorg/neorg). Unfortunately, tangling and code blocks are still far from good :/

The biggest issues are the following:

1. [Tangling does not work with child directories](https://github.com/nvim-neorg/neorg/issues/793)
2. [Looking glass does play well with LSP](https://github.com/nvim-neorg/neorg/discussions/811)
3. [Looking glass with tagged blocks shifts code to the left, which causes problem](https://github.com/nvim-neorg/neorg/issues/1301)

(1) is easy to circumvent: we can create a Neovim command `NixOS` to postprocess files named `dir1.dir2.move.file.ext` so that they are moved to
`dir1/dir2/file.ext`. This command also tangles the code blocks and exports this document to markdown.

``` lua
-- .nvim.lua
vim.api.nvim_create_user_command("NixOS", function()
  vim.cmd("Neorg tangle current-file")
  vim.cmd("Neorg export to-file README.md")
  for _, pathname in pairs(vim.split(vim.fn.glob("*.move.*"), "\n")) do
    local action_start, action_end = pathname:find("%.move%.")
    local dir = pathname:sub(0, action_start - 1):gsub("%.", "/")
    local file = pathname:sub(action_end + 1)
    vim.loop.fs_mkdir(dir, tonumber("755", 8))
    vim.loop.fs_rename(pathname, dir .. "/" .. file)
  end
end, {})
```

(3) is easy too, but cumbersome: when editing code, move the tangle tag one line up; once done, move it back to the top of the code block again.


## Quick start


- Follow the [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) instructions
- Clone this repository and cd into the directory:

```sh
git clone git@github.com:luigidcsoares/dotfiles <path/to/repository>
cd dotfiles
```

- Scan [flake.nix](#flakenix) for `home-manager.users` and replace with your user name
- Scan [home/default.nix](#homedefaultnix) for `username` and `homeDirectory` and change as appropriate
- Scan [system/default.nix](#systemdefaultnix) for `defaultUser` and change as appropriate ([NixOS-WSL] sets the default username to `nixos`)

- Rebuild your nixos system configuration:

```sh
sudo nixos-rebuild switch --flake <path/to/repository>#nixos
```

- Move `<path/to/repository>` (and anything else you need) to your new user home directory
- Shutdown the WSL instance and open it again, now with your user by default
- Optional) remove the old `/home/nixos/` folder
  

## NixOS configuration



### Flake


Here we define our flake for the NixOS configuration, along with a minimal development environment. 

- Inputs:
    - [nixpkgs](https://github.com/NixOS/nixpkgs/tree/nixos-unstable) is the most recent version of the repository (unstable)
    - [nixos-wsl](https://github.com/nix-community/NixOS-WSL) is the WSL module
    - [home-manager](https://github.com/nix-community/home-manager) is a system for managing user environments
    - [neorg-overlay](https://github.com/nvim-neorg/nixpkgs-neorg-overlay) is used to get the newest features of [Neorg] (unstable)

- Outputs:
    - NixOS configuration: system-level configs stay under `system/` and user configurations stay under `home/`
    - Minimal dev environment for neovim's lua code (we install dev tools for Nix globally, as we're going to be writing Nix stuff everywhere)
    - Flake templates, which are stored under `templates/`

``` nix
# flake.nix
{
  description = "NixOS WSL Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
  };

  outputs =
    { self, nixpkgs, nixos-wsl, home-manager, neorg-overlay, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-wsl.nixosModules.wsl
          ./system
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ neorg-overlay.overlays.default ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.luigidcsoares = import ./home;
          }
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.git pkgs.lua-language-server ];
      };

      templates = {
        latex = {
          path = ./templates/latex;
          description = "Minimal LaTeX template";
          welcomeText = ''
            # Getting started
            - Add your latex packages into `texEnv` in `flake.nix`
            - Run `nix develop` to enter the environment

            # Optional

            You may want to automate the last step with direnv:  

            - Run `echo "use flake" > .envrc`  
            - Run `direnv allow`
          '';
        };

        "python/jupyterlab" = {
          path = ./templates/python/jupyterlab;
          description = "Python template using Poetry2Nix (Jupyter Lab)";
          welcomeText = ''
            # Getting started

            - Update the Python version in both flake.nix and pyproject.toml
            - Add the Python packages you need to pyproject.toml
            - Run `git init`
            - Run `git add flake.nix pyproject.toml poetry.lock`
            - Run `nix develop`

            # Optional

            You may want to automate the last step with direnv:  

            - Run `echo "use flake" > .envrc`  
            - Run `direnv allow`
          '';
        };

        "python/molten" = {
          path = ./templates/python/molten;
          description = "Python template using Poetry2Nix (Neovim with Molten)";
          welcomeText = ''
            # Getting started

            - Update the Python version in both flake.nix and pyproject.toml
            - Add the Python packages you need to pyproject.toml
            - Run `git init`
            - Run `git add flake.nix pyproject.toml poetry.lock`
            - Run `nix develop`

            # Optional

            You may want to automate the last step with direnv:  

            - Run `echo "use flake" > .envrc`  
            - Run `direnv allow`
          '';
        };
      };
    };
}
```


### System configuration


As already mentioned, all system-level configs stay under `system/`, with `system/default.nix` file simply importing the individual config files.
The `default.nix` file also sets up some general options:

- Enable nix flakes
- Set up the correct time zone
- Set the system's state version (**do not alter this!** check the [FAQ](https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion))

``` nix
# system/default.nix
{ pkgs, lib, ... }: { 
  imports = [ 
    ./wsl.nix
    ./shell.nix
    ./docker.nix
    ./ui.nix
    ./dev.nix
  ]; 

  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # time.timeZone = "America/Sao_Paulo";
  time.timeZone = "Australia/Sydney";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11";
}
```

Enable WSL (which uses the [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) module):

``` nix
# system/wsl.nix
{ pkgs, ... }: {
  wsl = {
    enable = true;
    defaultUser = "luigidcsoares";
    startMenuLaunchers = true;
  };
}
```

Define zsh as the default shell:

``` nix
# system/shell.nix
{ pkgs, ... }: {
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];
  users.defaultUserShell = pkgs.zsh;
}
```

Enable docker without root:

``` nix
# system/docker.nix
{ pkgs, ... }: {
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
```

Enable dconf (required for [GTK](#user-configuration)) and configure the default fonts:

``` nix
# system/ui.nix
{ pkgs, ... }: {
  programs.dconf.enable = true;
  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Iosevka Nerd Font" ];
        serif = [ "Iosevka Etoile" ];
        sansSerif = [ "Iosevka Aile" ];
      };
    };

    packages = with pkgs; [
      (iosevka-bin.override { variant = "Aile"; })
      (iosevka-bin.override { variant = "Etoile"; })
      (nerdfonts.override { fonts = [ "Iosevka" ]; })
    ];
  };
}
```

Install global development tools (only for languages we're going to be using constantly):

``` nix
# system/dev.nix
{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.nixd pkgs.nixfmt ];
}
```


### User configuration


Similar to the system case, user-level configurations are also split into multiple files under `home/`. The file `home/default.nix` imports all
modules and defines some general user-level configurations:

- The user's name and home directory
- The correct time zone
- Home manager's state version

``` nix
# home/default.nix
{ ... }: {
  imports = [
    ./ui.nix
    ./tools.nix
    ./shell.nix
    ./neovim.nix
    ./zathura.nix
  ];

  home = {
    username = "luigidcsoares";
    homeDirectory = "/home/luigidcsoares";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
```

Set up theme for gui apps (check [Catppuccin theme for GTK](https://github.com/catppuccin/gtk)):

``` nix
# home/ui.nix
{ pkgs, ... }: {
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Compact-Lavender-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "lavender" ];
        size = "compact";
        tweaks = [ "rimless" ];
        variant = "mocha";
      };
    };
  };
}
```

Set up some tools:

``` nix
# home/tools.nix
{ ... }: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf.enable = true;
  programs.ripgrep.enable = true;

  services.ssh-agent.enable = true;
  programs.git = {
    enable = true;
    userName = "Luigi D. C. Soares";
    userEmail = "dev@luigidcsoares.com";
  };
}
```

Set up zsh with oh-my-zsh and powerlevel10k theme:

``` nix
# home/shell.nix
{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "fzf" ];
    };
    plugins = [
      {
        name = "powerlevel10k";
        file = "powerlevel10k.zsh-theme";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
      }
      {
        name = "powerlevel10k-config";
        file = "p10k.zsh";
        src = ./zsh;
      }
    ];
    shellAliases = {
      nixos-update = "sudo nixos-rebuild switch --flake ~/workspace/dotfiles/#nixos";
      rm = "rm -i"; 
      rmr = "rm -ir";
      rmrf = "rm -irf";
    };
  };
}
```

Configure Neovim as the default editor and install plugins (see [Neovim configuration](#neovim-configuration)). 

``` nix
# home/neovim.nix
{ pkgs, ... }: {
  home.file = {
    ".config/nvim/after".source = ./nvim/after;
    ".config/nvim/init.lua".text = ''
      ${builtins.readFile ./nvim/options.lua}
      ${builtins.readFile ./nvim/catppuccin.lua}
      ${builtins.readFile ./nvim/lualine.lua}
      ${builtins.readFile ./nvim/telescope.lua}
      ${builtins.readFile ./nvim/treesitter.lua}
      ${builtins.readFile ./nvim/lspconfig.lua}
      ${builtins.readFile ./nvim/term.lua}
      ${builtins.readFile ./nvim/molten.lua}
      ${builtins.readFile ./nvim/neorg.lua}
      ${builtins.readFile ./nvim/vimtex.lua}
    '';
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = [
      # Dependency for neorg and telescope
      pkgs.vimPlugins.plenary-nvim

      # Dependencies for neorg
      pkgs.vimPlugins.nvim-nio
      pkgs.vimPlugins.nui-nvim

      pkgs.vimPlugins.catppuccin-nvim
      pkgs.vimPlugins.nvim-web-devicons
      pkgs.vimPlugins.lualine-nvim

      pkgs.vimPlugins.telescope-nvim
      pkgs.vimPlugins.telescope-file-browser-nvim
      pkgs.vimPlugins.toggleterm-nvim

      pkgs.vimPlugins.nvim-lspconfig
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars

      pkgs.vimPlugins.molten-nvim
      pkgs.vimPlugins.neorg
      pkgs.vimPlugins.vimtex
      
      (pkgs.vimUtils.buildVimPlugin {
        name = "wezterm";
        src = pkgs.fetchFromGitHub {
          owner = "willothy";
          repo = "wezterm.nvim";
          rev = "v0.4.0";
          hash = "sha256-HBwmBlvlw1bZNSSOVpy7iuPpGSMpHRra3Ych2PH+aWY=";
        };
      })
    ];

    extraLuaPackages = luaPkgs: [
      # Dependencies for neorg
      luaPkgs.lua-utils-nvim
      luaPkgs.pathlib-nvim
    ];

    extraPython3Packages = pythonPkgs: [
      # Dependencies for molten
      pythonPkgs.jupyter-client
      pythonPkgs.pynvim
    ];
  };
}
```

Finally, we configure Zathura as the PDF reader:

- Customize mappings and con
- Configure the clipboard
- Set up [Catppuccin theme for Zathura](https://github.com/catppuccin/zathura)

``` nix
# home/zathura.nix
{ ... }: {
  programs.zathura = {
    enable = true;
    mappings = {
      "H" = "scroll full-left";
      "J" = "scroll page-bottom";
      "K" = "scroll page-top";
      "L" = "scroll full-right";
    };
    options = {
      selection-clipboard = "clipboard";
      recolor = true;
      recolor-keephue = true;
      # Catppuccin Mocha (see https://github.com/catppuccin/zathura)
      default-fg = "#CDD6F4";
      default-bg = "#1E1E2E";
      completion-bg = "#313244";
      completion-fg = "#CDD6F4";
      completion-highlight-bg = "#575268";
      completion-highlight-fg = "#CDD6F4";
      completion-group-bg = "#313244";
      completion-group-fg = "#89B4FA";
      statusbar-fg = "#CDD6F4";
      statusbar-bg = "#313244";
      notification-bg = "#313244";
      notification-fg = "#CDD6F4";
      notification-error-bg = "#313244";
      notification-error-fg = "#F38BA8";
      notification-warning-bg = "#313244";
      notification-warning-fg = "#FAE3B0";
      inputbar-fg = "#CDD6F4";
      inputbar-bg = "#313244";
      recolor-lightcolor = "#1E1E2E";
      recolor-darkcolor = "#CDD6F4";
      index-fg = "#CDD6F4";
      index-bg = "#1E1E2E";
      index-active-fg = "#CDD6F4";
      index-active-bg = "#313244";
      render-loading-bg = "#1E1E2E";
      render-loading-fg = "#CDD6F4";
      highlight-color = "#575268";
      highlight-fg = "#F5C2E7";
      highlight-active-color = "#F5C2E7";
    };
  };
}
```


## Neovim configuration


This Neovim configuration is written in [Lua](https://www.lua.org/), and it's stored in `home/nvim/`. Let's start with some general options:

``` lua
-- home/nvim/options.lua
-- Enable project local configuration
vim.opt.exrc = true

-- Default indentation options
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Default keymap options
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Default UI options
vim.opt.number = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.textwidth = 73
vim.opt.termguicolors = true
vim.opt.concealcursor = ""
vim.opt.conceallevel = 2
vim.opt.foldlevel = 99

-- Sets up clipboard
vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = {
  name = "WSLClipboard",
  copy = {
    ["+"] = "clip.exe",
    ["*"] = "clip.exe"
  },
  paste = {
    ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
  },
  cache_enabled = 0
}

-- Show replace result in split window
vim.opt.inccommand = "split"
```

Set up a colorscheme:

``` lua
-- home/nvim/catppuccin.lua
require("catppuccin").setup({ flavour = "mocha" })
vim.cmd.colorscheme("catppuccin")
```

Install lualine and configure its theme:

``` lua
-- home/nvim/lualine.lua
require("lualine").setup({ options = { theme = "catppuccin" } })
```

Install telescope plugin and extensions:

``` lua
-- home/nvim/telescope.lua
local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
  extensions = {
    file_browser = {
      hijack_netrw = true,
      hidden = true
    }
  }
})

-- Telescope mappings
vim.keymap.set("n", "<Leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>lg", builtin.live_grep, {})
vim.keymap.set("n", "<Leader>bf", builtin.buffers, {})
vim.keymap.set("n", "<Leader>ht", builtin.help_tags, {})

-- Telescope extensions
telescope.load_extension("file_browser")
vim.keymap.set(
  "n",
  "<Leader>fb", -- As in emacs "dired"
  ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  {}
)
```

Configure treesitter's highlight, indent and selection:

``` lua
-- home/nvim/treesitter.lua
require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    disable = { "latex" }
  },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      node_incremental = "v",
      node_decremental = "z",
      scope_incremental = "<Tab>",
    }
  }
})
```

Set up LSP servers:

``` lua
-- home/nvim/lspconfig.lua
local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup({})
lspconfig.nixd.setup({})
lspconfig.pyright.setup({})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<Leader>fmt", vim.lsp.buf.format, opts)
  end
})
```

Configure toggleterm, so we can easily open and close terminals. 
A simple alternative is to use ctrl-z + fg, but with toggleterm we get terminals as neovim buffers, which is awesome.

``` lua
-- home/nvim/term.lua
require("toggleterm").setup({
  open_mapping = "<Leader>tt",
  insert_mappings = false,
  -- Using <Leader> as <space>, there's gonna be a lag when typing 
  -- space followed by a t. We can disable terminal mappings, but 
  -- then we have to exit to normal mode (ESC) every time we want
  -- to quit the terminal, which is a little incovenient.
  -- terminal_mappings = false,
  start_in_insert = true,
  hide_numbers = true,
  direction = "float"
})

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set("t", "<ESC>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
```

Configure molten with wezterm as the provider, for a jupyter-like experience:

``` lua
-- home/nvim/molten.lua
vim.g.molten_auto_open_output = false
vim.g.molten_image_provider = "wezterm"
```

Install and configure Neorg:

``` lua
-- home/nvim/neorg.lua
require("neorg").setup({
  load = {
    ["core.defaults"] = {},
    ["core.concealer"] = {},
    ["core.export"] = {},
    ["core.keybinds"] = {
      config = {
        hook = function(keybinds)
          keybinds.map_event(
            "norg", "n", keybinds.leader .. "o",
            "core.looking-glass.magnify-code-block"
          )
        end
      }
    }
  }
})
```

Configure LaTeX (vimtex):

- Fix the path to neovim (nix only)
- Define Zathura as the default PDF viewer

``` lua
-- home/nvim/vimtex.lua
vim.g.vimtex_callback_progpath = vim.fn.system("which nvim")
vim.g.vimtex_view_method = "zathura"
```

- Define specific options for Neorg files:

``` lua
-- home/nvim/after/ftplugin/norg.lua
vim.opt.textwidth = 150
```
