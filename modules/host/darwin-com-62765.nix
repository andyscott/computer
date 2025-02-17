_:
let user = "ags"; in {
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
