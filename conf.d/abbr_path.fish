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

# ┌─────────────────────┐
# │ universal variables │
# └─────────────────────┘

# set -Ux ABBR_PATH_EDITOR 'nvim'
# set -Ux ABBR_PATH_DEFAULT_OPTS --tilde --warn-folders-missing-slash

# ---------------------------------------------------------------------------------------

# ┌────────────┐
# │ completion │
# └────────────┘

# Disable default file completions
complete -c abbr_path -f
# Second argument: complete directories (will automatically include trailing /)
complete -c abbr_path -n 'test (count (commandline -opc)) -ge 2' -a '(__fish_complete_directories)'
complete -c abbr_path -n 'test (count (commandline -opc)) -ge 3' -l tilde -d 'use tilde for home directory path expansion'
complete -c abbr_path -n 'test (count (commandline -opc)) -ge 3' -l add-cd-abbr -d 'create a cd$name abbr'
complete -c abbr_path -n 'test (count (commandline -opc)) -ge 3' -l add-editor-abbr -d 'create a $EDITOR$name abbr'
complete -c abbr_path -n 'test (count (commandline -opc)) -ge 3' -l warn-missing-slash -d 'show a warning if `abbr_path <NAME> <PATH>` PATH was missing trailing `/`' 
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

    if set -q ABBR_PATH_DEFAULT_OPTS
        for arg in $ABBR_PATH_DEFAULT_OPTS
            not contains $arg $argv
            and set -fa argv $arg
        end
    end

    argparse --ignore-unknown --strict-longopts 'help' 'add-cd-abbr=*' 'add-editor-abbr=*' 'tilde' 'warn-missing-slash' -- $argv || return 1

    set -l name $argv[1]
    set -l path $argv[2]

    if set -q _flag_help
        echo "abbr_path <ABBR_NAME> <PATH> [...OPTIONS]"
        echo ""
        echo "SUMMARY:"
        echo "   Creates an abbreviation that expands to a path."
        echo ""
        echo "OPTIONS:"
        echo "   --help                    show help message"
        echo ""
        echo "   --add-cd-abbr [name?]     creates a abbr for 'cd\$name' to expand to `cd \$path`"
        echo "                             [name?] value is optional - if none is given then use <ABBR_NAME>"
        echo ""
        echo "   --add-editor-abbr [name?] creates a abbr for '\$EDITOR\$name' to expand to `\$EDITOR\$path`"
        echo "                             [name?] value is optional - if none is given then use <ABBR_NAME>"
        echo ""
        echo "   --tilde                   use tilde for absolute path passed in"
        echo ""
        echo "   --warn-missing-slash      ensure folders end with trailing '/'"
        echo ""
        echo "UNIVERSAL VARIABLES:"
        echo "   \$ABBR_PATH_EDITOR       prefix value to use \$EDITOR for flag '--add-editor-abbr'"
        echo ""
        echo "   \$ABBR_DEFAULT_OPTS      flags to pass to every every `abbr_path` call"
        echo "                            (IF USED AT ALL, TYPICALLY: `--tilde --warn-missing-slash`)"
        echo ""
        echo "EXAMPLE:"
        echo "   • Create the abbreviation 'f_' that expands to '~/.config/fish/':"
        echo "     ❯ abbr_path f_ '~/.config/fish/' --add-cd-abbr"
        echo ""
        echo "   • Now, typing 'f_' anywhere will expand to '~/.config/fish/'."
        echo "     ❯ f_<TAB> "
        echo "     ❯ ~/.config/fish/<CURSOR> "
        echo ""
        echo "   • Similiarly, typing 'cdf_' will expand to 'cd ~/.config/fish/'"
        echo "     ❯ cdf_<TAB>"
        echo "     ❯ cd ~/.config/fish/<CURSOR>"
        echo ""
        echo "   • Using both the Universal Variables"
        echo "     ❯ # interactive session"
        echo "     ❯ set -Ux ABBR_PATH_EDITOR nvim"
        echo "     ❯ set -Ux ABBR_DEFAULT_OPTS --warn-missing-slash --tilde"
        echo ""
        echo "     ❯ abbr_path f_cf ~/.config/fish/config.fish --add-editor-abbr=f"
        echo "       no quoting needed because --tilde"
        echo ""
        echo "     ❯ nvimf<TAB> "
        echo "     ❯ nvim ~/.config/fish/config.fish<CURSOR> "
        echo ""
        echo "     ❯ nvimf_cf<TAB> "
        echo "     ❯ nvim ~/.config/fish/config.fish<CURSOR> "
        echo ""
        echo "     ❯ abbr_path f_ ~/.config/fish"
        echo "       WARNING: '~/.config/fish' is missing trailing '/'"
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
        echo "     ❯ abbr_path t_cf '~/.tmux/tmux.conf' --add-editor-abbr"
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
        echo "HELPFUL KEYBINDING:"
        echo "     ❯ bind / expand-abbr or self-insert"
        echo "     ❯ bind space self-insert expand-abbr"
        echo ""  
        echo "SEE ALSO:"
        echo "   • https://github.com/ndonfris/abbr_path.fish"
        echo "   • https://fishshell.com/docs/current/cmds/abbr.html"
        return 0
    end


    # add '/' if $path doesn't end with it
    if test -d $path && not string match -rq -- '^.*/$' "$path"
        set -ql _flag_warn_missing_slash
        and echo "Warning: `abbr_path $name $path` missing trailing '/'" >&2

        set path "$path/"
    end

    set -ql _flag_tilde && string match -rq "^$HOME" "$path" 
    and set path (string replace -r -- "^$HOME" '~' $path)

    # note: most folder expansions should end with trailing '/' character
    abbr -a $name --set-cursor --position=anywhere -- $path%

    if set -ql _flag_add_cd_abbr
        # trim right trailing '_' if name ends with it
        string match -rq '^(.*)\_$' "$name"
        and set -l name (string trim --right --chars='_' "$name")

        set fixed_names
        for fixed_name in $name $_flag_add_cd_abbr
            if not contains $fixed_name $fixed_names && test -n "$fixed_name"
                set -a fixed_names $fixed_name
            end
        end

        for fixed_name in $fixed_names
            abbr -a cd$fixed_name --set-cursor -- cd $path%
        end
    end

    if set -ql _flag_add_editor_abbr
        # trim right trailing '_' if name ends with it
        string match -rq '^(.*)\_$' "$name"
        and set -l name (string trim --right --chars='_' "$name")

        set -l fixed_names
        for fixed_name in $name $_flag_add_editor_abbr
            if not contains $fixed_name $fixed_names && test -n "$fixed_name"
                set -a fixed_names $fixed_name
            end
        end

        set -q ABBR_PATH_EDITOR && not test -n "$ABBR_PATH_EDITOR" && set -f EDITOR $ABBR_PATH_EDITOR
        if not set -q EDITOR || test -n "$EDITOR"
            set -f EDITOR nvim
        end

        for fixed_name in $fixed_names
            abbr -a $EDITOR$fixed_name --set-cursor -- $EDITOR $path%
        end
    end
end

function _abbr_path_uninstall --on-event abbr_path_uninstall
    set -eU ABBR_PATH_EDITOR
    set -eU ABBR_DEFAULT_OPTS
end
