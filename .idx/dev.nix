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
            "$PORT"
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
            "-d"
            "emulator-5554"
          ];
          manager = "flutter";
        };
      };
    };
  };
}
