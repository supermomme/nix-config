{ pkgs, lib, config, ... }: {

  options = {
    conf.tailscale.enable = lib.mkEnableOption "enable tailscale gpu";
  };

  config = lib.mkIf config.conf.tailscale.enable {

    environment.systemPackages = [ pkgs.tailscale ];
    services.tailscale.enable = true;
  };
}