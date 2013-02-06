git-svn-hooks
=============

This is a shell function for Bourne compatible shells (bash, zsh, ksh, ash,
etc.) that allows you to run hooks for git-svn commands (including through
aliases.)

Installation
------------

    mkdir ~/.sh
    mv git-svn.sh ~/.sh

In your shell startup file (e.g. ~/.bashrc) add the following:

    for f in ~/.sh/*.sh; do
        source $f
    done

Hooks
-----

You can make pre and post hooks, they go into .git/hooks/ in your project
directory. For example:

    .git/hooks/post-svn-dcommit
    .git/hooks/pre-svn-rebase

The hooks should be executable files (such as chmod +x shell scripts) that
return 0 on success and some other value on failure.

A pre hook that returns failure will stop the git-svn command from executing.

Sample Hooks
------------

There are some ready to use sample hooks in the `sample_hooks` directory, they
do a `git stash` before rebase, and do a stash and rebase before dcommit.

If you want to update a remote server on dcommit, edit the `update_server`
function in `post-svn-dcommit`.

Usage
-----

Use git and git-svn commands as usual, including aliases you have for them,
the git-svn hooks will run.

Configuration
-------------

You can set the `GIT_SVN_USERNAME` environment variable to issue a dummy svn
command to log in as that username for all `git svn` commands.

This is helpful if you frequently change svn usernames, since svn will use the
last one you logged in as.
