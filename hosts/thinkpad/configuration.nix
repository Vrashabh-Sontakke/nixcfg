# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

  # Inhibit sleep only while remote SSH sessions are active (includes VS Code Remote SSH).
  systemd.services.prevent-sleep-when-remote = {
    description = "Inhibit sleep during active remote SSH sessions";
    wantedBy = [ "multi-user.target" ];
    after = [ "sshd.service" "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "5s";
      ExecStart = pkgs.writeShellScript "prevent-sleep-when-remote" ''
        #!${pkgs.bash}/bin/bash
        set -euo pipefail

        remote_sessions() {
          ${pkgs.iproute2}/bin/ss -Htn state established '( sport = :22 )' | ${pkgs.coreutils}/bin/wc -l
        }

        while true; do
          if [ "$(remote_sessions)" -gt 0 ]; then
            ${pkgs.systemd}/bin/systemd-inhibit \
              --what=sleep:handle-lid-switch \
              --who="remote-ssh-guard" \
              --why="Active SSH or VS Code Remote SSH session" \
              ${pkgs.bash}/bin/bash -c "
                while [ \"\$(${pkgs.iproute2}/bin/ss -Htn state established '( sport = :22 )' | ${pkgs.coreutils}/bin/wc -l)\" -gt 0 ]; do
                  sleep 15
                done
              "
          else
            sleep 15
          fi
        done
      '';
    };
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Disk Configuration
      ./disko-config.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable uinput for Sunshine virtual input devices
  hardware.uinput.enable = true;

  networking.hostName = "thinkpad"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  
  
  # Docker
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };

  ## Define a user account. Don't forget to set a password with ‘passwd’.
  #users.users.vrash = {
  #  isNormalUser = true;
  #  description = "Vrashabh Sontakke";
  #  extraGroups = [ "networkmanager" "wheel" ];
  #  packages = with pkgs; [
  #  #  thunderbird
  #  ];
  #};
  
  # hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  #direnv
  programs.direnv.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    git
    nil
    nixd
    neovim
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
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    allowSFTP = true;
  };

  # Sunshine game streaming
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

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
  system.stateVersion = "25.05"; # Did you read the comment?

}
