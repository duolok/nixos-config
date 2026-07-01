# nixos-config

Flake-based NixOS + [home-manager](https://github.com/nix-community/home-manager)
configuration for host `nixos` (user `duolok`). Everything needed to rebuild the
system lives in this repo.

## Layout

| Path                         | What it is                                                    |
| ---------------------------- | ------------------------------------------------------------ |
| `flake.nix` / `flake.lock`   | Flake entrypoint; pins nixpkgs + home-manager (release 26.05)|
| `configuration.nix`          | System config (boot, users, services, system packages)       |
| `hardware-configuration.nix` | Machine-specific hardware scan (see restore note below)      |
| `home.nix`                   | User environment via home-manager (sway, zsh, waybar, …)     |
| `nvim/`                      | Neovim config, symlinked to `~/.config/nvim`                 |
| `scripts/`                   | Helper scripts, symlinked into `~/.config/scripts`           |
| `yazi-keymap.toml`           | Yazi keymap, symlinked to `~/.config/yazi/keymap.toml`       |

## Rebuild

```sh
sudo nixos-rebuild switch --flake ~/fun/nixos-config#nixos
```

The `rebuild` shell alias (defined in `home.nix`) does exactly this.

Update pinned inputs (nixpkgs, home-manager) and rebuild:

```sh
nix flake update --flake ~/fun/nixos-config
sudo nixos-rebuild switch --flake ~/fun/nixos-config#nixos   # or: rebuild-update
```

Preview a build without switching:

```sh
nixos-rebuild build --flake ~/fun/nixos-config#nixos
```

## Restore on a fresh machine

1. Install NixOS as usual and enable flakes:

   ```sh
   # add to /etc/nixos/configuration.nix, then `nixos-rebuild switch`
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```

   (or pass `--extra-experimental-features "nix-command flakes"` to each command).

2. Clone this repo:

   ```sh
   git clone git@github.com:duolok/nixos-config.git ~/fun/nixos-config
   ```

3. **Regenerate hardware config for the new machine** (disk UUIDs / drivers
   differ per machine):

   ```sh
   sudo nixos-generate-config --show-hardware-config > ~/fun/nixos-config/hardware-configuration.nix
   ```

4. Rebuild:

   ```sh
   sudo nixos-rebuild switch --flake ~/fun/nixos-config#nixos
   ```

## Notes

- Flakes only see files tracked by git — `git add` new files before rebuilding.
- Pinned to NixOS **26.05**. To move releases, bump the refs in `flake.nix`
  (`nixos-XX.XX` and `release-XX.XX`), adjust `system.stateVersion` only when you
  intend to (read the comment in `configuration.nix` first), then `nix flake update`.
