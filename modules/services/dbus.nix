{...}: {
  config = {
    services.dbus = {
      # use broker dbus implementation, higher performance
      implementation = "broker";
    };
  };
}
