{ config, ... }: {

  ### invidious (youtube-client)
  services.invidious.enable = true;
  services.postgresql.enable = true;

}