#
# HT https://gist.github.com/LnL7/570349866bb69467d0caf5cb175faa74
#
# Initially install with
#  $ nix-env -f '<nixpkgs>' -r -iA userPackages
#
# Afterwards, edit the file and run:
#
#  $ nix-rebuild
#
# See https://gist.github.com/LnL7/570349866bb69467d0caf5cb175faa74#gistcomment-2598159
#
# See also:
#  https://gist.github.com/Widdershin/de023630617c405b033245ced16221f2
#
# Found at
#   https://nixos.wiki/wiki/FAQ#Why_not_use_nix-env_-i_foo.3F
#
self: super:
let
  emptyPkg = {};
  notDarwin = pkg: if self.stdenv.isDarwin then emptyPkg else pkg;
  xpkgs = notDarwin rec {
    # --------------------------------------------------------------------------
    # X.org
    # --------------------------------------------------------------------------

    # Fonts
    inherit (self)
      # Installing FiraCode from nerd-fonts (aka "FuraCode Nera Font") manually
      # for now as there's an issue with the nerdfonts package.
      # https://github.com/ryanoasis/nerd-fonts/releases/tag/v2.0.0
#      nerdfonts
#      fira-code
      source-code-pro
    ;

    inherit (self)
      xsel
    ;
    inherit (self.xorg)
      mkfontdir
      mkfontscale
      xev
      xrandr
    ;

    # Apps
    inherit (self)
      dropbox
      rescuetime

      # Remote desktops. None work or work well.
#      nomachine-client # no nomachine-server :-(.
#      teamviewer
#      tigervnc
#      x11vnc
    ;

    enableSlack = false; # Desktop Slack disabled — use Firefox tab.
    slack-dark = if enableSlack then slack-dark else emptyPkg;

    # https://github.com/KSmanis/kwin-move-window-to-center
    # but let's have xmonad+KDE.

    # KDE
    inherit (self)
      gwenview # Image viewer.
      spectacle # Screenshot taker.
    ;
}; in
with builtins; rec {
  userPackages = super.userPackages or {} // xpkgs // super.recurseIntoAttrs rec {

    #
    # Nix.
    #
    inherit (self)
      nix-prefetch-scripts
      nixfmt
      nixpkgs-fmt
      nox
    ;

    #
    # Something like build-essential.
    #
    gcc = notDarwin self.gcc;
    inherit (self)
      gnumake
      pkgconfig
      python
    ;

    #
    # Terminals.
    #
    inherit (self)
      alacritty
      kitty
    ;

    #
    # Command line utilities.
    #
    bash = self.bashInteractive_5;
    inherit (self)
      # Shells.
      fish
      zsh

      bash-completion
      nix-bash-completions

      # VCS system.
      bazaar
      darcs
      git
      gti # Humourous wrapper for git.
      mercurial

      # Security related.
      gnupg22
      gopass
      pass
      pinentry

      # Commands.
      bat
      bind # for dig. XXX: Any smaller package?
      cabal2nix
      coreutils
      curl
#      dbxcli # Defined in overlay/dbxcli.nix
      direnv
      dos2unix
      fd
      fzf
      gist
      hledger
      htop
      httpie
      hub # Defined in overlay/hub.nix
      jq
      killall
      lastpass-cli
      lsd
      mosh
      mr
      mtr
      neofetch
      pandoc
      peco
      ripgrep
      rlwrap
      shellcheck
      speedtest-cli
      tree
      unzip
      watchman
      wget
      youtube-dl
    ;
    pijul = if false then pijul else {};
    lab = self.gitAndTools.lab;

    # Tmux.
    tmux = self.tmux;
    tmux-fzf-url = self.tmuxPlugins.fzf-tmux-url;

    #
    # Editors
    #
    emacs = self.emacs;
    ispell = self.ispell;
    neovim = self.neovim;

    # Vim with Python3 for vim-orgmode support.
    vim_ =
      if true # Disable vim for now. It doesn't compile on Darwin anyhow.
      then emptyPkg
      else ((self.vim_configurable.override {
      guiSupport = "no";
      darwinSupport = self.stdenv.isDarwin;
      python = self.python3;
    }).overrideAttrs (prevAttrs: {
      name = "my-vim-${prevAttrs.version}";
    }));

    #
    # Programming Languages.
    #
    inherit (self)
      gnum4 # for opam's sake.
      ocaml
      opam
      rustup
    ;

    # Dependently typed PLs.
    agda = notDarwin self.haskellPackages.Agda; # Broken on macOS.
    ats2 = notDarwin self.ats2; # Broken on macOS.
    idris1 = if false then self.idris else null; # Idris 1.3.2 dependencies conflict with bt-app.
    inherit (self)
      coq
    ;

    # Haskell.
    ghc865 = self.haskell.compiler.ghc865;
    inherit (self)
      cabal-install
      stack

      brittany # From haskell overlay.
      ghcid # From haskell overlay.
      hindent # From haskell overlay.
      hlint # From haskell overlay.
      ormolu # From haskell + omolu overlay.
      pointfree # From haskell overlay.
    ;

    #
    # Google Cloud Platform.
    #
    inherit (self)
      google-cloud-sdk

      docker-credential-gcr
      kubectl
    ;

    # Yarn for gitmoji-cli.
    inherit (self)
      nodejs
      yarn
    ;

    #
    # Default packages.
    #
    # WARNING: Do not remove!
    #
    inherit (self)
      nix # Don't enable this on multi-user.
      cacert;

    #
    # nix-rebuild script.
    #
    nix-rebuild = super.writeScriptBin "nix-rebuild" ''
      #!${super.stdenv.shell}
      if ! command -v nix-env &>/dev/null; then
        echo "warning: nix-env was not found in PATH, add nix to userPackages" >&2
        PATH=${self.nix}/bin:$PATH
      fi
      nix-env -f '<nixpkgs>' -r -iA userPackages "$@"

      #
      # Fun and silly commit messages.
      #
      # FIXME: Mutation, hah!
      #
      yarn --silent global add gitmoji-cli
    '';

    #
    # FIXME: Fix below which provides a diff but breaks with use of `super.recurseIntoAttrs` above.
    #        The `super.recurseIntoAttrs` allows you to find userPackages when doing `nix search`.
/*
    nix-rebuild = super.writeScriptBin "nix-rebuild" ''
      #!${super.stdenv.shell}

#      #!${super.stdenv.shell}
#      if ! command -v nix-env &>/dev/null; then
#        echo "warning: nix-env was not found in PATH, add nix to userPackages" >&2
#        PATH=${self.nix}/bin:$PATH
#      fi
#      exec nix-env -f '<nixpkgs>' -r -iA userPackages "$@"

      #!${super.stdenv.shell}
      set -e
      if ! command -v nix-env &>/dev/null; then
        echo "warning: nix-env was not found in PATH, add nix to userPackages" >&2
        PATH=${self.nix}/bin:$PATH
      fi
      IFS=- read -r _ oldGen _ <<<"$(readlink "$(readlink ~/.nix-profile)")"
      oldVersions=$(readlink ~/.nix-profile/package_versions || echo "/dev/null")
      nix-env -f '<nixpkgs>' -r -iA userPackages "$@"
      IFS=- read -r _ newGen _ <<<"$(readlink "$(readlink ~/.nix-profile)")"
      ${self.diffutils}/bin/diff --color -u --label "generation $oldGen" $oldVersions \
        --label "generation $newGen" ~/.nix-profile/package_versions \
        || true
    '';

    packageVersions =
      let
        versions = super.lib.attrsets.mapAttrsToList (_: pkg: pkg.name) self.userPackages;
        versionText = super.lib.strings.concatMapStrings (s: s+"\n") versions;
      in
      super.writeTextDir "package_versions" versionText;
*/
  };
}
