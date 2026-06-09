#   AUTHOR:     Nick Donfris | @ndonfris
#  LICENSE:     MIT
#  VERSION:     1.0.0
#     REPO:     https://github.com/ndonfris/abbr_path.fish

# ┌─────────┐
# │ Summary │
# └─────────┘
# `abbr_path` creates an abbreviation that expands to a path
#   Usage:   `abbr_path <abbr_name> <path>`
#   Example: 
#             1. `abbr_path f_ ~/.config/fish/`
#
#             ❯ cd f_<TAB>
#             ❯ cd ~/.config/fish/<CURSOR>
#
#             ❯ ls f_<TAB>
#             ❯ ls ~/.config/fish/<CURSOR>
#
#             2. `abbr_path f_cf ~/.config/fish/config.fish` 
#
#             ❯ nvim f_cf<TAB>
#             ❯ nvim ~/.config/fish/config.fish
#
#             ❯ cat f_cf<TAB> 
#             > cat ~/.config/fish/config.fish


# ---------------------------------------------------------------------------------------

# ┌───────────────────┐
# │ install/uninstall │
# └───────────────────┘
#
# • a normal install w/ fisher:
#
#     ❯ fisher install ndonfris/abbr_path.fish
#
# • fisher uninstall:
#
#     ❯ fisher remove ndonfris/abbr_path.fish
#
#   NOTE: make sure you remove the abbr_path abbreviations before uninstalling,
#         otherwise they will remain in your config and cause error)
#  
#     ❯ cd ~/.config/fish/ && grep -E 'abbr_path' **/*.fish
#
# ---------------------------------------------------------------------------------------

# ┌────────────┐
# │ completion │
# └────────────┘

# Disable default file completions
complete -c abbr_path -f
# Second argument: complete directories (will automatically include trailing /)
complete -c abbr_path -n 'test (count (commandline -opc)) -ge 2' -a '(__fish_complete_directories)'
complete -c abbr_path -n 'test (count (commandline -opc)) -ge 3' -l tilde -d 'use tilde for home directory path expansion'
complete -c abbr_path -n 'test (count (commandline -opc)) -ge 3' -l add-cd-abbr -d'create a cd$name abbr'
complete -c abbr_path -l help -d 'show help message'

# ---------------------------------------------------------------------------------------

# ┌──────────┐
# │ function │
# └──────────┘

# A simple function that creates an abbreviation that expands to a path. The
# abbreviation can be used anywhere in the command line and will expand to the
# specified path. The function also includes a help flag that provides usage
# information and examples.
function abbr_path -d 'creates an abbr named $argv[1], that allows path $argv[2] to be expanded anywhere'
    argparse --ignore-unknown --strict-longopts 'help' 'add-cd-abbr' 'tilde' -- $argv || return 1

    set -l name $argv[1]
    set -l path $argv[2]

    if set -q _flag_help
        echo "abbr_path <ABBR_NAME> <PATH> [...OPTIONS]"
        echo ""
        echo "SUMMARY:"
        echo "   Creates an abbreviation that expands to a path."
        echo ""
        echo "OPTIONS:"
        echo "   --help         show help message"
        echo "   --add-cd-abbr  creates a abbr for 'cd\$name' to expand to `cd \$path`"
        echo "   --tilde        use tilde for absolute path passed in"
        echo ""
        echo "EXAMPLE:"
        echo "   • Create the abbreviation 'f_' that expands to '~/.config/fish/':"
        echo "     ❯ abbr_path f_ '~/.config/fish/' --add-cd-abbr"
        echo "   • Now, typing 'f_' anywhere will expand to '~/.config/fish/'."
        echo "     ❯ f_<TAB> "
        echo "     ❯ ~/.config/fish/<CURSOR> "
        echo "    • Similiarly, typing 'cdf_' will expand to 'cd ~/.config/fish/'"
        echo "     ❯ cdf_<TAB>"
        echo "     ❯ cd ~/.config/fish/<CURSOR>"
        echo ""
        echo "COMMON USE CASES:"
        echo "   • Fish folders"
        echo "     ❯ abbr_path f_ '~/.config/fish/' --add-cd-abbr"
        echo "     ❯ abbr_path f_cf '~/.config/fish/config.fish'"
        echo "     ❯ abbr_path f_f '~/.config/fish/functions/'"
        echo "     ❯ abbr_path f_c '~/.config/fish/completions/'"
        echo "     ❯ abbr_path f_cd '~/.config/fish/conf.d/'"
        echo "     ❯ abbr_path f_f,c '~/.config/fish/{functions,completions}/'"
        echo "     ❯ abbr_path f_c,f '~/.config/fish/{functions,completions}/'"
        echo ""
        echo "   • Common software configuration folders"
        echo "     ❯ abbr_path c_ '~/.config/' --add-cd-abbr"           
        echo "     ❯ abbr_path d_ '~/.dots/' --add-cd-abbr"             
        echo "     ❯ abbr_path n_ '~/.config/nvim/' --add-cd-abbr"
        echo "     ❯ abbr_path t_ '~/.tmux/' --add-cd-abbr"
        echo "     ❯ abbr_path t_cf '~/.tmux/tmux.conf'"
        echo ""
        echo "   • PATH folders"
        echo "     ❯ abbr_path l_ '~/.local/'"
        echo "     ❯ abbr_path l_s '~/.local/share/'"
        echo "     ❯ abbr_path l_sb '~/.local/share/bin/'"
        echo ""
        echo "   • Project folders or files"
        echo "     ❯ abbr_path r_ '~/repos/'"
        echo "     ❯ abbr_path p_ '~/projects/'"
        echo "     ❯ abbr_path w_ '~/work/'"
        echo ""
        echo "   • Asset locations"
        echo "     ❯ abbr_path D_ '~/Downloads/' --add-cd-abbr"
        echo "     ❯ abbr_path P_ '~/Pictures/' --add-cd-abbr"
        echo "     ❯ abbr_path V_ '~/Videos/' --add-cd-abbr"
        echo ""  
        echo "SEE ALSO:"
        echo "   • https://github.com/ndonfris/abbr_path.fish"
        echo "   • https://fishshell.com/docs/current/cmds/abbr.html"
        return 0
    end
    set -ql _flag_tilde && string match -rq "^$HOME" "$path" 
    and set path (string replace -r -- "^$HOME" '~' $path)

    # note: most folder expansions should end with trailing '/' character
    abbr -a $name --set-cursor --position=anywhere -- $path%

    if set -ql _flag_add_cd_abbr
        string match -rq '^(.*)\_$' "$name"
        and set -l name (string trim --right --chars='_' "$name")
        abbr -a cd$name --set-cursor -- cd $path%
    end
end
