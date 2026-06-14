{ hostVars, ... }:
{
  system.primaryUser = hostVars.username;
  users.users.${hostVars.username}.home = /Users/mickael;
}
