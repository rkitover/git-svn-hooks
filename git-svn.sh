# git-svn-hooks -- a helper for git-svn that allows hooks
#
# Version: 0.1.0
#
# Works with all Bourne compatible shells.
#
# Based on: https://raw.github.com/hkjels/.dotfiles/master/zsh/git-svn.zsh
#
# Author: rkitover: Rafael Kitover (rkitover@cpan.org)
#
# repo: https://github.com/rkitover/git-svn-hooks

git() {
    _root=$(command git rev-parse --show-toplevel 2>/dev/null);

    # check that this is a git-svn repo
    [ -n "$_root" ] && [ -d "$_root/.git/svn"  ] && [ x != x"$(ls -A "$_root/.git/svn/")" ] && _git_svn=1

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
        unset _expanded _root
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

    if [ -n "$GIT_SVN_USERNAME" ]; then
        echo yes | svn log -rHEAD --username $GIT_SVN_USERNAME $(cd $(command git rev-parse --show-toplevel); command git config svn-remote.svn.url) >/dev/null
        _svn_username="$GIT_SVN_USERNAME"
        unset GIT_SVN_USERNAME
    fi

    # Pre hooks
    if [ -x "$_root/.git/hooks/pre-svn-$1" ]; then
        if ! "$_root"/.git/hooks/pre-svn-$1; then
            if [ -n "$_svn_username" ]; then
                export GIT_SVN_USERNAME="$_svn_username"
                unset _svn_username
            fi
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
            if [ -n "$_svn_username" ]; then
                export GIT_SVN_USERNAME="$_svn_username"
                unset _svn_username
            fi
            unset _root _exit_val
            return $?
        fi
    fi

    if [ -n "$_svn_username" ]; then
        export GIT_SVN_USERNAME="$_svn_username"
        unset _svn_username
    fi

    unset _root

    return $_exit_val
}

# Copyright (c) 2013, Rafael Kitover
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice, this
# list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
