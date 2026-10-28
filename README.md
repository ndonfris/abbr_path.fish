<div align="center"><h1><a alt-text="abbr_path.fish" href="#abbr_path.fish"><code>abbr_path.fish</code></a>

[![fish](https://img.shields.io/badge/shell-fish%20%E2%89%A5%203.6.0-4AAE9B?logo=gnometerminal&logoColor=white)](https://fishshell.com/) [![fisher](https://img.shields.io/badge/plugin-fisher-blue)](https://github.com/jorgebucaran/fisher) [![license](https://img.shields.io/badge/license-MIT-green)](LICENSE.md)

</h1>

![abbr_path.fish demo](assets/demo4-2.gif)
<b><sub><sup>Turn your most-used paths into abbreviations that expand _anywhere_ on the command line.</sup></sub></b>

</div>

## What is it?

`abbr_path.fish` is a tiny [fish shell](https://fishshell.com/) utility that wraps fish's native [`abbr`](https://fishshell.com/docs/current/cmds/abbr.html) to create **path abbreviations**.

Define a short alias once, and from then on it expands to a real filesystem path **anywhere** in a command, not just as a `cd` target.

```fish
abbr_path f_cf ~/.config/fish/config.fish
```

```console
❯ nvim f_cf⇥
❯ nvim ~/.config/fish/config.fish
```

It works as an argument to *any* command: `cat`, `cp`, `ls`, `nvim`, `source`, you name it.

## Why?

There are plenty of great tools for jumping *around* a filesystem (`z`, `zoxide`, `fzf`, …), and `abbr_path` can stand in for some of them, but that wasn't the motivation.

The goal is to make your **frequently-used files and directories available as arguments to any command**.

Instead of remembering (or `cd`-ing toward) a deep path, you type a short mnemonic and let fish expand it in place:

```console
❯ cat   f_cf⇥   →   cat   ~/.config/fish/config.fish
❯ ls    f_⇥     →   ls    ~/.config/fish/
❯ cp x  D_⇥     →   cp x  ~/Downloads/
```

Because it builds on `abbr --position=anywhere`, the expansion is **inline, visible, and editable** before you hit enter. There's no magic, no subshell, just fish doing what it already does well.

## Installation

#### Requirements

- [fish](https://fishshell.com/) `≥ 3.6.0`
- [fisher](https://github.com/jorgebucaran/fisher)

```fish
fisher install ndonfris/abbr_path.fish
```

<details>
<summary>Manual installation (without fisher)</summary>

```fish
curl -L https://raw.githubusercontent.com/ndonfris/abbr_path.fish/main/conf.d/abbr_path.fish \
  -o ~/.config/fish/conf.d/abbr_path.fish
```

</details>

## Usage

```fish
abbr_path <ABBR_NAME> <PATH>
```

| Argument      | Description                                                            |
| ------------- | ---------------------------------------------------------------------- |
| `<ABBR_NAME>` | The short alias you'll type. A trailing-marker like `_` reads nicely.  |
| `<PATH>`      | The directory or file the alias expands to.                            |

Run `abbr_path --help` for a built-in cheat sheet of examples.

### Creating a path abbreviation

<!-- GIF: typing `abbr_path f_ ~/.config/fish/` and then using it.
     Suggested file: assets/create.gif -->
<!-- ![Creating an abbreviation](assets/create.gif) -->

```fish
abbr_path f_ '~/.config/fish/'
# if you want to keep `~/.config/fish/` expansion exactly either 
#   >_ abbr f_ '~/.config/fish/'
#   >_ abbr f_ ~/.config/fish/ --tilde
```

Now `f_` expands to `~/.config/fish/` wherever it appears:

```console
❯ cd f_⇥
❯ cd ~/.config/fish/

❯ ls f_⇥
❯ ls ~/.config/fish/
```

### Files work too

<!-- GIF: expanding a file abbreviation into different commands.
     Suggested file: assets/files.gif -->
![File abbreviations](assets/abbr_path_f_.gif)

```fish
abbr_path f_cf '~/.config/fish/config.fish'
```

```console
❯ nvim f_cf⇥
❯ nvim ~/.config/fish/config.fish

❯ cat f_cf⇥
❯ cat ~/.config/fish/config.fish
```

### A naming convention that scales

A loose convention keeps a growing set of abbreviations memorable: a leading letter for the "area", `_` as the marker, and extra letters to drill in:

<!-- GIF: showing a handful of abbreviations in action across commands.
     Suggested file: assets/convention.gif -->
<!-- ![Naming convention](assets/convention.gif) -->

```fish
# fish config
abbr_path f_    '~/.config/fish/'
abbr_path f_f   '~/.config/fish/functions/'
abbr_path f_c   '~/.config/fish/completions/'
abbr_path f_cd  '~/.config/fish/conf.d/'
abbr_path f_cf  '~/.config/fish/config.fish'

# common config folders
abbr_path c_    '~/.config/'
abbr_path n_    '~/.config/nvim/'
abbr_path t_    '~/.tmux/'
abbr_path t_cf  '~/.tmux/tmux.conf'

# project locations
abbr_path r_    '~/repos/'
abbr_path p_    '~/projects/'
abbr_path w_    '~/work/'

# asset locations
abbr_path D_    '~/Downloads/'
abbr_path P_    '~/Pictures/'
abbr_path V_    '~/Videos/'
```

> [!TIP]
> Directory paths read best with a trailing `/`, since fish completes *into* them naturally,
> so `f_⇥` becomes `~/.config/fish/` ready for the next path segment.

### Also get a `cd` shortcut with `--add-cd-abbr`

Pass `--add-cd-abbr` and `abbr_path` creates a **second, companion abbreviation** for jumping straight into a directory, on top of the usual anywhere-expansion.

<!-- GIF: `cdf⇥` expanding to `cd ~/.config/fish/` and changing directory.
     Suggested file: assets/add-cd-abbr.gif -->
![cd shortcut](assets/cdf.gif)

```fish
abbr_path f_ '~/.config/fish/' --add-cd-abbr
```

You now have **two** abbreviations from that one line:

| Type    | Expands to             | Position   | Use it for                          |
| ------- | ---------------------- | ---------- | ----------------------------------- |
| `f_`    | `~/.config/fish/`      | *anywhere* | the path as an argument to any cmd  |
| `cdf_`  | `cd ~/.config/fish/`   | *command*  | hopping into the directory          |

```console
❯ cdf⇥
❯ cd ~/.config/fish/
```

**Behavior & rules:**

- The cd-abbr is named `cd` + your abbr name with **one trailing `_` stripped** (A name without a trailing `_`, e.g. `proj`, becomes `cdproj`.)

  | Input                                                         | `cd` abbr    | expansion                      |
  | ------------------------------------------------------------- | ------------ | ------------------------------ |
  | `abbr_path l_ '~/.local/' --add-cd-path`                      | `cdl`        | `cd ~/.local/`                 |
  | `abbr_path c_ '~/.config/' --abbr-cd-path`                    | `cdc`        | `cd ~/.config/`                |
  | `abbr_path c_f '~/.config/fish/' --abbr-cd-path`              | `cdc_f`      | `cd ~/.config/fish/`           |

- The `cd` prefix keeps it namespaced, so it won't collide with your `f_` path abbreviation or with real commands.
- It expands only in **command position**, so it acts like a normal command and never interferes with `f_` used mid-line.
- It's only meaningful for **directories**. Pointing it at a file produces a `cd` that errors at
  runtime, so reserve `--add-cd-abbr` for folder paths.

> [!TIP]
> Use the related `--tilde` flag to rewrite an absolute, `$HOME`-prefixed path back to `~` before
> it's stored. Handy if you build the path from `$PWD` or a completion:
>
> ```fish
> abbr_path f_ /home/you/.config/fish/ --tilde   # stored as ~/.config/fish/
> ```
>
> Or if you don't want to quote `PATH` argument
>
> ```fish
> abbr_path f_f ~/.config/fish/functions/ --tilde
> ```

### Making abbreviations permanent

`abbr_path` creates a session abbreviation. To keep your favorites across shells, add the `abbr_path` calls to a file that fish sources on startup, e.g. `~/.config/fish/config.fish` or a dedicated `~/.config/fish/conf.d/my_paths.fish`.

## How it works

Under the hood, `abbr_path` is a thin wrapper around fish's own abbreviation engine:

```fish
abbr -a $name --set-cursor --position=anywhere -- $path%
```

- `--position=anywhere` lets the abbreviation expand mid-command, not just as the first token.
- `--set-cursor` (`%` marker) drops your cursor right after the expanded path, ready to keep typing.

That's the whole trick: no background process, no shell hooks.

## Uninstalling

```fish
fisher remove ndonfris/abbr_path.fish
```

> [!IMPORTANT]
> Remove any saved `abbr_path` calls from your config **before** uninstalling, otherwise fish
> will try to run a command that no longer exists on startup. To find them:
>
> ```fish
> cd ~/.config/fish/ && grep -rE 'abbr_path' **/*.fish
> ```

## Contributing

Contributions are welcome! Please [open an issue](https://github.com/ndonfris/abbr_path.fish/issues) or submit a pull request.

<!-- The GIFs in this README are seeded from [`assets/demo.fish`](assets/demo.fish), which defines the -->
<!-- exact abbreviations shown above. Re-record them with: -->
<!---->
<!-- ```fish -->
<!-- source assets/demo.fish        # seed the demo abbreviations in a fresh shell -->
<!-- source assets/demo.fish --help # print the commands to type while recording -->
<!-- ``` -->

## See also

- [fish `abbr` documentation](https://fishshell.com/docs/current/cmds/abbr.html)
- [fisher](https://github.com/jorgebucaran/fisher)

## License

[MIT](LICENSE.md)
