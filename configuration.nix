# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Spotify is unfree (proprietary); needs this to be installable at all.
  nixpkgs.config.allowUnfree = true;

  # Enable flakes + the new nix CLI system-wide so `nixos-rebuild --flake`
  # and the `rebuild` alias work without passing --extra-experimental-features.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # home-manager's NixOS module is supplied as a flake input (see flake.nix),
  # so it no longer needs to be fetched/imported here. Its options
  # (home-manager.*) are still configured further down.
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."duolok" = {
    isNormalUser = true;
    description = "duolok";
    # "transmission" lets duolok read the daemon's download directory.
    # "docker" lets duolok talk to the docker daemon without sudo.
    extraGroups = [ "networkmanager" "wheel" "transmission" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  programs.zsh.enable = true;
  programs.sway.enable = true;
  programs.firefox.enable = true;

  # Docker daemon + CLI. Membership in the "docker" group (above) is what lets
  # duolok run `docker` without sudo; it takes effect on next login/reboot.
  virtualisation.docker.enable = true;

  # Thunar GUI file manager. gvfs = trash + mounting of removable media;
  # tumbler = thumbnail generation; thunar-volman = auto-manage USB/SSD.
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [ thunar-volman thunar-archive-plugin ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # duolok's dotfiles (sway bindings, zsh, waybar, dunst) are managed
  # declaratively via home-manager instead of loose dotfiles.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # If an unmanaged dotfile blocks a rebuild (e.g. an app wrote its own
  # config), back it up as <name>.hmbak instead of failing activation and
  # silently rolling back the whole switch.
  home-manager.backupFileExtension = "hmbak";
  home-manager.users."duolok" = import ./home.nix;

  security.rtkit.enable = true;
  services.pipewire = {
  	enable = true;
	alsa.enable = true;
	pulse.enable = true;
  };

  # Automounting of removable media (USB sticks, external SSDs).
  # udisks2 is the D-Bus mount service; the per-user udiskie daemon
  # (see home.nix) watches for new devices and mounts them.
  services.udisks2.enable = true;

  # Transmission BitTorrent daemon (TUI client `tremc` is in home.nix).
  # Downloads go to /var/lib/transmission/Downloads (symlinked to
  # ~/torrents); group-readable so duolok (in the transmission group) can
  # reach them. RPC is bound to localhost only, so tremc connects with no
  # auth and nothing is exposed to the network.
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    downloadDirPermissions = "770";
    settings = {
      rpc-bind-address = "127.0.0.1";
      rpc-whitelist = "127.0.0.1";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
 	neovim
	foot
	wmenu
	grim slurp
	wl-clipboard
	brightnessctl
	swaylock-effects swayidle swaybg
	git
 #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?




}
