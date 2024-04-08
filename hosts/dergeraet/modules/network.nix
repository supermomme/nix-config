{ pkgs, config, ... }: {

  # networking.networkmanager.enable = true;
  # networking.firewall.allowedTCPPorts = [  ];
  # networking.firewall.allowedUDPPorts = [  ];
  networking.firewall.enable = true;

  sops.secrets."wireless.env" = {
    sopsFile = ../../../secrets/dergeraet.yaml;
  };
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    environmentFile = config.sops.secrets."wireless.env".path;
    networks = {
      BlahajAppreciationClub.pskRaw = "@BlahajAppreciationClub@";
      camping_momme.psk = "@camping_momme@";
      eduroam = {
        auth=''
          proto=RSN
          key_mgmt=WPA-EAP
          eap=PEAP
          identity="@EDU_IDENT@"
          password="@EDU_PASS@"
          # password=hash:das_Passwort_als_Hash
          #domain_suffix_match="radius.htw-dresden.de"
          domain_suffix_match="radius.htw-dresden.de"
          anonymous_identity="69873312454253036930@htw-dresden.de"
          phase1="peaplabel=0"
          phase2="auth=MSCHAPV2"
          ca_cert="/etc/ssl/certs/ca-bundle.crt"
        '';
      };
    };
  };

  environment.systemPackages = with pkgs; [
    wpa_supplicant_gui
  ];
}