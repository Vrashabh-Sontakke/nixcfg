{
  config,
  pkgs,
  inputs,
  ...
}: {
  users.users.vrash = {
    initialHashedPassword = "$6$GWQ7swYQrv8BJJdN$XSjGRmn9IUUCgiFnwD7wWkffZxFw0ReMeecNowFnx8OYzGziyUYxhogpkF9hA/MaNWIPUN9BR64IBZ3ZqcpMs/";
    isNormalUser = true;
    description = "Vrashabh Sontakke";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      # "adbusers"
      # "libvirtd"
      # "flatpak"
      # "audio"
      # "video"
      # "plugdev"
      # "input"
      # "kvm"
      # "qemu-libvirtd"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClfAqcEwFTgnXgQP4YKfewyc4p74CETkI9KXy6Wliwuu4dPfm+456549yOfA3cejy/M20jiFCnUKMONerAXlRTK38NG54RauvjWfk9EZbSuA9hJ3b8TJdTGfvSOQ1fKlq1NtRPD5POhI36fybSRKmDU7lm4fEQc2B27EqwQXd4FCaXW4FaSi/HlessfhG1W9cvDTJ8tkjbP7RdrDOBQD7PQYPYTgmlmkQjrkRbFCguU7Q7ZFmbqcSKZEeD9wmRjHsNSumRtWQk/xxmwZHwbfiIq3w8PHKouk8AGmCh93cnYRS7TlnYAAUL4kD7DY6Q1aPKs++ImjXTjAAN+DRaG9QD vrashabh@sontakke.in"
    ];
    packages = [inputs.home-manager.packages.${pkgs.system}.default];
  };
  home-manager.users.vrash =
    import ../../../home/vrash/${config.networking.hostName}.nix;
}
