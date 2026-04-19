{ self, ... }: {
  flake.nixosModules.rmpc = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.cli.rmpc;
    user = config.internal.username;
  in {
    # Ensure MPD is imported/enabled since RMPC needs it to function
    imports = [ self.nixosModules.mpd ];
    
    options.device.features.cli.rmpc.enable = lib.mkEnableOption "RMPC (MPD Client)" // {
      default = true;
    };

    config = lib.mkIf cfg.enable {
      # RMPC requires MPD to function.
      device.features.services.mpd.enable = lib.mkDefault true;

      home-manager.users.${user} = {
        programs.rmpc = {
          enable = true;
          config = ''
            #![enable(implicit_some)]
            ConfigFile(
              address: "127.0.0.1:6600",
              // # theme: "Zedorfska"
              ui: (
                album_art_enabled: true,
                album_art_display_strategy: "Kitty",
              ),
              keybinds: (
                global: {
                  ":":       CommandMode,
                  ",":       VolumeDown,
                  "s":       Stop,
                  ".":       VolumeUp,
                  "<Tab>":   NextTab,
                  "<S-Tab>": PreviousTab,
                  "1":       SwitchToTab("Queue"),
                  "2":       SwitchToTab("Directories"),
                  "3":       SwitchToTab("Artists"),
                  "4":       SwitchToTab("Album Artists"),
                  "5":       SwitchToTab("Albums"),
                  "6":       SwitchToTab("Playlists"),
                  "7":       SwitchToTab("Search"),
                  "q":       Quit,
                  ">":       NextTrack,
                  "k":       TogglePause,
                  "<":       PreviousTrack,
                  "l":       SeekForward,
                  "e":       ToggleRepeat,
                  "r":       ToggleRandom,
                  "t":       ToggleConsume,
                  "z":       ToggleSingle,
                  "j":       SeekBack,
                  "~":       ShowHelp,
                  "u":       Update,
                  "U":       Rescan,
                  "I":       ShowCurrentSongInfo,
                  "O":       ShowOutputs,
                  "P":       ShowDecoders,
                  "R":       AddRandom,
                },
                navigation: {
                  "<Up>":      Up,
                  "<Down>":    Down,
                  "<Left>":    Left,
                  "<Right>":   Right,
                  "<C-k>":     PaneUp,
                  "<C-j>":     PaneDown,
                  "<C-h>":     PaneLeft,
                  "<C-l>":     PaneRight,
                  "<C-u>":     UpHalf,
                  "N":         PreviousResult,
                  "a":         Add,
                  "A":         AddAll,
                  "\"":         Rename,
                  "n":         NextResult,
                  "g":         Top,
                  "<Space>":   Select,
                  "<C-Space>": InvertSelection,
                  "G":         Bottom,
                  "<CR>":      Confirm,
                  "i":         FocusInput,
                  "J":         MoveDown,
                  "<C-d>":     DownHalf,
                  "/":         EnterSearch,
                  "<C-c>":     Close,
                  "<Esc>":     Close,
                  "K":         MoveUp,
                  "D":         Delete,
                  "B":         ShowInfo,
                },
                queue: {
                  "D":      DeleteAll,
                  "<CR>":   Play,
                  "<C-s>":  Save,
                  "a":      AddToPlaylist,
                  "d":      Delete,
                  "C":      JumpToCurrent,
                  "X":      Shuffle,
                },
              ),
            )
          '';
        };
      };
    };
  };
}
