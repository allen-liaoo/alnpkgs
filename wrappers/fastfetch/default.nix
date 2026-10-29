{ lib, ... }:

{
  # jsonc (comments, trailing commas) is not valid JSON for `settings`; pass it verbatim
  flags."--config" = lib.mkForce "${./config.jsonc}";
}
