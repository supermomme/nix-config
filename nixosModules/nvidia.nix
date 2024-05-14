{ pkgs, lib, config, ... }: {

  options = {
    conf.nvidia.enable = lib.mkEnableOption "enable nvidia gpu";
  };

  config = lib.mkIf config.conf.nvidia.enable {

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vulkan-validation-layers
      ];
    };
    services.xserver.videoDrivers = ["nvidia" "modsetting"];
    
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };
}