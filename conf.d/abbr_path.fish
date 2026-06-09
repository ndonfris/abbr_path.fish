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

# ---------------------------------------------------------------------------------------

# ┌──────────┐
# │ function │
# └──────────┘

# A simple function that creates an abbreviation that expands to a path. The
# abbreviation can be used anywhere in the command line and will expand to the
# specified path. The function also includes a help flag that provides usage
# information and examples.
function abbr_path -a name path -d 'creates an abbr named $argv[1], that allows path $argv[2] to be expanded anywhere'
    argparse --ignore-unknown --strict-longopts 'help' -- $argv || return 1

    if set -q _flag_help
        echo "abbr_path <ABBR_NAME> <PATH>"
        echo ""
        echo "SUMMARY:"
        echo "   Creates an abbreviation that expands to a path."
        echo ""
        echo "EXAMPLE:"
        echo "   • Create the abbreviation 'f_' that expands to '~/.config/fish/':"
        echo "     ❯ abbr_path f_ ~/.config/fish/"
        echo "   • Now, typing 'f_' anywhere will expand to '~/.config/fish/'."
        echo "     ❯ f_<TAB> "
        echo "     ❯ ~/.config/fish/<CURSOR> "
        echo ""
        echo "COMMON USE CASES:"
        echo "   • Fish folders"
        echo "     ❯ abbr_path f_ ~/.config/fish/"
        echo "     ❯ abbr_path f_f ~/.config/fish/functions/"
        echo "     ❯ abbr_path f_c ~/.config/fish/completions/"
        echo "     ❯ abbr_path f_cd ~/.config/fish/conf.d/"
        echo "     ❯ abbr_path f_cf ~/.config/fish/config.fish"
        echo ""
        echo "   • Common software configuration folders"
        echo "     ❯ abbr_path c_ ~/.config/"           
        echo "     ❯ abbr_path d_ ~/.dots/"             
        echo "     ❯ abbr_path n_ ~/.config/nvim/"
        echo "     ❯ abbr_path t_ ~/.tmux/"
        echo "     ❯ abbr_path t_cf ~/.tmux/tmux.conf"
        echo ""
        echo "   • PATH folders"
        echo "     ❯ abbr_path l_ ~/.local/"
        echo "     ❯ abbr_path l_s ~/.local/share/"
        echo "     ❯ abbr_path l_sb ~/.local/share/bin/"
        echo ""
        echo "   • Project folders or files"
        echo "     ❯ abbr_path r_ ~/repos/"
        echo "     ❯ abbr_path p_ ~/projects/"
        echo "     ❯ abbr_path w_ ~/work/"
        echo ""
        echo "   • Asset locations"
        echo "     ❯ abbr_path D_ ~/Downloads/"
        echo "     ❯ abbr_path P_ ~/Pictures/"
        echo "     ❯ abbr_path V_ ~/Videos/"
        echo ""  
        echo "SEE ALSO:"
        echo "   • https://github.com/ndonfris/abbr_path.fish"
        echo "   • https://fishshell.com/docs/current/cmds/abbr.html"
        return 0
    end

    # note: most folder expansions should end with trailing '/' character
    abbr -a $name --set-cursor --position=anywhere -- $path%
end
