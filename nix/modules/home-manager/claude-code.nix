{
  pkgs,
  config,
  inputs,
  ...
}:
{
  home-manager.users."${config.system.primaryUser}" = { config, ... }: {
    home.packages =
      let
        pkgsUnstable = import inputs.nixpkgs-unstable {
          system = pkgs.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
      in
      [
        pkgsUnstable.claude-code
      ];

    home.file.".claude" = {
      enable = true;
      recursive = true;
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/claude";
    };
  };
}
