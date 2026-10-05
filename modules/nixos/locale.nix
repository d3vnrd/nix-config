{lib, ...}: {
  time.timeZone = lib.mkDefault null; # default to UTC
  i18n.defaultLocale = "en_US.UTF-8";
}
