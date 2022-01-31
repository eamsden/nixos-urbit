{ sources ? import sources.nix }:
{
  overlay = import ./overlay.nix sources;
}
