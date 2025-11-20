{ config, pkgs, lib, ... }:

{
    imports = [
        ./hardware-configuration.nix
    ];

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.useOSProber = true;

    environment.etc = {
        # machine-id is used by systemd for the journal, if you don't
        #persist this file you won't be able to easily use journalctl to
        # look at journals for previous boots.
        "machine-id".source = "/nix/persist/etc/machine-id";
        
        # For this to work you will need to create the directory yourself:
        # $ mkdir /nix/persist/etc/ssh
        "ssh/ssh_host_rsa_key".source = "/nix/persist/etc/ssh/ssh_host_rsa_key";
        "ssh/ssh_host_rsa_key.pub".source = "/nix/persist/etc/ssh/ssh_host_rsa_key.pub";
        "ssh/ssh_host_ed25519_key".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
        "ssh/ssh_host_ed25519_key.pub".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key.pub";
    };


    networking.hostName = "wuvt2016017";

    networking.networkmanager.enable = true;

    time.timeZone = "America/New_York";

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

    services.xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
        xkb = {
            layout = "us";
            variant = "";
        };
    };

    # This configure the gnome behavior
    programs.dconf = {
        enable = true;
        profiles.user.databases = [{
            lockAll = true;
            settings = {
                "org.gnome.desktop.session".idle-delay = lib.gvariant.mkUint32 0;  # disables idle timeout

                "org.gnome.desktop.screensaver" = {
                    lock-enabled = false;
                    idle-activation-enabled = false;
                };
            };
        }];
    };

    # Disable sleep/suspend/hibernate/lock (not sure if all of this is nescessary/work)
    systemd = {
	    targets = {
            sleep.enable = false;
            hibernate.enable = false;
            hybrid-sleep.enable = false;
	    };
	    sleep.extraConfig = ''
            AllowSuspend=no
            AllowHibernation=no
        '';
        user.services."gnome-screensaver".enable = false;
    }; 

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

    users.users = {
        ladmin = {
            isNormalUser = true;
            hashedPassword = ""; # set this before running
            extraGroups = [ "networkmanager" "wheel" ];
            openssh.authorizedKeys.keys = [
                "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAION5VMQA84lzlDTOoBfkrg7Y/Kv8nTVVMPy3HLdE5d8mAAAABHNzaDo= eri@vtluug.org"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFvQNSUn6XJRXev5WbUu3m4xdyb6rfgA/p0xLIeDh/Eo eri@vtluug.org"
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRBiwY0c3tCjNyr3qmyRUE3KZ7VwmvTjXrJ4hBMwYdi9Cat5BiROjOFpej+uSvxWr5d/aWLhcDnea2sDKX4a4QzVJl2YW5WXXKSPA7Rr5biRopV/oGe4RJVQj53UKVpSUaZdaKkc2R0MelIq3CLIToZybI7m867W6hP5nKhAuiL3JxBVLjLCiN1dPCzqXZjNdPwZYbsQ47FjmXqYsOL9Dd3siUziF02fzqsT8wW2+Fln8+hon0Q/Pi6HKpUSIO93ok+S0+vfwkRbfKLSmKwE0cawzx3mtRjdDAn7Xtp+KKZ75fLW7NBB1kAlnwYgiGnZACpSrHEr9gh2amRJ7TzCeV cardno:000604139688"
                "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICpB45RlFQbjIckUvK5XpGG+9PhdsKmYLZAjTMS1mtVRAAAABHNzaDo= mutantmonkey@rostrata"
                "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAmDZODWVRVEyOMPoig5rbFGGEV9Rnva5jVkitlFqbpmAAAABHNzaDo= mutantmonkey@rostrata"
                "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDXoH7q8CgjDRAuAksemVOF40k+mTkBLiuoRta2aYJwaAAAABHNzaDo= mutantmonkey@rostrata"
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqKllIJvFSGTo/2vp9JCczLaf5IvJVemHbiNv0H8U4ti6JfBOfjyJ3BbSH/zvVAbGFSt5I3u+XAvEnop09fwfqNmRFinYPG0nNcErpi5iyqJWhSA5h+7hBjT3nLnMpiM0kwR9DaTTbqOLfVv6hUUWdykmZE8wNsF6qt6U/6lE0u3jzlGDKnD/H25cy68OMqLa4WIVachNBoswg97E/hBUJINqrZ4pMUGirPGpGsVDtkRE3oPWUx85zEkoGe2rR0IV6zKaR7kxRgi+yNJ9FJWoUduIULI0NXUe5jfT4c+6KaUpvyBdCGpaCCq+Pl3G3SkHKRIYOq3usZ2B+9jxHXC+grM9ykLZe032YnVhNbcaXKHBhyLzT3AUXhoc9g2LMrl3phykYjd48qF4+ciu7c/DSOPcYcEvy6CNnorjJ69fJpwFlCvM5dhmNNlSBIfVIICCm5gDZpiEmjphn96mJ52H+L9AhH8PXcdEe0cxvTFyjLGos2Qoh8iH4PBtdTKiYmR1ARQwetFbfFTPZQwntdN0u1eBNHnWz4KL6bF24/dOTHoCpUwF88M5KfdvzPlOQZRESTgIYgRuRDaBMhlk4jLYahB0OQ9xIl76ouSx0I8F+A66ItqoawhssOY5up3fUjx1ZsTC2jJt2MjHYTRaKSeKyvzfz5CnxagketRNPseSzxQ== /home/eric/.ssh/id_rsa"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBI2qx9/prfNZ+SzatkRncojXfDlUNrp7Iw7myA7qpK2 jared"
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD1naUXM33gsoh+Dxp8TZ4Fi8J8SGUGVaZ3z90/Rxhrja2OvS6hoApkE3O407GJkzETgVw99yIkUh+JN7VHUdzzbI00CXBd33NcIa4hMFXYvSSuZtMrELQVSG/48tR0+I/PASYP+sE2dDqmuicLFk7pmrdROV9XYTnHdWE76n+tkOpQdJxHHkllGjV0+QTFGD0h//fqx9+FEkO2EKOrxiIiA441qMhVUGdKhkeomQtcBnXH9rzYcTenHSf6Af1gibjPosYBP7oMtjU5kde0q6O84CEpktpM04fvAqdr4pWc7patFYk+2dCvc029BlGbsDYnAIxvvu43O2ob6q4R1qsz53lvwXOcNNs2cfKAqj/oG06x0uocw66lgG1G8Ri1HZWxaUTxVeypWaS4omS06xi7AmMfVq0BW0oSLV9GH4X+zTJkSeUFWZAdZEXdQSBNCC2i1CG3lCBKefXJSniupU08ay94x394DF1OA65OkOerDIsqEiprq8GSw4FmhfiN6Oc= eric_kauppi"
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDW4tZf7eJLXAgRnQlAddNURtOU4eXQ5k8Bp4Hw/UUa/QxsYu3efHGnt53mNutc2nScHlwPrEPWdfQCWj2VAxcsoj9sKuadjIvC3Oz3wsVMerkqyfoZNMZxx36Ft2YsOnBeQo8pCbBt54NS3/Bo6ijpts87CdPaERDWinQTQpx8ZK8Qn3FPy8TaUpvSNLZdnMYp1f6PV4nQVmz30/uozWMwEbLRHbdSyq3ewq93GkuyZ9V1/L/ZY4qRy8cKWkVVJW3j1pXVZ4VyNki29gTHoaAcLCuwjZznnesWSBgr45lG7K0c/oVSJJAmYOMYfhKa76Le1vlvQbphBrUrZXO5jEqrQ6G+Tb1GX+fSDVtiXTPJyRMCFp19dSIMWa1qZ80DwUBAmWHsBhwlhByD9kBLwJEMw7YdZq/dZJOEDaXeGOIFiCt8YT6nE6Hln/prIkY+mHBbW5rQVXDZqYUWgWk3LAgKsTmjVldbr4opAPJHpHGxCjWF5ObmIPfv2zZy1VsGWPc= emach@Eric-Laptop"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0XZyXVLH9YMdyW7HUlWvsd+TOob41qtrG4jjlj+qyu prestonpitzer20@vt.edu"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbh3gdpIuefWXTHmNzQCn7gvTbwTUBJ1DGjOtTgrWj8 rsk"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICyTxPV3S7ms0AJ0tduI3aJP3o2TJCnkirWKaj5i1+DW c@pyrope.net"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOen0Hh9uoJlT9ikRmc9dZQfsjMtBc2v7PNIHyf0KSNh mikhail@licas.dev"
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2X3mt/WTcj/I+u7cO2GFsQ1q9XW7KE2trr6V02bL64xeEMLNsI39FgmWQsfv+QK/QB9MJsV/0dYv9YAkseKf1uBs+kLZRqw1dNa0MEEPW+Qbw7C2e0Np4yxLYLDG95y5M/DxQ40T8aiyBXgRmMObmBC+wM+DXLPhDL29x/MlI04DDWjWq3Y35xWFJIDMYH5bBQlEOzWH3HWfNW94Z6grziFS9ZJ6oWYyw9Y8Hz6/eANHSyogU7nFSonirGF1RHpd4ZG1SeG96BuKYbjxnrIJRdePqCCukC5ozL+Xi2CQWg8jqGMqmxhDEl9+pUNbP74uMVK34l+sXaWmlArc/SyQxDUbvDthOahS1lVRQhVDLzdaJ1giO6PW5miP3tCFJHqolKglchIoSpEUj380cq2rlGwyGJGg35gBUN9iUau2fGXrPk0toa3ax24gh04a7Le/GRKmzPTmgU5wCQingot9siKINWzh4UVGgzf/uevbjUr3IC4kOJUSpHox0OePzvwc= jlight@MacBook-Air.local"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID7pEQ6Kv88EKXlS6oZkhJQQQ8ZMF7j/SgVFLCK1sXdh rsk@theseus"
            ];
        };

        studio = {
            isNormalUser = true;
            hashedPassword = ""; # set this before running
            extraGroups = ["networkmanager"];
        };
    };

    programs.firefox = {
        enable = true;
        policies = {
            DisableTelemetry = true;
            ExtensionSettings = {
                # blocks all addons except the ones specified below
                "*".installation_mode = "blocked"; 
          
                # uBlock Origin:
                "uBlock0@raymondhill.net" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                    installation_mode = "force_installed";
                };
		    };
            Preferences = {
                "browser.newtabpage.activity-stream.showSponsored" = false;
                "browser.newtabpage.activity-stream.system.showSponsored" = false;
                "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
                "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
                "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
                "browser.newtabpage.activity-stream.feeds.system.topstories" = false;
            };
            Bookmarks = [
                {
                    Title = "WUVT Last 15";
                    URL = "https://wuvt.vt.edu/last15";
                    Favicon = "https://wuvt.vt.edu/favicon.ico";
                    Placement = "toolbar";
                }
                {
                    Title = "Trackman";
                    URL = "https://trackman-fm.apps.wuvt.vt.edu";
                    Favicon = "https://wuvt.vt.edu/favicon.ico";
                    Placement = "toolbar";
                }
                {
                    Title = "ROLLED";
                    URL = "https://rolled.apps.wuvt.vt.edu";
                    Favicon = "https://wuvt.vt.edu/favicon.ico";
                    Placement = "toolbar";
                }
                {
                    Title = "FM Program Logs";
                    URL = "https://docs.google.com/forms/d/e/1FAIpQLSd_enxUv_9C8YPAjiSAHA5LiszlvdT0-eqNgbeZ3XveTJCiPA/viewform";
                    Favicon = "https://wuvt.vt.edu/favicon.ico";
                    Placement = "toolbar";
                }
            ];
        };
    };
    
    environment.systemPackages = with pkgs; [
        vim
    ];

    services.openssh = {
        enable = true;
        settings = {
            KbdInteractiveAuthentication = false;
            PasswordAuthentication = false;
            PermitRootLogin = "no";   
        };
    };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.05"; # Did you read the comment?
}
