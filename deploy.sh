#!/bin/bash

# This is a deployment script for commiting the HTML documentation to the
# completely separate gh-pages branch.  It's probably quite unsafe.

code=0
branch=$(git rev-parse --abbrev-ref HEAD)

if [[ "$branch" != "master" ]]; then
    echo "you should be on master to do this" >&2
    exit 1
fi

make html || exit $?
echo

stashed=$(git stash create)
if [[ -n "$stashed" ]]; then
    git stash store "$stashed"
    git restore --quiet .
fi

git symbolic-ref HEAD refs/heads/gh-pages
git reset --quiet
cd _build/html || {
    git symbolic-ref HEAD refs/heads/master
    git reset --quiet
    if [[ -n "$stashed" ]]; then
        git stash pop
    fi
    exit 3
}

git --work-tree=. add -A
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
git symbolic-ref HEAD refs/heads/master
git reset --quiet
cd ../.. || exit 4
if [[ -n "$stashed" ]]; then
    git stash pop --quiet
fi
exit $code
