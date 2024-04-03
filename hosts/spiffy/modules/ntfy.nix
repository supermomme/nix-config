{ ... }: {
  ### ntfy
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.momme.world";
      listen-http = ":4363";
      behind-proxy = true;
      auth-default-access = "write-only";
    };
  };
}