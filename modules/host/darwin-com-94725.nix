_:
# New company-issued machine with hostname `com-94725` that mirrors Andrew's base setup.
let
  user = "ags";
in
{
  _module.args.user = user;

  imports = [
    ./../darwin
  ];

  home-manager.users.${user} = {
    _module.args.user = user;
    imports = [
      ./../darwin/home
    ];
  };
}
