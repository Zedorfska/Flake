{ self, ... }: {
  flake.nixosModules.gpu-screen-recorder = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.services.gpu-screen-recorder;
    user = config.internal.username;
    
    gsr = "${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder";
    
    commonFlags = "-c mp4 -f 60 -a \"app-inverse:spotify|app-inverse:Firefox|app-inverse:LibreWolf|app-inverse:Music Player Daemon|app-inverse:WEBRTC VoiceEngine|app-inverse:paplay\" -a default_input -a \"app:WEBRTC VoiceEngine\" -a \"app:Firefox|app:LibreWolf|app:spotify|app:Music Player Daemon|app:paplay\" -q high -r 120 -replay-storage ram -restart-replay-on-save no -k auto -ac opus -ab 128 -fm cfr -bm auto -cr limited -tune performance -df no -cursor yes -keyint 2.0 -encoder gpu -o /home/${user}/Videos/Clips/ -ro /home/${user}/Videos/Recordings";
    
    mkRecorder = monitor: size: "${pkgs.bash}/bin/bash -c '${gsr} -w ${monitor} -s ${size} ${commonFlags}'";

    create-clip = pkgs.writeShellScriptBin "create-clip" ''
      CODE="3"
      MONITOR="main"
      SILENT="FALSE"
      while getopts ":c:m:s" OPTION; do
          case $OPTION in
              c) CODE="$OPTARG" ;;
              m) MONITOR="$OPTARG" ;;
              s) SILENT="TRUE" ;;
              *) echo "Invalid flag: $OPTION"; exit 1 ;;
          esac
      done
      case $CODE in
          "1") TIME="10s" ;;
          "2") TIME="30s" ;;
          "3") TIME="1m" ;;
          "4") TIME="5m" ;;
          "5") TIME="10m" ;;
          "6") TIME="30m" ;;
          *) echo "Invalid code"; exit 1 ;;
      esac
      case $MONITOR in
          "main") MONITOR_ARG="DP-1" ;;
          "side") MONITOR_ARG="HDMI-A-1" ;;
          *) echo "Invalid monitor"; exit 1 ;;
      esac

      if [[ $SILENT == "FALSE" ]]; then
          ${pkgs.libnotify}/bin/notify-send --app-name "gpu-screen-recorder" "Creating clip..." "Monitor $MONITOR | $TIME"
      fi

      pkill -SIGRTMIN+$CODE -f "gpu-screen-recorder -w $MONITOR_ARG"

      if [[ $SILENT == "FALSE" ]]; then
          sleep 0.1 
          ${pkgs.libnotify}/bin/notify-send --app-name "gpu-screen-recorder" "Created clip" "Monitor $MONITOR | $TIME"
      fi
    '';
  in
  {
    options.device.features.services.gpu-screen-recorder.enable = lib.mkEnableOption "GSR Replay System";

    config = lib.mkIf cfg.enable {
      programs.gpu-screen-recorder.enable = true;

      home-manager.users.${user} = {
        home.packages = [ pkgs.gpu-screen-recorder create-clip ];

        systemd.user.services.gpu-screen-recorder-main = {
          Unit = {
            Description = "GPU Screen Recorder - DP-1";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
            ExecStart = mkRecorder "DP-1" "1920x1080";
            Restart = "on-failure";
            RestartSec = "5s";
            TimeoutStopSec = "5";
            KillSignal = "SIGINT";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };

        systemd.user.services.gpu-screen-recorder-side = {
          Unit = {
            Description = "GPU Screen Recorder - HDMI-A-1";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
            ExecStart = mkRecorder "HDMI-A-1" "1680x1050";
            Restart = "on-failure";
            RestartSec = "5s";
            TimeoutStopSec = "5";
            KillSignal = "SIGINT";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
