typeset -U fpath FPATH
typeset _worktrees_plugin_dir="${${(%):-%x}:A:h}"
fpath=("$_worktrees_plugin_dir/functions" $fpath)
unset _worktrees_plugin_dir

autoload -Uz bare-clone gwt _gwt_branch_name _gwt_post_create
