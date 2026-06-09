# `abbr_path.fish`

A very simple [fish shell](https://fishshell.com/) utility for creating [`abbr`](https://fishshell.com/docs/current/cmds/abbr.html) commands for files/paths that you often use.

## Why?

While their are many ways to jump around a file-system, I've found that using `abbr --position=anywhere` is much more generally useful for a variety of use-cases.

Their are a plethora of existing tooling for jumping around a file-system easy, and while this plugin can be used as a replacement for those, that was not the original motivation for this plugin.

Instead, my primary use case for this plugin is to have my common files/paths available to arguments of any command. For example, to access my `~/.config/fish/config.fish` file, I can simply type `f_cf` anywhere in a command, and it will be expanded to `~/.config/fish/config.fish`. This is much more convenient than having to remember the exact path or using a more complex tool to navigate to the file.

## Installation

Requirements:

- [fish](https://fishshell.com/) (version 3.6.0 or higher)
- [fisher](https://github.com/jorgebucaran/fisher)

```fish
fisher install ndonfris/abbr_path.fish
```

<details>
<summary>Manual installation</summary>

```fish
curl -L https://raw.githubusercontent.com/ndonfris/abbr_path.fish/main/abbr_path.fish -o ~/.config/fish/conf.d/abbr_path.fish
```

</details>

## Usage

<!---->

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License
[MIT License](LICENSE.md)
