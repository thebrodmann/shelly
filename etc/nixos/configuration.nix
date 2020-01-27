# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     git
     vim
     wget
     ksshaskpass
     kdeFrameworks.kwallet

     firefox
     lxqt.pavucontrol-qt
     xorg.xmodmap
  ];

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

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    # Enable touchpad support.
    libinput.enable = true;

    # Enable the KDE Desktop Environment.
#    displayManager.lightdm.enable = true; # default displayManager.
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;

  };
  security.pam.services.sddm.enableKwallet = true;
  security.pam.services.kdewallet.enableKwallet = true;

  fonts.fonts = with pkgs; [
    noto-fonts-emoji
    font-awesome_5
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.steshaw = {
    isNormalUser = true;
    home = "/home/steshaw";
    description = "Steven Shaw";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQM+CdduNpScMe8Uucb5TCVLx3HrXUrTJO8hBkOF8Dy4+IYLFxo6teT8XT4X0+SLJ6gdxPjRPfqmcZwdg051BkaPAh6TkX0zqAeaBFSh3rVmNWV1mxDxYl9X5yWXkaj/kCOpJccz2NrNINYvv4wYHVoVRDg97+RMCdLyzXV2W0sf+J1Mozpj05AAgo6iqUNwo8bHJtekD4UZ6L1Zql3QSwBZvIo2eK9Ir6DPhDMRD0YHLUnFfdLYbGhlqi3qPu8CbEbu+4ptyhlePqvIymdmVwd2VL44SBr5KvlmFuZmhm/LL2b89tb2a2X3RW8do4y1W/wIOwfSeUfXf83zUftTyR steven@steshaw.org" ];
  };
  users.users.debbie = {
    isNormalUser = true;
    home = "/home/debbie";
    description = "Deborah Shaw";
    extraGroups = [];
  };

  security.sudo.wheelNeedsPassword = false;
  nix.trustedUsers = ["@wheel"];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
