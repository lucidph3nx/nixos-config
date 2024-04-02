{ config, pkgs, ... }:

{
  services.git-sync = {
  	enable = true;
    repositories = {
      "github-sso-automation" = {
        uri = "ssh://git@github.com-jarden-digital:jarden-digital/github-sso-automation.git";
        path = "/Users/ben/code/github-sss-automation";
      };
      "trading-client" = {
        uri = "ssh://git@github.com-jarden-digital:jarden-digital/trading-client.git";
        path = "/Users/ben/code/trading-client";
      };
    };
  };
}
