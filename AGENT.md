# AGENT.md

Personal dotfiles managed by [chezmoi](https://www.chezmoi.io) (v2.73). macOS (arm64) is the primary target; Linux is partially supported by the install script.

- Source dir: `~/.local/share/chezmoi` (this repo). Target: `~`.
- Remote: `git@github.com:abruneau/chezmoi.git`, branch `main`.
- No chezmoi config file (`~/.config/chezmoi/chezmoi.toml`), no `.chezmoidata`, no encryption, no password-manager templates.

## Layout

| Source | Target | What |
|---|---|---|
| `dot_zshrc`, `dot_antigenrc`, `dot_p10k.zsh` | `~/.zshrc`, ... | zsh + antigen + powerlevel10k |
| `dot_oh-my-zsh/custom/shared_functions.zsh` | `~/.oh-my-zsh/custom/` | shell functions |
| `dot_macos` | `~/.macos` | `defaults write` macOS prefs, sourced by install script |
| `dot_config/Brewfile` | `~/.config/Brewfile` | all packages (`brew bundle`) |
| `dot_config/aerospace/` | `~/.config/...` | tiling WM config (`.tmpl` but currently has no template logic) |
| `dot_config/sketchybar/` | `~/.config/...` | Lua bar config + C event providers (compiled by `helpers/install.sh`) |
| `dot_config/nvim/` | `~/.config/...` | AstroNvim config |
| `dot_config/raycast/` | `~/.config/...` | Raycast export + scripts |
| `private_Library/private_Preferences/...iterm2.plist` | `~/Library/Preferences/` | iTerm2 prefs (binary plist) |
| `.chezmoiscripts/` | (none) | scripts run by chezmoi, not copied to `~` |

### Scripts

- `run_once_after_install-packages.sh.tmpl`: first-apply bootstrap. Installs Homebrew, `brew bundle`, fonts, sketchybar helpers, sources `~/.macos`, sets global git user.
- `run_after_update.sh.tmpl`: runs after **every** apply: `brew update && brew bundle`. Slow, needs network.

## Source naming (chezmoi attributes)

Prefixes stack in this order: `private_`, `executable_`, `symlink_`, `dot_`. Suffix `.tmpl` = Go template.

- `dot_foo` → `.foo`
- `private_` → mode 0600/0700
- `executable_` → +x
- `symlink_foo` → symlink whose target is the file contents
- `run_once_` / `run_onchange_` / `run_` + `before_`/`after_` → scripts
- Templates use `{{ .chezmoi.os }}`, `{{ .chezmoi.arch }}`, etc. See `chezmoi data`.

Never rename files by hand to add/remove attributes; use `chezmoi chattr +executable ~/path` (or `-private`, `+template`, ...).

## Commands

```bash
chezmoi status                 # what apply would change (col1 = target vs last state, col2 = apply action)
chezmoi diff [~/target]        # diff of what apply WOULD DO. "-" = current home file, "+" = source
chezmoi managed                # list managed targets
chezmoi add ~/.foo             # start managing a file
chezmoi re-add [~/.foo]        # copy edited home file(s) back into source (non-templates only)
chezmoi merge ~/.foo           # 3-way merge when both sides changed
chezmoi edit ~/.foo            # edit source file for a target
chezmoi apply [~/.foo]         # write source → home (also runs scripts!)
chezmoi apply --exclude=scripts ~/.foo   # apply without triggering brew bundle
chezmoi cat ~/.foo             # render target content (templates evaluated)
chezmoi execute-template < f.tmpl        # test a template
chezmoi forget ~/.foo          # stop managing, keep home file
chezmoi doctor                 # sanity check
```

Commands take **target paths** (`~/.zshrc`), not source paths (`dot_zshrc`). `chezmoi diff .zshrc` from this dir fails with "not managed".

## Gotchas

- **Home has drifted from source.** `chezmoi status` shows `MM` on `.zshrc`, `.p10k.zsh`, `.antigenrc`, aerospace, nvim, iTerm plist: the live files are newer. A bare `chezmoi apply` overwrites those edits. Default direction when syncing is home → source (`re-add`), and confirm with the user before any `apply`.
- `apply` runs `run_after_update.sh` every time (brew update + bundle). Use `--exclude=scripts` unless the user wants it.
- Any non-dot file at repo root gets deployed to `~` unless listed in `.chezmoiignore` (this file is). Dot-prefixed source entries (`.git`, `.claude`) are ignored automatically.
- Binary files (iTerm plist, compiled sketchybar helpers, `.rayconfig`) produce noisy diffs; don't hand-edit them.
- The install script hardcodes a personal git email; this machine is also used for Tsuga work.
- Commit history is loose ("update", "update 20260312"); no convention to follow beyond keeping commits scoped.

## Workflow

1. Edit the live file in `~` (or `chezmoi edit`).
2. `chezmoi diff ~/file` to confirm.
3. `chezmoi re-add ~/file` (or `chezmoi add` for new files).
4. Commit in this repo. Ask before pushing.
