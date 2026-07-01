{ config, pkgs, ... }:

let
  mod = "Mod4"; # Super as the main key (Alt is taken by Firefox's menu access keys).
in
{
  home.username = "duolok";
  home.homeDirectory = "/home/duolok";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    lf
    pulsemixer
    fzf
    bc
    nerd-fonts.fira-code

    # tmux keybindings (from macbook-dotfiles tmux.conf)
    fd
    skim
    # lazygit is provided by programs.lazygit below (themed).
    yazi
    timewarrior
    hostess

    # git pager
    diff-so-fancy

    # used by tj / aliases ported from macbook-dotfiles zsh
    spotify-player
    gh
    k9s

    # galaxy.nvim prerequisite (telescope's live_grep/find_files)
    ripgrep

    # unfree, needs nixpkgs.config.allowUnfree in configuration.nix
    spotify

    # `claude` wasn't actually on PATH anywhere - the `cl` alias and the
    # `claude` window in tj's build_back/build_devops were both pointing
    # at nothing until this.
    claude-code

    # nvim-treesitter shells out to a C compiler to build parsers; nothing
    # on this system provided "cc"/"gcc" before.
    gcc

    # GitHub PR/issue dashboard TUI (runs as `gh-dash` or `gh dash`).
    gh-dash
    # image viewer (X11, runs via XWayland on sway), video player.
    feh
    mpv
    # terminal client for the transmission daemon (enabled in configuration.nix).
    tremc
    # MPRIS control/metadata for the waybar Spotify module.
    playerctl
    # system info fetch tool.
    fastfetch

    # live system/process monitor (fastfetch is one-shot only).
    btop
    # JSON wrangling for gh / k9s output etc.
    jq
    # Nix dev tooling: LSP (autocomplete/errors for this config in nvim) and
    # the RFC-style formatter.
    nil
    nixfmt-rfc-style

    # PDF/document viewer, wrapped with the extra format plugins (default
    # ships mupdf/PDF only). djvu, PostScript, and comic-book archives.
    (zathura.override {
      plugins = [
        zathuraPkgs.zathura_pdf_mupdf
        zathuraPkgs.zathura_djvu
        zathuraPkgs.zathura_ps
        zathuraPkgs.zathura_cb
      ];
    })

    # ---- dev toolchains (restored from macbook-dotfiles usage) ----
    # kubernetes: kubectl backs the `k` alias; helm for charts. k9s already
    # installed above.
    kubectl
    kubernetes-helm
    # docker CLI comes from virtualisation.docker in configuration.nix (the
    # daemon + docker group), so it's not listed here.

    # C/C++ + task runners: gcc already installed above.
    cmake
    gnumake
    just

    # rust: rustc/cargo plus the dev tools (clippy lints, rustfmt, LSP).
    rustc
    cargo
    clippy
    rustfmt
    rust-analyzer

    # go: compiler + LSP.
    go
    gopls

    # python: backs the `p`/poetry-era `venv` aliases. plain interpreter for now.
    python3
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "foot";
    BROWSER = "firefox";
    MOZ_ENABLE_WAYLAND = "1";
  };

  fonts.fontconfig.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
  home.file."Pictures/Screenshots/.keep".text = "";

  # ---- Sway: dwm/Aerospace-flavored bindings, Alt (mod) as the main key ----
  # home-manager's sway defaults already use h/j/k/l for left/down/up/right
  # (focus, move, resize-mode), which matches both vi-mode muscle memory and
  # Aerospace's defaults. The entries below only add or override what's
  # missing relative to dwm: hard kill on mod+w, dmenu-style launcher on
  # mod+space, scratchpad terminal, screenshots, media keys, multi-monitor
  # focus, and a waybar toggle.
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = mod;
      terminal = "foot";
      menu = "wmenu-run -i -f 'FiraCode Nerd Font 10'";
      defaultWorkspace = "workspace number 1";

      gaps = {
        inner = 0;
        outer = 10;
      };

      # LG UltraGear+ 4K. 95.033Hz is the highest non-DSC 4K mode the GTX
      # 1070 Ti can drive over DisplayPort (Pascal has no DSC, so 4K@144
      # isn't reachable). This is the practical max, not 90Hz.
      output."DP-1".mode = "3840x2160@95.033Hz";

      window.border = 3;
      floating.border = 3;

      colors = {
        focused = {
          border = "#1b2432";
          background = "#060F19";
          text = "#ffffff";
          indicator = "#1b2432";
          childBorder = "#1b2432";
        };
        unfocused = {
          border = "#19192d";
          background = "#1d1d1d";
          text = "#ffffff";
          indicator = "#19192d";
          childBorder = "#19192d";
        };
      };

      input."type:keyboard" = {
        # caps:escape (not caps:swapescape): caps becomes Escape, but the
        # physical Escape key keeps acting as Escape instead of toggling
        # Caps Lock. swapescape was making vi-mode Escape presses toggle
        # the Caps Lock indicator, which is what was happening before.
        xkb_options = "caps:escape";
        # Keep the default 600ms delay so normal typing never triggers an
        # accidental repeat (avoids doubled characters), but a faster 40/s
        # repeat rate so held j/k in nvim still scrolls quicker than the
        # default 25/s once repeat kicks in.
        repeat_delay = "600";
        repeat_rate = "40";
      };

      bars = [ ]; # waybar replaces the built-in swaybar

      # Written out in full rather than layering on top of the module's
      # built-in defaults: home-manager's sway "default" keybindings are
      # discarded entirely as soon as this option is assigned here, so a
      # partial override would silently lose bindings instead of merging.
      keybindings = {
        # session / apps
        "${mod}+Return" = "exec foot";
        "${mod}+Shift+Return" = "exec foot";
        "${mod}+w" = "kill"; # dwm muscle memory
        "${mod}+space" = "exec wmenu-run -i -f 'FiraCode Nerd Font 10'"; # dwm muscle memory
        "${mod}+d" = "exec wmenu-run -i -f 'FiraCode Nerd Font 10'";
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+e" =
          "exec swaynag -t warning -m 'Exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
        "${mod}+Shift+x" = "exec swaylock -f --screenshot --effect-blur 7x5 --clock";
        "${mod}+BackSpace" = "exec ~/.config/scripts/powermenu.sh"; # power menu (lock/suspend/reboot/…)
        "${mod}+Shift+b" = "exec pkill -SIGUSR1 waybar";

        # focus / move, vim-style hjkl (matches Aerospace defaults)
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        # workspaces, exact parity with dwm's tag scheme
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";
        "${mod}+Tab" = "workspace back_and_forth"; # dwm's "last viewed tag"

        # layout
        "${mod}+b" = "splith";
        "${mod}+v" = "exec firefox";
        "${mod}+Shift+v" = "splitv";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+a" = "focus parent";
        "${mod}+s" = "layout stacking";
        "${mod}+e" = "exec foot -e pulsemixer"; # TUI volume mixer
        "${mod}+Shift+w" = "layout tabbed";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+minus" = "scratchpad show"; # dwm's spterm scratchpad
        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+r" = "exec foot -e yazi /home/duolok"; # file manager, opens in home
        "${mod}+Shift+r" = "mode resize"; # mirrors dwm's mfact h/l shrink/grow
        # direct window resize, hjkl (same directions as the resize mode)
        "${mod}+Ctrl+h" = "resize shrink width 30px";
        "${mod}+Ctrl+l" = "resize grow width 30px";
        "${mod}+Ctrl+j" = "resize grow height 30px";
        "${mod}+Ctrl+k" = "resize shrink height 30px";

        # live gap adjustment (Mod4+minus is the scratchpad, hence Ctrl).
        # =/- grow/shrink inner+outer by 5px; Ctrl+0 resets to 0/10.
        "${mod}+Ctrl+equal" = "gaps inner all plus 5, gaps outer all plus 5";
        "${mod}+Ctrl+minus" = "gaps inner all minus 5, gaps outer all minus 5";
        "${mod}+Ctrl+0" = "gaps inner all set 0, gaps outer all set 10";

        # multi-monitor, mirrors dwm's focusmon/tagmon
        "${mod}+comma" = "focus output left";
        "${mod}+period" = "focus output right";
        "${mod}+Shift+comma" = "move workspace to output left";
        "${mod}+Shift+period" = "move workspace to output right";

        # screenshots, mirrors dwm's Print/Shift+Print via maim
        "Print" = "exec grim \"$HOME/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png\"";
        "Shift+Print" = "exec sh -c 'grim -g \"$(slurp)\" - | tee \"$HOME/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png\" | wl-copy -t image/png'";

        # transparency toggle
        "${mod}+t" = "exec ~/.config/scripts/toggle-opacity.sh";

        # media/brightness keys, same XF86 keys as the dwm config
        "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
      };
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 28;
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "custom/spotify" "cpu" "memory" "clock" "tray" ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          # Roman-numeral workspaces (workspace name "1".."10" -> I..X).
          format = "{icon}";
          format-icons = {
            "1" = "I";
            "2" = "II";
            "3" = "III";
            "4" = "IV";
            "5" = "V";
            "6" = "VI";
            "7" = "VII";
            "8" = "VIII";
            "9" = "IX";
            "10" = "X";
            default = "•";
          };
        };
        # Spotify: current track from the desktop app via MPRIS. Click to
        # play/pause. The exec emits its own trailing " | " separator ONLY
        # when a track is playing (and truncates to 40 chars) - so when
        # nothing plays the module is empty/hidden and there's no dangling
        # leading pipe before CPU. `; true` keeps the exit code 0.
        "custom/spotify" = {
          format = "{}";
          interval = 5;
          exec = "t=$(${pkgs.playerctl}/bin/playerctl -p spotify metadata --format '{{artist}} - {{title}}' 2>/dev/null); [ -n \"$t\" ] && printf '%.40s | ' \"$t\"; true";
          on-click = "${pkgs.playerctl}/bin/playerctl -p spotify play-pause";
          tooltip = false;
        };
        # cpu has NO leading separator: it's either preceded by spotify's
        # trailing " | ", or (when spotify is off) it's the first module.
        "cpu" = {
          format = "CPU: {usage}%";
          interval = 3;
        };
        "memory" = {
          format = " | MEM: {percentage}%";
          interval = 5;
        };
        "clock" = {
          format = " | {:%a %d %b  %H:%M}";
        };
        "pulseaudio" = {
          format = "{volume}% {icon}";
          format-muted = "muted";
          format-icons = [ "" "" "" ];
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        "battery" = {
          format = "{capacity}% {icon}";
          format-icons = [ "" "" "" "" "" ];
        };
        "network" = {
          format-wifi = "{essid} ";
          format-ethernet = "eth ";
          format-disconnected = "down";
        };
        "tray" = {
          spacing = 8;
        };
      }
    ];
    style = ''
      * {
        font-family: "FiraCode Nerd Font", monospace;
        font-size: 12px;
      }
      window#waybar {
        background-color: #1d1d1d;
        color: #ffffff;
        border-bottom: 3px solid #19192d;
      }
      #workspaces button {
        padding: 0 8px;
        color: #ffffff;
      }
      #workspaces button.focused {
        background-color: #060F19;
        border-bottom: 3px solid #1b2432;
      }
      /* No horizontal padding here so the " | " separators (with a single
         space each side) are the only spacing -> perfectly even. */
      #custom-spotify, #cpu, #memory, #clock {
        padding: 0;
      }
      #tray {
        padding: 0 10px;
      }
    '';
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "keyboard";
        width = 370;
        height = 350;
        offset = "0x19";
        padding = 2;
        horizontal_padding = 2;
        transparency = 25;
        font = "Monospace 12";
        format = "<b>%s</b>\\n%b";
      };
      urgency_low = {
        background = "#1d2021";
        foreground = "#928374";
        timeout = 3;
      };
      urgency_normal = {
        foreground = "#ebdbb2";
        background = "#458588";
        timeout = 5;
      };
      urgency_critical = {
        background = "#1cc24d";
        foreground = "#ebdbb2";
        frame_color = "#fabd2f";
        timeout = 10;
      };
      # Silence Spotify's "now playing" notifications on every track change:
      # skip_display = no popup, history_ignore = keep it out of history too.
      spotify = {
        appname = "Spotify";
        skip_display = "true";
        history_ignore = "true";
      };
    };
  };

  # Automount removable media (USB/SSD). Watches udisks2 and mounts new
  # devices under /run/media/duolok/<label>; ~/mounted-dev symlinks there.
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "FiraCode Nerd Font:size=10";
      };
      # Vague (vague-theme/vague.nvim) 16-colour ANSI palette + the theme's
      # own terminal.lua mapping, so TUIs that lean on terminal colours
      # (lazygit, etc.) render coherently. Lives in [colors-dark] because
      # foot deprecated the plain [colors] section. Background is a neutral
      # very-dark-gray rather than Vague's near-black #141415. Window
      # transparency is handled on demand by the Mod4+t binding.
      colors-dark = {
        foreground = "cdcdcd";
        background = "1c1c1c"; # very dark gray

        regular0 = "252530"; # black   (line)
        regular1 = "d8647e"; # red     (error)
        regular2 = "7fa563"; # green   (plus)
        regular3 = "f3be7c"; # yellow  (warning)
        regular4 = "6e94b2"; # blue    (keyword)
        regular5 = "bb9dbd"; # magenta (parameter)
        regular6 = "aeaed1"; # cyan    (constant)
        regular7 = "cdcdcd"; # white   (fg)

        bright0 = "606079"; # bright black   (comment)
        bright1 = "e08398"; # bright red
        bright2 = "99b782"; # bright green
        bright3 = "f5cb96"; # bright yellow
        bright4 = "8ba9c1"; # bright blue
        bright5 = "c9b1ca"; # bright magenta
        bright6 = "bebeda"; # bright cyan
        bright7 = "d7d7d7"; # bright white

        selection-foreground = "cdcdcd";
        selection-background = "333738"; # visual
      };
    };
  };

  # syntax-highlighting cat replacement; also usable as an fzf previewer.
  programs.bat.enable = true;

  # smart `cd` that learns your most-used dirs. enableZshIntegration defaults
  # to true when programs.zsh is enabled, so `z <dir>` just works after rebuild.
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # lazygit's default theme is near-invisible against Vague; this gives it a
  # bright active border, a clearly-visible selected-line background, and
  # Vague-matched accent colours.
  programs.lazygit = {
    enable = true;
    settings = {
      gui.theme = {
        activeBorderColor = [ "#8ba9c1" "bold" ]; # bright blue
        inactiveBorderColor = [ "#606079" ];      # comment/gray
        optionsTextColor = [ "#8ba9c1" ];
        selectedLineBgColor = [ "#405065" ];      # search - clearly visible
        selectedRangeBgColor = [ "#405065" ];
        cherryPickedCommitBgColor = [ "#252530" ];
        cherryPickedCommitFgColor = [ "#c9b1ca" ];
        unstagedChangesColor = [ "#d8647e" ];     # red
        defaultFgColor = [ "#cdcdcd" ];
      };
    };
  };

  # ---- tmux: ported from macbook-dotfiles tmux/tmux.conf ----
  # Bindings m/J/W (mac-mini-services-picker.sh, open-audio-journal.sh,
  # work-mode.sh) are left commented out: those scripts are Mac-only and
  # weren't ported to this machine.
  programs.tmux = {
    enable = true;
    extraConfig = ''
      # Truecolor passthrough: default-terminal must be a *-256color terminfo,
      # and "*:RGB" advertises that the outer terminal (foot) supports 24-bit
      # colour, so themes/prompts render inside tmux exactly as in a fresh
      # terminal. The previous "tmux-256color:RGB" matched the wrong terminal
      # name and left tmux on screen-256color (no truecolor).
      set -g default-terminal "tmux-256color"
      set -ga terminal-features "*:RGB"
      set -g extended-keys on
      unbind C-b
      set -g prefix C-s
      bind-key C-s send-prefix
      set -g base-index 1
      set -g renumber-windows on
      set -g mode-keys vi
      set -g status-position top
      set -g status-justify absolute-centre
      set -g status-style "bg=default"
      set -g window-status-current-style "fg=black bg=white  "
      set -g window-status-current-style "fg=colour255,bg=default,bold"
      set -g window-status-separator ""
      set -g window-status-format "#[fg=colour240]#[default] #I:#W#{?window_flags,#{window_flags},} #[fg=colour240]#[default]"
      set -g window-status-current-format "#[fg=colour252]#[default] #I:#W#{?window_flags,#{window_flags},} #[fg=colour252]#[default]"
      set -g status-interval 5
      set -g status-left "#S"
      set -g status-right ""
      # for debugging
      set -g remain-on-exit "off"

      bind r source-file "~/.config/tmux/tmux.conf"
      bind b set -g status
      bind x kill-pane
      bind-key -n M-BSpace send-keys C-w
      bind e split-window -h -c "#{pane_current_path}"
      bind q split-window -v -c "#{pane_current_path}"
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind f run "tmux neww ~/.config/scripts/tmux-session-dispensary.sh"
      bind F run "tmux neww ~/.config/scripts/tmux-fzf-nvim.sh"
      bind g run "~/.config/scripts/open_github.sh"
      bind t run "tmux neww ~/.config/scripts/time.sh"
      bind N run "~/.config/scripts/tmux-session-dispensary.sh ~/documents/notes"
      bind P run "~/.config/scripts/tmux-session-dispensary.sh ~/documents/projects"
      bind D run "~/.config/scripts/tmux-session-dispensary.sh ~/.config"
      bind H run "~/.config/scripts/tmux-session-dispensary.sh ~"
      bind S run "~/.config/scripts/tmux-session-dispensary.sh ~/documents/projects/stormy"
      bind G neww -n "git" -c "#{pane_current_path}" lazygit
      bind y neww -n "yazi" -c "#{pane_current_path}" yazi
      bind O run "tmux neww ~/.config/scripts/links-picker.sh"
      bind L neww -n "links" "nvim ~/.config/links.tsv"
      # bind m run "tmux neww 'bash ~/.config/scripts/mac-mini-services-picker.sh'"  # Mac-only, not ported
      # bind J run "~/.config/scripts/open-audio-journal.sh"  # Mac-only, not ported
      # bind W run "tmux neww -n work-mode 'bash ~/.config/scripts/work-mode.sh toggle; printf \"\\nPress enter to close... \"; read -r _'"  # Mac-only, not ported
      bind E show-environment -g
    '';
  };

  home.file = {
    ".config/scripts/tmux-session-dispensary.sh" = {
      source = ./scripts/tmux-session-dispensary.sh;
      executable = true;
    };
    ".config/scripts/tmux-fzf-nvim.sh" = {
      source = ./scripts/tmux-fzf-nvim.sh;
      executable = true;
    };
    ".config/scripts/open_github.sh" = {
      source = ./scripts/open_github.sh;
      executable = true;
    };
    ".config/scripts/time.sh" = {
      source = ./scripts/time.sh;
      executable = true;
    };
    ".config/scripts/links-picker.sh" = {
      source = ./scripts/links-picker.sh;
      executable = true;
    };
    ".config/scripts/skim-themes.sh" = {
      source = ./scripts/skim-themes.sh;
      executable = true;
    };
    ".config/scripts/tmux-job.sh" = {
      source = ./scripts/tmux-job.sh;
      executable = true;
    };
    ".config/scripts/set-wallpaper.sh" = {
      source = ./scripts/set-wallpaper.sh;
      executable = true;
    };
    ".config/scripts/toggle-opacity.sh" = {
      source = ./scripts/toggle-opacity.sh;
      executable = true;
    };
    ".config/scripts/powermenu.sh" = {
      source = ./scripts/powermenu.sh;
      executable = true;
    };
    ".config/yazi/keymap.toml".source = ./yazi-keymap.toml;

    # galaxy.nvim, "complex" variant (duolok/galaxy-nvim). lazy.nvim
    # bootstraps and installs plugins into ~/.local/share/nvim on first
    # launch, which is writable and untouched by this symlink.
    ".config/nvim".source = ./nvim;
    "mounted-dev".source = config.lib.file.mkOutOfStoreSymlink "/run/media/duolok";
    # transmission-daemon downloads land here (see services.transmission).
    "torrents".source = config.lib.file.mkOutOfStoreSymlink "/var/lib/transmission/Downloads";
  };

  # ---- git: ported from macbook-dotfiles git/config ----
  programs.git = {
    enable = true;
    ignores = [
      "**/.claude/settings.local.json"
      "/services/actualbudget/data/"
    ];
    settings = {
      user = {
        name = "duolok";
        email = "dusan.lecic5@gmail.com";
      };
      core = {
        compression = 9;
        whitespace = "error";
        preloadindex = true;
      };
      # Fixed a stray leading "@" in the source config's insteadOf targets
      # ("@git@github.com:..."), which looked like an unrendered template
      # placeholder and would never have matched a real remote URL.
      url."git@github.com:duolok/".insteadOf = "dl:";
      url."git@github.com:".insteadOf = "gh:";
      status = {
        branch = true;
        showStash = true;
        showUntrackedFiles = "all";
      };
      diff = {
        context = 3;
        renames = "copies";
        interHunkContext = 10;
      };
      push = {
        autoSetupRemote = true;
        default = "current";
      };
      pull = {
        default = "current";
        rebase = true;
      };
      rebase = {
        autoStash = true;
        missingCommitsCheck = "warn";
      };
      pager = {
        branch = false;
        tag = false;
        diff = "diff-so-fancy | less --tabs=4 -RFX";
      };
      "diff-so-fancy" = {
        markEmptyLines = false;
        stripLeadingSymbols = false;
      };
      color.diff = {
        meta = "black bold";
        frag = "magenta";
        context = "white";
        whitespace = "yellow reverse";
        old = "red";
      };
    };
  };

  # ---- zsh: ported from oblivion (LARBS-derived) ----
  programs.starship.enable = true;

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autocd = true;
    defaultKeymap = "viins";
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000000;
      save = 10000000;
      path = "${config.xdg.cacheHome}/zsh/history";
    };

    shellAliases = {
      vim = "nvim";
      vimdiff = "nvim -d";

      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -vI";
      bc = "bc -ql";
      mkd = "mkdir -pv";

      # Alphabetical sort, dotfiles hidden. Dropped -A (was showing dotfiles)
      # and -U (which cancelled the -t sort, leaving output unsorted).
      ls = "ls -C -p --color=auto";
      grep = "grep --color=auto";
      diff = "diff --color=auto";

      ka = "killall";
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gst = "git status";
      e = "$EDITOR";
      t = "tmux";
      z = "zathura";
      lf = "lf";

      # ---- ported from macbook-dotfiles zsh/.zshrc ----
      venv = "source .venv/bin/activate";
      vi = "nvim";
      im = "nvim";
      n = "nvim"; # was a typo "nivm" in the source config
      k = "kubectl";
      cl = "claude";
      lg = "lazygit";
      nm = "neomutt";
      p = "poetry";
      mb = "~/Documents/projects/microbrew/target/debug/microbrew";
      yt = "lux";
      dl = "lux";
      dl-audio = ''yt-dlp -x --audio-format="mp3"'';
      src = "source ~/.config/zsh/.zshrc";
      cmake = "cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON";
      # These three depend on $GG_API/$GG_EW/$GG_WEB, which aren't defined
      # anywhere in macbook-dotfiles or this config - set them in
      # home.sessionVariables (or tell me the paths) or these will cd/point
      # nowhere.
      phpcs = "\${GG_API}/lib/vendor/bin/phpcs";
      phpmd = "\${GG_API}/lib/vendor/bin/phpmd";
      cd-ew = "cd \${GG_EW}";
      cd-w = "cd \${GG_WEB}";
      cd-a = "cd \${GG_API}";

      tj = "~/.config/scripts/tmux-job.sh";

      # One-shot NixOS rebuild from the flake in this repo.
      rebuild = "sudo nixos-rebuild switch --flake ~/fun/nixos-config#nixos";
      # Update all flake inputs (nixpkgs, home-manager) then rebuild.
      rebuild-update = "nix flake update --flake ~/fun/nixos-config && sudo nixos-rebuild switch --flake ~/fun/nixos-config#nixos";
    };

    # Mirrors oblivion's zshrc: vi-mode cursor shapes, lf-cd on ctrl-o,
    # bc on ctrl-a, fzf jump on ctrl-f/ctrl-n, edit-command-line on ctrl-e.
    initContent = ''
      export KEYTIMEOUT=1

      # menuselect keymap only exists once the complist module is loaded;
      # it must come before the bindkey -M menuselect calls below.
      zmodload zsh/complist

      bindkey -M menuselect 'h' vi-backward-char
      bindkey -M menuselect 'k' vi-up-line-or-history
      bindkey -M menuselect 'l' vi-forward-char
      bindkey -M menuselect 'j' vi-down-line-or-history
      bindkey -v '^?' backward-delete-char

      function zle-keymap-select () {
          case $KEYMAP in
              vicmd) echo -ne '\e[1 q';;
              viins|main) echo -ne '\e[5 q';;
          esac
      }
      zle -N zle-keymap-select
      zle-line-init() {
          zle -K viins
          echo -ne "\e[5 q"
      }
      zle -N zle-line-init
      echo -ne '\e[5 q'
      preexec() { echo -ne '\e[5 q' ;}

      lfcd () {
          tmp="$(mktemp -uq)"
          trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' HUP INT QUIT TERM PWR EXIT
          lf -last-dir-path="$tmp" "$@"
          if [ -f "$tmp" ]; then
              dir="$(cat "$tmp")"
              [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
          fi
      }
      bindkey -s '^o' '^ulfcd\n'
      bindkey -s '^a' '^ubc -lq\n'
      bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'

      autoload edit-command-line; zle -N edit-command-line
      bindkey '^e' edit-command-line
      bindkey -M vicmd '^e' edit-command-line
    '';

    # Login-shell only (sourced once per login, unlike initContent which
    # runs for every interactive shell) - mirrors oblivion's `exec startx`.
    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec sway
      fi
    '';
  };
}
