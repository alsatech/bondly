# Firebase Studio (Project IDX) environment for Bondly Flutter app
# Docs: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  channel = "unstable";

  packages = [
    pkgs.flutter
    pkgs.jdk17
    pkgs.unzip
  ];

  env = {};

  idx = {
    extensions = [
      "Dart-Code.dart-code"
      "Dart-Code.flutter"
    ];

    workspace = {
      onCreate = {
        flutter-pub-get = "flutter pub get";
      };
      onStart = {};
    };

    previews = {
      enable = true;
      previews = {
        web = {
          command = [
            "flutter"
            "run"
            "--machine"
            "-d"
            "web-server"
            "--web-hostname"
            "0.0.0.0"
            "--web-port"
            "3000"
            # Using port 3000 instead of $PORT to avoid Firebase Studio's
            # built-in auth proxy that intercepts requests on the assigned
            # preview port (typically 9002). Port 3000 is not intercepted
            # by Firebase Studio's forwardAuthCookie mechanism, so login
            # requests reach the backend directly.
            # TECH_DEBT: re-enable debug hot reload once Firebase Studio
            # supports WSS forwarding to the preview port.
            "--profile"
          ];
          manager = "flutter";
        };
        android = {
          command = [
            "flutter"
            "run"
            "--machine"
            "-d"
            "android"
          ];
          manager = "flutter";
        };
      };
    };
  };
}
