# Reusable TPM + LUKS convenience module
{ config, lib, pkgs, ... }:
{
  options.my.tpmLuks.devices = lib.mkOption {
    type = with lib.types; attrsOf (attrs);
    default = {};
    description = ''Map of LUKS UUID -> attrset { device = <path>; tpm2 = bool; crypttabExtraOpts = [ .. ]; keyFile = <path>; }'';
  };

  config = lib.mkIf (config.my.tpmLuks.devices != {}) {
    boot.initrd.systemd.enable = true;

    security.tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };

    # Expand each provided device into boot.initrd.luks.devices entries
    boot.initrd.luks.devices = lib.mapAttrs (uuid: data: (let hasKey = builtins.hasAttr "keyFile" data; in {
      device = data.device;
      keyFile = lib.mkIf hasKey data.keyFile;
      crypttabExtraOpts = lib.optionals (data.tpm2 or false) (data.crypttabExtraOpts or [ "tpm2-device=auto" ]);
    })) config.my.tpmLuks.devices;
  };
}
