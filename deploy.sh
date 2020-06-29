#!/bin/bash

# This is a deployment script for commiting the HTML documentation to the
# completely separate gh-pages branch.  It's probably quite unsafe.

code=0
branch=$(git symbolic-ref --short HEAD 2>/dev/null)

if [[ "$branch" != "master" ]]; then
    echo "you should be on master to do this" >&2
    exit 1
fi

make html || exit $?
echo

# Make sure to stash any changes before we swap branches.
stashed=$(git stash create)
if [[ -n "$stashed" ]]; then
    git stash store "$stashed"
    git restore --quiet .
fi

# We force-switch to the gh-pages branch, without modification to any files at
# all.  Since the directory structure is completely different and we want to
# ensure that the contents of _build/html is never changed, this is easier than
# checking out another commit.  Checkout _should_ be ok, since _build is in
# .gitignore, but this plumbing switch guarantees that no files will be touched.
git symbolic-ref HEAD refs/heads/gh-pages
# Reset the staging index, so nothing is staged (otherwise many changes will be
# after the switch).
git reset --quiet
# The --work-tree option to the primary `git` command makes the `add` operation
# behave as if we are in _build/html, and that that is the repository root.
git --work-tree="_build/html" add -A

if git diff --quiet --cached; then
    echo "No changes, nothing to commit."
else
    git commit --quiet -m "Update rendered documentation"
    if git push --quiet; then
        echo "Pushed successfully."
    else
        echo "Push failed." >&2
        code=8
    fi
fi

# Swap back to master.
git symbolic-ref HEAD refs/heads/master
git reset --quiet
if [[ -n "$stashed" ]]; then
    git stash pop --quiet
fi
exit $code
