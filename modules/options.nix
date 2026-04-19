{ lib, ... }: {
  options.device = {
    core  = lib.mkOption { type = lib.types.submodule {}; default = {}; };
    #tools = lib.mkOption { type = lib.types.submodule {}; default = {}; };
    twm   = lib.mkOption { type = lib.types.submodule {}; default = {}; };

    features = {
      browsers     = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      bundles      = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      chat         = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      cli          = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      drivers      = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      environments = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      fonts        = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      gaming       = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      launchers    = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      services     = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      software     = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      terminals    = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      theme        = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      tools        = lib.mkOption { type = lib.types.submodule {}; default = {}; };
      filemanagers = lib.mkOption { type = lib.types.submodule {}; default = {}; };
    };
  };
}
