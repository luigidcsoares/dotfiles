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
    - Neovim overlay that wraps it with the plugins we are going to use by default (we could just use home-manager neovim.plugins' option, but this
      approach allows us to reuse this overlay in other projects as a starting point)
    - NixOS configuration: system-level configs stay under `system/` and user configurations stay under `home/`
    - Minimal dev environment for neovim's lua code (we install dev tools for Nix globally, as we're going to be writing Nix stuff everywhere)
    - Flake templates, which are stored under `templates/` (**TODO**)

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
      overlays.default = import overlays/neovim.nix;

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixos-wsl.nixosModules.wsl
          ./system
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays =
              [ self.overlays.default neorg-overlay.overlays.default ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.luigidcsoares = import ./home;
          }
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.git pkgs.lua-language-server ];
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
{ pkgs, ... }: { 
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

  time.timeZone = "America/Sao_Paulo";

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
      (iosevka-bin.override { variant = "aile"; })
        (iosevka-bin.override { variant = "etoile"; })
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
    enableAutosuggestions = true;
    enableCompletion = true;
    initExtra = ''
      # Sets up Windows Terminal to duplicate tab at the same dir
      # See https://learn.microsoft.com/en-us/windows/terminal/tutorials/new-tab-same-directory
      keep_current_path() { 
        printf "\e]9;9;%s\e\\" "$(wslpath -w "$PWD")" 
      }
      precmd_functions+=(keep_current_path)
    '';
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
  };
}
```

Configure Neovim as the default editor and install plugins (see [Neovim configuration](#neovim-configuration)). This step requires two files:

- `home/neovim.nix`: configures the Neovim package that we're going to use
- `overlays/neovim.nix`: defines an overlay with the Neovim package wrapped with default plugins and some helper function for later use

Let's start with `home/neovim.nix`:

``` nix
# home/neovim.nix
{ pkgs, ... }: {
  home = {
    sessionVariables.EDITOR = "nvim";
    packages = [ pkgs.neovim ];
    file = {
      ".config/nvim/after".source = ./nvim/after;
      ".config/nvim/init.lua".text = ''
        ${builtins.readFile ./nvim/options.lua}
        ${builtins.readFile ./nvim/catppuccin.lua}
        ${builtins.readFile ./nvim/lualine.lua}
        ${builtins.readFile ./nvim/telescope.lua}
        ${builtins.readFile ./nvim/treesitter.lua}
        ${builtins.readFile ./nvim/lspconfig.lua}
        ${builtins.readFile ./nvim/neorg.lua}
        ${builtins.readFile ./nvim/vimtex.lua}
      '';
    };
  };
}
```

Then, we define the Neovim's overlay:

``` nix
# overlays/neovim.nix
final: prev:
let
  neovimDefaultPlugins = let plugins = final.vimPlugins;
  in [
    plugins.catppuccin-nvim
    plugins.nvim-web-devicons
    plugins.lualine-nvim
    plugins.plenary-nvim
    plugins.telescope-nvim
    plugins.telescope-file-browser-nvim
    plugins.nvim-treesitter.withAllGrammars
    plugins.nvim-lspconfig
    plugins.neorg
    plugins.vimtex
  ];

  neovimWithPlugins = extraPlugins:
    let
      normalizePlugin = plugin: { inherit plugin; };
      plugins = neovimDefaultPlugins ++ extraPlugins;
      config = prev.neovimUtils.makeNeovimConfig {
        plugins = map normalizePlugin plugins;
      };
    in prev.wrapNeovimUnstable prev.neovim-unwrapped
    (config // { wrapRc = false; });
in {
  inherit neovimDefaultPlugins neovimWithPlugins;
  neovim = neovimWithPlugins [ ];
}
```

This helps us to replace plugins in project-specific configurations. For example, when working on Neorg locally, we can define a flake that
overrides Neorg's version so that we can use our local version of it:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos.url = "github:luigidcsoares/dotfiles";
  };
  outputs = { self, nixpkgs, nixos, ... }:
    let
      system = "x86_64-linux";
      neorg-overlay = final: prev: {
        vimPlugins = prev.vimPlugins // {
          neorg = prev.vimUtils.buildVimPlugin {
            pname = prev.vimPlugins.neorg.pname;
            version = "local";
            src = self;
          };
        };
      };
      pkgs = nixpkgs.legacyPackages.${system}.appendOverlays [
        neorg-overlay
        nixos.overlays.default
      ];
    in {
      devShells.${system}.default =
        pkgs.mkShell { buildInputs = [ pkgs.neovim ]; };
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
