# Shared ZFS settings module
{ config, lib, ... }:
{
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  # Hosts can append extra pools via boot.zfs.extraPools
}
