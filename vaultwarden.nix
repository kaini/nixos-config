{ ... }:

{
  services.vaultwarden = {
    enable = true;

    config = {
      DOMAIN = "https://vaultwarden.pushrax.com";

      # Vaultwarden is only reachable through the local reverse proxy.
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      # This instance is intended for a single, pre-created account.
      SIGNUPS_ALLOWED = false;
      INVITATIONS_ALLOWED = false;
      EMERGENCY_ACCESS_ALLOWED = false;
      PASSWORD_HINTS_ALLOWED = false;
    };
  };

  my.http.vaultwarden.port = 8222;
}
