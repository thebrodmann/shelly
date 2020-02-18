# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
      ./xorg.nix
      ./users.nix
    ];

  nix.useSandbox = true;
  nixpkgs.config.allowUnfree = true;
  virtualisation.docker.enable = true;
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";

  # Use the systemd-boot EFI boot loader.
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs.autoScrub.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # TODO: Perhaps swapfile's are not compatible with ZFS.
#  swapDevices = [ { device = "/var/swapfile"; size = 32768; } ];
#  boot.resumeDevice = "rpool/root/nixos";

  networking.hostName = "verona";
  networking.hostId = "df28ea3c";

  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.addresses = true;

  services.eternal-terminal.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Australia/Brisbane";

  environment.systemPackages = with pkgs; [
    direnv
    git
    poppler # For Emacs pdf-tools — Spacemacs pdf layer.
    vim
    wget

    # Haskell packages.
    # Install stable HIE for GHC 8.6.5.
    (let enable_hie = true;
      all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
    in
    if enable_hie then all-hies.selection { selector = p: { inherit (p)
    ghc865; }; } else cachix)
    haskellPackages.brittany
    cachix
    haskell.compiler.ghc865
    hlint
  ];

  services.emacs.enable = true;

  services.buildkite-agent.enable = true;
  services.buildkite-agent.openssh.privateKeyPath = /tmp/buildkite-agent/buildkite_rsa;
  services.buildkite-agent.openssh.publicKeyPath = /tmp/buildkite-agent/buildkite_rsa.pub;
  services.buildkite-agent.tokenPath = /tmp/buildkite-agent/token;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.gnupg.agent.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    forwardX11 = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  services.keybase.enable = true;

  # Open ports in the firewall.
  #
  # No need to specify 22 here when the openssh service is enabled.
  # https://nixos.org/nixos/manual/index.html#sec-firewall
  #
  networking.firewall.enable = false;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [
    80 433 # HTTP ports
    5900 # VNC
    3389 # RDP
    6568 7070 # AnyDesk
  ];
  networking.firewall.allowedTCPPortRanges = [
    { from = 3000; to = 3010; } # Dev ports.
    { from = 8000; to = 8081; } # Dev ports.
  ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  #
  # Enable sound + bluetooth.
  #
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;

    # NixOS allows either a lightweight build (default) or full build of
    # PulseAudio to be installed.  Only the full build has Bluetooth support, so
    # it must be selected here.
    package = pkgs.pulseaudioFull;
  };
  hardware.bluetooth.enable = true;

  fonts.fonts = with pkgs; [
    noto-fonts-emoji
    font-awesome_5
    source-code-pro
    fira-code
  ];

  security.sudo.wheelNeedsPassword = false;
  nix.trustedUsers = ["@wheel" "steshaw"];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
