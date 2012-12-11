# git-svn-hooks -- a helper for git-svn that allows hooks
#
# Version: 0.0.1
#
# Works with all Bourne compatible shells.
#
# Based on: https://raw.github.com/hkjels/.dotfiles/master/zsh/git-svn.zsh
#
# Author: rkitover: Rafael Kitover (rkitover@cpan.org)

git() {
    _root=$(command git rev-parse --show-toplevel);

    # check that this is a git-svn repo
    [ -d "$_root/.git/svn"  ] && [ x != x"$(ls -A "$_root/.git/svn/")" ] && _git_svn=1

    # otherwise just pass through to git
    if [ -z "$_git_svn" ]; then
        command git "$@"
        unset _root _git_svn
        return $?
    fi

    unset _git_svn

    # Expand git aliases
    _param_1=$1
    export _param_1

    _expanded="$( \
        command git config --get-regexp alias | sed -e 's/^alias\.//' | while read _alias _git_cmd; do \
            if [ "$_alias" = "$_param_1" ]; then \
                echo "$_git_cmd"; \
                break; \
            fi; \
        done \
    )"

    unset _param_1

    # check for !shell-command aliases
    case "$_expanded" in
    \!*)
        _expanded=$(echo "$_expanded" | sed -e 's/.//')
        shift
        eval "$_expanded \"\$@\""
        return $?
        ;;
    *)
        if [ -n "$_expanded" ]; then
            shift
            eval "git $_expanded \"\$@\""
            unset _expanded _root
            return $?
        fi
        ;;
    esac

    unset _expanded

    if [ "$1" != "svn" ]; then
        command git "$@"
        unset _root
        return $?
    else
        shift;
    fi

    # Pre hooks
    if [ -x "$_root/.git/hooks/pre-svn-$1" ]; then
        if ! "$_root"/.git/hooks/pre-svn-$1; then
            unset _root
            return $?
        fi
    fi

    # call git-svn
    command git svn "$@"
    _exit_val=$?

    # Post hooks
    if [ -x "$_root/.git/hooks/post-svn-$1" ]; then
        if ! "$_root"/.git/hooks/post-svn-$1; then
            unset _root _exit_val
            return $?
        fi
    fi

    unset _root

    sh -c "exit $_exit_val"
    unset _exit_val
    return $?
}
