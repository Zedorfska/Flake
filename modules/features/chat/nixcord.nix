{ self, inputs, ... }: {
  flake.nixosModules.nixcord = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.chat.nixcord;
    user = config.internal.username;
    nasinNanpaFont = "${pkgs.nasin-nanpa}/share/fonts/opentype/nasin-nanpa.otf";
  in {
    options.device.features.chat.nixcord.enable = lib.mkEnableOption "Nixcord (Discord with Vencord/Equicord)";
    config = lib.mkIf cfg.enable {
      
      device.features.tools.portals.enable = true;

      home-manager.users.${user} = { lib, ...}: {
        imports = [ inputs.nixcord.homeModules.nixcord ];
        
        home.activation.equibopSettingsCleanup = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
          # This is so fucking evil but I literally dont care
          rm -f "$HOME/.config/equibop/settings/settings.json.backup"
        '';

        home.activation.equibopSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
          settingsDir="$HOME/.config/equibop/settings"
          settingsFile="$settingsDir/settings.json"

          mkdir -p "$settingsDir"
          if [ -L "$settingsFile" ]; then
            cp --remove-destination "$(readlink -f "$settingsFile")" "$settingsFile"
            chmod 644 "$settingsFile"
          fi
        '';

        programs.nixcord = {
          enable = true;
          equibop = {
            enable = true;
            settings = {
              autoUpdate = true;
              autoUpdateNotification = false;
            };
            package = pkgs.equibop.overrideAttrs (oldAttrs: {
            nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
            postFixup = (oldAttrs.postFixup or "") + ''
              wrapProgram $out/bin/equibop \
                --add-flags "--ozone-platform-hint=auto" \
                --add-flags "--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer" \
                --add-flags "--lang=en-UK" \
                --set-default ELECTRON_OZONE_PLATFORM_HINT auto \
                --set-default NVD_BACKEND direct \
                --set-default __GLX_VENDOR_LIBRARY_NAME nvidia
              ''; # EVIL UK
            });
          };

          extraConfig = {
              hardwareAcceleration = true;
              video = {
                remote_screenshare_optimization = false;
                video_encoding = false;
              };
              DANGEROUS_ENABLE_DEVTOOLS_ONLY_ENABLE_IF_YOU_KNOW_WHAT_YOU_ARE_DOING = false;
            };

quickCss = ''
  @font-face {
    font-family: "nasin-nanpa";
    src: url("file://${pkgs.nasin-nanpa}/share/fonts/opentype/nasin-nanpa.otf");
    unicode-range: U+F1900-U+F19FF;
  }

  * {
    font-family: inherit, "nasin-nanpa" !important;
  }
'';

          config = {
            # TODO: I am NOT indenting all of ts rn
            autoUpdate = true;
            notifyAboutUpdates = false;
            autoUpdateNotification = false;
            frameless = true;
            useQuickCss = true; # LON
            transparent = false;

            
            plugins = {

              ###
              ### Control
              ###
              # Mouse
              messageClickActions =
              {
                enable = true;

                disableInDms = false;
                disableInSystemDms = true;
                clickTimeout = 300;
                selectionHoldTimeout = 300;
                useSelectionForQuote = false;
                deferDoubleClickForTriple = false;
                quoteWithReply = true;
                reactEmoji = "";

                addAdditionalReacts = false;
                additionalReactEmojis = "";

                singleClickAction = "DELETE";
                singleClickOthersAction = "DELETE";
                singleClickModifier = "BACKSPACE";

                doubleClickAction = "EDIT";
                doubleClickOthersAction = "REPLY";
                doubleClickHoldThreshold = 0;
                doubleClickModifier = "NONE";

                tripleClickAction = "NONE";
                tripleClickModifier = "NONE";
              };
              middleClickTweaks =
              {
                enable = true;

                openScope = "none";
                pasteScope = "always";
                pasteThreshold = 100;
              };
              dragify =
              {
                enable = false;
                allowChatBodyDrop = false;
                channelOutput = "link";
                inviteMaxUses = 1;
                inviteExpireAfter = 1800;
                inviteTemporaryMembership = false;
                reuseExistingInvites = false;
                userOutput = "mention";
              };
              quickReply.enable = true;
              voiceChatDoubleClick.enable = true;

              # Keyboard
              revealAllSpoilers.enable = true;
              webKeybinds.enable = true;
              RecentDMSwitcher.enable = false;
              betterPlusReacts.enable = true;
              frequentQuickSwitcher.enable = false;
              keyboardNavigation.enable = false;
              toggleVideoBind =
              {
                enable = true;
                keyBind = "H";
                reqAlt = true;
                reqCtrl = true;
                reqShift = false;
              };

              ###
              ### Misc
              ###
              newGuildSettings =
              {
                enable = true;
                events = true;    # Mute events
                everyone = true;    # Mute @everyone
                guild = false;    # Whether to mute guild
                messages = 1;        # Only mentions
                role = false;        # Suppress role mentions
                showAllChannels = true; # Show all channels
              };
              ReviewDB.enable = false;
              ClearURLs.enable = true;
              crashHandler.enable = true;
              disableCallIdle.enable = true;
              disableDeepLinks.enable = false;
              loadingQuotes =
              {
                enable = true;
                additionalQuotes = "Test Quote | Znyeg";
                additionalQuotesDelimiter = "|";
                enableDiscordPresetQuotes = false;
                enablePluginPresetQuotes = false;
              };
              noOnboardingDelay.enable = true;
              replaceGoogleSearch =
              {
                enable = true;
                customEngineName = "DuckDuckGo";
                customEngineURL = "https://duckduckgo.com/";
                replacementEngine = "off";
              };
              spotifyCrack.enable = true;
              validReply.enable = true;
              validUser.enable = true;
              youtubeAdblock.enable = true;
              webRichPresence.enable = false;
              webScreenShareFixes.enable = true; # Vencord is web or whatever
              UserPFP = # TODO: setup
              {
                enable = false;
                #databaseSource = ""; TODO: doesnt work lol
                #overrideServerAvatars = true;
                #preferNitro = true;
              };
              atSomeone.enable = true;
              idleAutoRestart =
              {
                enable = false;
                isEnabled = true;
                idleMinutes = 30.0;
              };
              messageBurst =
              {
                enable = false;
                shouldMergeWithAttachment = false;
                timePeriod = 5;
                useSpace = false;
              };
              noPushToTalk.enable = false;
              questify =
              {
                enable = true;

                #completeAchievementQuestsInBackground = true;
                #completeGameQuestsInBackground = true;
                #completeVideoQuestsInBackground = true;
                completeVideoQuestsQuicker = true;

                autoCompleteQuestsSimultaneously = true;
                disableQuestsEverything = true;
                questButtonDisplay = "never";
              };
              voiceRejoin =
              {
                enable = true;
                applyOnlyToDms = false;
                preventReconnectIfCallEnded = "both";
                rejoinDelay = 1.0;
                rejoinTimeout = 60.0;
              };
              whosWatching =
              {
                enable = true;
                showPanel = true;
              };

              ###
              ### UI changes
              ### 
              platformIndicators.enable = true;
              sortFriendRequests.enable = false;
              sortFriends.enable = true;
              showMeYourName =
              {
                enable = true;
                includedNames = "{display}";
                removeDuplicates = true;
                displayNameColor = "#c9cdfb";
              };
              typingIndicator =
              {
                enable = true;
                includeMutedChannels = true;
                indicatorMode = 2;
              };
              typingTweaks =
              {
                enable = true;
                alternativeFormatting = true;
                showAvatars = true;
                showRoleColors = false;
              };
              MutualGroupDMs.enable = true;
              accountPanelServerProfile.enable = true;
              alwaysAnimate =
              {
                enable = true;
                icons = true;
                nameplates = false;
                roleGradients = false;
                serverBanners = false;
                statusEmojis = false;
              };
              betterGifAltText.enable = true;
              #betterNotesBox =
              #{
              #  enable = true;
              #  hide = true;
              #};
              betterRoleContext.enable = true;
              betterRoleDot.enable = false;
              betterSettings.enable = true;
              betterUploadButton.enable = true;
              biggerStreamPreview.enable = true;
              clientTheme = { enable = false; color = "c45a75"; };
              copyEmojiMarkdown.enable = true;
              copyFileContents.enable = true;
              copyStickerLinks.enable = true;
              dontRoundMyTimestamps.enable = true;
              favoriteGifSearch.enable = true;
              fixCodeblockGap.enable = true;
              fixImagesQuality.enable = false;
              fixSpotifyEmbeds.enable = true;
              forceOwnerCrown.enable = true;
              friendInvites.enable = true;
              friendsSince.enable = true;
              fullSearchContext.enable = true;
              fullUserInChatbox.enable = true;
              gameActivityToggle.enable = false;
              imageFilename.enable = false;
              imageZoom = { enable = false; }; # TODO: eventually set this up but ts ass
              implicitRelationships.enable = true;
              keepCurrentChannel.enable = true;
              memberCount.enable = false;
              mentionAvatars.enable = false;
              messageLatency.enable = true;
              messageLinkEmbeds =
              {
                enable = true;
                automodEmbeds = "always";
              };
              noMosaic.enable = true;
              noPendingCount =
              {
                enable = true;
                hideFriendRequestsCount = false;
                hideMessageRequestsCount = false;
                hidePremiumOffersCount = true;
              };
              noProfileThemes.enable = true;
              noReplyMention.enable = false;
              noServerEmojis.enable = false;
              noSystemBadge.enable = false;
              noTypingAnimation.enable = false;
              noUnblockToJump.enable = true;
              openInApp.enable = false; # TODO: This just doesnt work lol
              pauseInvitesForever.enable = false;
              pictureInPicture =
              {
                enable = true;
                loop = false;
              };
              previewMessage.enable = false;
              quickMention.enable = false;
              readAllNotificationsButton.enable = false;
              replyTimestamp.enable = true;
              reverseImageSearch.enable = false;
              roleColorEverywhere =
              {
                enable = false;
                chatMentions = false;
                colorChatMessages = false;
                memberList = false;
                messageSaturation = 30.0;
                pollResults = false;
                reactorsList = false;
                voiceUsers = false;
              };
              sendTimestamps.enable = true;
              serverListIndicators.enable = false;
              shikiCodeblocks =
              {
                enable = true;
                bgOpacity = 100.0;
                #customTheme = "";
                #theme = "";
                tryHljs = "SECONDARY";
                useDevIcon = "GREYSCALE";
              };
              showAllMessageButtons.enable = false;
              showTimeoutDuration =
              {
                enable = true;
                displayStyle = "ssalggnikool"; # What
              };
              silentMessageToggle.enable = false;
              superReactionTweaks =
              {
                enable = true;
                superReactByDefault = false;
                superReactionPlayingLimit = 0.0; # Why the FUCK is this a float
                unlimitedSuperReactionPlaying = false;
              };
              themeAttributes.enable = false; # TODO: what
              translate.enable = false;
              unindent.enable = false;
              unlockedAvatarZoom.enable = true;
              userMessagesPronouns.enable = true;
              userVoiceShow =
              {
                enable = true;
                showInMemberList = true;
                showInMessages = false;
                showInUserProfileModal = true;
              };
              viewIcons =
              {
                enable = true;
                format = "png";
                imgSize = "1024";
              };
              voiceDownload.enable = true;
              voiceMessages =
              {
                enable = true;
                echoCancellation = true;
                noiseSuppression = true;
              };
              volumeBooster.enable = true;
              webContextMenus.enable = true;
              FullVCPFP.enable = true;
              VCPanelSettings.enable = false;
              alwaysExpandProfiles.enable = false;
              alwaysExpandRoles.enable = false;
              autoZipper =
              {
                enable = true;
                extensions = ".psd,.blend,.exe,.dmg,.app,.apk,.iso";
              };
              bannersEverywhere.enable = false;
              betterActivities =
              {
                enable = false;
                allActivitiesStyle = "carousel";
                hideTooltip = true;
                iconSize = 5.0;
                memberList = false;
                removeGameActivityStatus = false;
                renderGifs = true;
                specialFirst = true;
                userPopout = true;
              };
              betterAudioPlayer.enable = false;
              betterInvites.enable = true;
              bypassPinPrompt.enable = true;
              cleanChannelName.enable = true;
              clickableRoles.enable = true;
              commandPalette.enable = false;
              #components.enable = false;
              # Fuck you
              declutter =
                {
                  enable = true;
                  alwaysShowUsername = true;
                  removeAudioMenus = false;
                  removeBillingSettings = true;
                  removeButtonTooltips = false;
                  removeClanTag = false;
                  removeGiftButton = true;
                  removeNameplate = true;
                  removeProfileEffect = true;
                  removeQuestsAboveDM = true;
                  removeServerBoostInfo = true;
                  removeShopAboveDM = true;
                  removeUnavailableEmojiPicker = true;
                };
              noNitroUpsell.enable = true;

              equicordHelper =
                {
                  enable = true;
                  accountStandingButton = false;
                  forceRoleIcon = false;
                  noBulletPoints = false;
                  noMirroredCamera = true;
                  noModalAnimation = true;
                  refreshSlashCommands = true;
                  removeActivitySection = true;
                  restoreFileDownloadButton = true;
                  showYourOwnActivityButtons = false;
                };
              gifCollections.enable = false;
              gitHubRepos =
                {
                  enable = true;
                  showLanguage = true;
                  #showRepositoryTab = true; # FUCK
                  showStars = true;
                };
              googleThat =
                {
                  enable = true;
                  customEngineURL = "https://duckduckgo.com/";
                  defaultEngine = "DuckDuckGo";
                };
              #guildTagSettings = # FUCK
              #  {
              #    enable = true;
              #    disableAdoptTagPrompt = true;
              #    #hideTags = false; # Commented out because a different mod does this
              #  };
              #holyNotes.enable = false; # FUCK
              iconViewer.enable = false;
              instantScreenshare.enable = false;
              invisibleChat =
                {
                  enable = false;
                  savedPasswords = "";
                };
              inviteDefaults =
                {
                  enable = true;
                  inviteDuration = 1800;
                  maxUses = 1;
                  temporaryMembership = false;
                };
              mediaPlaybackSpeed =
                {
                  enable = false;
                  defaultAudioSpeed = 1.0;
                  defaultVideoSpeed = 1.0;
                  defaultVoiceMessageSpeed = 1.0;
                };
              messageColors.enable = true;
              messageNotifier =
                {
                  enable = false;
                  users = "689483281804034088";
                };
              messagePeek =
                {
                  enable = true;
                  hideMuted = false;
                };
              messageTranslate =
                {
                  enable = false;

                  #confidenceRequirement = "0.8"; # FUCK
                  targetLanguage = "en";
                };
              micLoopbackTester.enable = false;
              moreCommands.enable = true;
              moreQuickReactions =
                {
                  enable = false;

                  frequentEmojis = true;
                  compactMode = false;

                  reactionCount = 5;
                  columns = 4.0;
                  rows = 2.0;

                  scroll = true;
                };
              neverPausePreviews.enable = true;
              newPluginsManager.enable = true;
              noRoleHeaders.enable = false;
              normalizeMessageLinks.enable = true;
              notificationTitle.enable = true;
              orbolayBridge = # TODO: Look into this
                {
                  enable = true;

                  isKeybindEnabled = true;
                  messageAlignment = "topright";
                  messagesSemitransparent = false;
                  port = 6888;
                  userAlignment = "topleft";
                  voiceSemitransparent = true;
                };
              pinIcon.enable = true;
              randomVoice = # TODO: yeah
                {
                  enable = false;
                };
              showBadgesInChat =
                {
                  enable = true;

                  ##
                  showDiscordNitro = false;
                  showDiscordProfile = false;
                  ##
                };
              timezones =
                {
                  enable = false;
                  _24hTime = true;
                  askedTimezone = false;
                  databaseUrl = "https://timezone.creations.works";
                  preferDatabaseOverLocal = true;
                  showMessageHeaderTime = true;
                  showOwnTimezone = true;
                  showProfileTime = true;
                  showTimezoneInfo = true;
                  useDatabase = true;
                };
              toastNotifications = # TODO: yes
                {
                  enable = false;
                };
              toneIndicators =
                {
                  enable = false;
                  customIndicators = "";
                  prefix = "/";
                };
              unitConverter =
                {
                  enable = false;
                  myUnits = "metric";
                };
              universalMention =
                {
                  enable = true;
                  globalMention = false;
                  onlyDMUsers = false;
                };

              ### 
              ### Snooping
              ###
              messageLogger =
                {
                  enable = false;

                  logDeletes = true;
                  logEdits = true;

                  collapseDeleted = false;
                  deleteStyle = "text";
                  inlineEdits = true;
                  showEditDiffs = false;
                  separatedDiffs = false;

                  ignoreBots = true;
                  ignoreChannels = "";
                  ignoreGuilds = "";
                  ignoreSelf = false;
                  ignoreUsers = "";
                };
              messageLoggerEnhanced =
                {
                  enable = false;

                  alwaysLogCurrentChannel = true;
                  alwaysLogDirectMessages = true;
                  attachmentFileExtensions = "png,jpg,jpeg,gif,webp,mp4,webm,mp3,ogg,wav";
                  attachmentSizeLimitInMegabytes = 12;
                  blacklistedIds = "";
                  cacheLimit = 1000;
                  cacheMessagesFromServers = false;
                  hideMessageFromMessageLoggers = false; # wtf
                  hideMessageFromMessageLoggersDeletedMessage = "false";
                  ignoreBots = true;
                  ignoreMutedCategories = false;
                  ignoreMutedChannels = false;
                  ignoreMutedGuilds = false;
                  ignoreSelf = false;
                  ignoreWebhooks = true;
                  messageLimit = 200;
                  messagesToDisplayAtOnceInLogs = 100;
                  permanentlyRemoveLogByDefault = false;
                  preserveCurrentChannel = true;
                  saveImages = true;
                  saveMessages = true;
                  showLogsButton = true;
                  showWhereMessageIsFrom = false;
                  sortNewest = true;
                  timeBasedCleanupMinutes = 0;
                  whitelistedIds = "";
                };
              serverInfo.enable = true;
              showHiddenChannels.enable = false;
              permissionsViewer.enable = false;
              silentTyping.enable = false;
              PinDMs = { enable = true; };
              relationshipNotifier =
                {
                  enable = true;
                  notices = true;
                  offlineRemovals = true;
                  friends = true;
                  servers = true;
                  groups = true;
                  friendRequestCancels = true;
                };
              IRememberYou.enable = false;
              keywordNotify =
                {
                  enable = false;
                  amountToKeep = 0;
                  ignoreBots = true;
                };
              vcNarratorCustom =
                {
                  enable = false;
                };
              #voiceChannelLog = # FUCK
              #  {
              #    enable = false;
              #    ignoreBlockedUsers = false;
              #    #mode = 1; # FUCK
              #    #voiceChannelChatSelf = true; # FUCK
              #    voiceChannelChatSilent = false;
              #    voiceChannelChatSilentSelf = false;
              #  };

              ###
              ### Audio
              ###
              notificationVolume =
                {
                  enable = false;
                  notificationVolume = 100.0;
                };
              customSounds.enable = true; # Evil that this isnt declarative
              pingNotifications =
                {
                  enable = true;

                  dms = true;
                  friends = false;
                  ignoreMuted = true;
                  mentions = true;
                  showInActive = true;
                };

              ###
              ### Commands
              ###
              quoter =
              {
                enable = true;
                grayscale = true;
                quoteFont = "M PLUS Rounded 1c";
                saveAsGif = false;
                showWatermark = false;
              };

              ###
              ### Fixes
              ###
              fixYoutubeEmbeds.enable = true;
              searchFix.enable = true;
              streamingCodecDisabler =
              {
                enable = false;
                disableH265Codec = true;
              };
            };
          };
        };
      };
    };
  };
}
