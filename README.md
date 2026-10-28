<div align="center"><h1><a alt-text="abbr_path.fish" href="#abbr_path.fish"><code>abbr_path.fish</code></a>

[![fish](https://img.shields.io/badge/shell-fish%20%E2%89%A5%204.1.0-4AAE9B?logo=gnometerminal&logoColor=white)](https://fishshell.com/) [![fisher](https://img.shields.io/badge/plugin-fisher-blue)](https://github.com/jorgebucaran/fisher) [![license](https://img.shields.io/badge/license-MIT-green)](LICENSE.md)

</h1>

![abbr_path.fish demo](assets/demo4-2.gif)
<b><sub><sup>Turn your most-used paths into abbreviations that expand _anywhere_ on the command line.</sup></sub></b>

</div>

<!-- NOTE:    tab character in examples is:  ⇥  -->
<!-- NOTE: cursor character in examples is:  █  -->
## What is it?

`abbr_path.fish` is a tiny [fish shell](https://fishshell.com/) utility that wraps fish's native [`abbr`](https://fishshell.com/docs/current/cmds/abbr.html) to create **path abbreviations**.

Define a short alias once, and from then on it expands to a real filesystem path **anywhere** in a command.

```fish
abbr_path f_cf ~/.config/fish/config.fish
```

```console
❯ nvim f_cf⇥
❯ nvim ~/.config/fish/config.fish█
```

It works as an argument to *any* command: `cat`, `cp`, `ls`, `nvim`, `source`, you name it.

## Why?

There are plenty of great tools for jumping *around* a filesystem (`z`, `zoxide`, `fzf`, …), and `abbr_path` can stand in for some of them, but that wasn't the motivation.

The goal is to make your **frequently-used files and directories available as arguments to any command**.

Instead of remembering (or `cd`-ing toward) a deep path, you type a short mnemonic and let fish expand it in place:

```console
❯ cat   f_cf⇥   →   cat   ~/.config/fish/config.fish█
❯ ls    f_⇥     →   ls    ~/.config/fish/█
❯ cp x  D_⇥     →   cp x  ~/Downloads/█
```

Because it builds on `abbr --position=anywhere`, the expansion is **inline, visible, and editable** before you hit enter. There's no magic, no subshell, just fish doing what it already does well.

## Installation

#### Requirements

- [fish](https://fishshell.com/) `≥ 4.1.0`
- [fisher](https://github.com/jorgebucaran/fisher)

```fish
fisher install ndonfris/abbr_path.fish
```

<details>
<summary>Manual installation (without fisher)</summary>

```fish
curl -L https://raw.githubusercontent.com/ndonfris/abbr_path.fish/master/conf.d/abbr_path.fish \
  -o ~/.config/fish/conf.d/abbr_path.fish
```

</details>

## Usage

```fish
abbr_path <ABBR_NAME> <PATH> [OPTIONS]
```

<br/>

| Argument      | Description                                                            |
| ------------- | ---------------------------------------------------------------------- |
| `<ABBR_NAME>` | The short alias you'll type. A trailing-marker like `_` reads nicely.  |
| `<PATH>`      | The directory or file the alias expands to.                            |

<br/>

| Options                                        | Description                                                                                                  |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| [`--tilde`](#tilde)                            | Create the abbr with `$HOME` replaced in `<PATH>` using a tilde (`~`)                                        |
| [`--add-cd-abbr [STR?]`](#add-cd-abbr)         | Create an added alias prefixed via `cd<ABBR_NAME>` with any trailing `_` removed                             |
| [`--add-editor-abbr [STR?]`](#add-editor-abbr) | Create an added alias prefixed via `$EDITOR<ABBR_NAME>` with any trailing `_` removed                        |
| [`--warn-missing-slash`](#warn-missing-slash)  | Show a warning when `abbr_path` is called with <PATH> directory missing trailing `/`                         |

<br/>

| Universal Variables                                 | Description                                                                                                  |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| [`ABBR_PATH_EDITOR`](#abbr_path_editor)             | Override what `--add-editor-path` abbr prefix value is used for `$EDITOR`                                    |
| [`ABBR_PATH_DEFAULT_OPTS`](#abbr_path_default_opts) | Options to pass to every `abbr_path` function call                                                           |

<br/>

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
❯ cd ~/.config/fish/█

❯ ls f_⇥
❯ ls ~/.config/fish/█
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
❯ nvim ~/.config/fish/config.fish█

❯ cat f_cf⇥
❯ cat ~/.config/fish/config.fish█
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

### Prevent PATH expansion with `--tilde` flag <a id="tilde"/>

Use the related `--tilde` flag to rewrite an absolute, `$HOME`-prefixed path back to `~` before it's stored.

**Handy if you:**

- build the path from `$PWD` or a completion
- don't want to quote `<PATH>` arguments

```fish
abbr_path f_ /home/you/.config/fish/ --tilde   # stored as ~/.config/fish/
```

```console
❯ f_⇥
❯ ~/.config/fish/█
```

### Get an `$EDITOR` shortcut with `--add-editor-abbr` <a id='add-editor-abbr'></a>

Pass `--add-editor-abbr` to `abbr_path`, when `<PATH>` argument is a file, and you want **extra companion abbreviations** added for opening the editor straight into the file.

> [!WARNING]
> Must either have `$ABBR_PATH_EDITOR` or `$EDITOR` set

```fish
# assume `$EDITOR` is set to `nvim`
abbr_path f_cf '~/.config/fish/config.fish' --add-editor-abbr --add-editor-abbr='f'
```

```console
❯ nvimf_cf⇥
❯ nvim ~/.config/fish/config.fish█

❯ nvimf⇥
❯ nvim ~/.config/fish/config.fish█
```

**Behavior & rules:**

- The editor-abbr is named `$EDITOR` + your abbr name with **one trailing `_` stripped**
- One or more `--add-editor-abbr` switches can be used.
  - when `--add-editor-abbr` is seen without a value given, it assumes that it should use the abbr name (with any trailing `_`)
  - when `--add-editor-abbr=VALUE` is seen, an `abbr nvimVALUE` is created expanding to `nvim PATH`
- It expands only in **command position**, so it acts like a normal command and never interferes with `f_` used mid-line.

### Get a `cd` shortcut with `--add-cd-abbr` <a id='add-cd-abbr'></a>

Pass `--add-cd-abbr` and `abbr_path` creates **extra, companion abbreviation** for jumping straight into a directory, on top of the usual anywhere-expansion.

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
| `cdf`   | `cd ~/.config/fish/`   | *command*  | hopping into the directory          |

```console
❯ cdf⇥
❯ cd ~/.config/fish/█
```

**Behavior & rules:**

- The cd-abbr is named `cd` + your abbr name with **one trailing `_` stripped** (A name without a trailing `_`, e.g. `proj`, becomes `cdproj`.)
- One or more `--add-cd-abbr` switches can be used.
  - when `--add-cd-abbr` is seen without a value given, it assumes that it should use the abbr name (with any trailing `_`)
  - when `--add-cd-abbr=VALUE` is seen, an `abbr cdVALUE` is created expanding to `cd PATH`
- The `cd` prefix keeps it namespaced, so it won't collide with your `f_` path abbreviation or with real commands.
- It expands only in **command position**, so it acts like a normal command and never interferes with `f_` used mid-line.
- It's only meaningful for **directories**. Pointing it at a file produces a `cd` that errors at runtime, so reserve `--add-cd-abbr` for folder paths.

### Using `--warn-missing-slash` <a id='warn-missing-slash' />

This flag is generally meant to be used in the [`$ABBR_PATH_DEFAULT_OPTS`](#abbr_path_default_opts) universal variable.

```fish
set -Ux ABBR_PATH_DEFAULT_OPTS --warn-missing-slash
```

```console
❯ abbr_path f_f '~/.config/fish/functions'    # WARNING!
❯ abbr_path f_f '~/.config/fish/functions/'   # No warning.
❯ abbr_path f_cf '~/.config/fish/config.fish' # No warning. <PATH> is a file
```

### Using Universal Variables

Set these universal variables in an interactive session, and they will be used across every `abbr_path` call.

#### `ABBR_PATH_EDITOR` <a id='abbr_path_editor' />

The editor name to prepend the `<ABBR_NAME>` or `--add-editor-abbr`

**EXAMPLE:**

```console
❯ # interactive session
❯ set -Ux ABBR_PATH_EDITOR emacs

❯ abbr_path f_cf '~/.config/fish/config.fish' --add-editor-abbr=f --add-editor-abbr=F

❯ emacsf⇥
❯ emacs ~/.config/fish/config.fish█

❯ emacsF⇥
❯ emacs ~/.config/fish/config.fish█
```

#### `ABBR_PATH_DEFAULT_OPTS` <a id='abbr_path_default_opts' />

The arguments to append to the end of `$argv` for every `abbr_path` function call.

This variable can be useful to avoid passing `--tilde` for every `abbr_path` usage, if you don't want to quote the `<PATH>` argument.

You can also enable warnings for `abbr_path` locations that didn't include trailing `/` for folders.

```console
❯ # interactive session
❯ set -Ux ABBR_PATH_DEFAULT_OPTS --tilde --warn-missing-slash

❯ abbr_path f_cf ~/.config/fish  # WARNING
❯ abbr_path f_cf ~/.config/fish/ # NO WARNING
```

### Making abbreviations permanent

`abbr_path` creates a session abbreviation. To keep your favorites across shells, add the `abbr_path` calls to a file that fish sources on startup, e.g. `~/.config/fish/config.fish` or a dedicated `~/.config/fish/conf.d/my_paths.fish`.

<details>
<summary> Full example: <code>~/.config/fish/conf.d/abbr_paths.fish</code></summary>

```fish
## All definitions `abbr` usages from fisher plugin `ndonfris/abbr_path.fish`
## 
## Located in ~/.config/fish/conf.d/abbr_paths.fish
##
status is-interactive || return

# OPTIONAL: function to edit this file
function abbr_pathed -d 'function to edit `conf.d/abbr_paths.fish`'
  $EDITOR ~/.config/fish/conf.d/abbr_paths.fish
  and source  ~/.config/fish/conf.d/abbr_paths.fish 
end

# fish
abbr_path f_   '~/.config/fish/' --add-cd-abbr
abbr_path f_f  '~/.config/fish/functions/' --add-cd-abbr
abbr_path f_f  '~/.config/fish/completions/' --add-cd-abbr
abbr_path f_cd '~/.config/fish/conf.d/' --add-cd-abbr
abbr_path f_cf '~/.config/fish/config.fish'

# nvim
abbr_path n_ ~/.config/nvim/ --add-cd-abbr --tilde
abbr_path n_l ~/.config/nvim/lua/ --add-cd-abbr --tilde
abbr_path n_n ~/.config/nvim/init.lua --tilde

# ~/.config
abbr_path c_ '~/.config/' --abbr-cd-abbr

# Other
abbr_path D_ '~/Downloads/' --add-cd-abbr
abbr_path P_ '~/Pictures/' --add-cd-abbr
abbr_path V_ '~/Videos/' --add-cd-abbr
abbr_path R_ '~/repos/' --add-cd-abbr
```

</details>

## How it works

Under the hood, `abbr_path` is a thin wrapper around fish's own abbreviation engine:

```fish
abbr -a $name --set-cursor --position=anywhere -- $path%
```

- `--position=anywhere` lets the abbreviation expand mid-command, not just as the first token.
- `--set-cursor` (`%` marker) drops your cursor right after the expanded path, ready to keep typing.

That's the whole trick: no background process, no shell hooks.

## Uninstalling

<details>
<summary><code>fisher</code> installation</summary>

```fish
fisher remove ndonfris/abbr_path.fish
```

</details>

<details>
<summary><code>curl</code> installation</summary>

```fish
emit abbr_path_uninstall
rm -f ~/.config/fish/conf.d/abbr_path.fish
```

</details>

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
