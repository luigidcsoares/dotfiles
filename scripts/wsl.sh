# The goal of this script is to define utility functions for syncing
# projects between the Windows filesystem (FS) and the WSL
# filesystem. This sync is done via git, defining the folder that
# lives in the Windows FS as the "remote" repository (but not as a
# bare repo, as we still want to edit files there).
#
# Hereinafter, "remote" refers to the folder located in the Windows FS
# and "local" refers to the WSL FS.
#
# wsl-init: initialises a git repository in both filesystems
# wsl-pull: commit any changes in the remote, and then update the local repo
# wsl-push: push changes to the remote
#
# Both repos are initialised with a branch `wsl`, which must be used
# for syncing purposes.
#
# TODO:
# - Allow push to different branches
# - What if remote is in another dirty branch and we cannot switch to wsl?
#
# Additional utilities are available:
#
# wsl-publish: copies a file from the WSL FS to Windows (e.g., pdfs).

WINDOWS_HOME=$(wslpath "$(wslvar USERPROFILE)")

# Usage: wsl-init repo-name windows-subpath wsl-path
# where windows-subpath is a subpath inside your profile (e.g., inside C:/Users/username)
wsl-init() {
    local origin_path=$(pwd)
    local repo_name="$1"
    local windows_repo="${WINDOWS_HOME}/${2}/${repo_name}"
    local wsl_repo="${3}/${repo_name}"

    mkdir -p "$windows_repo"
    cd "$windows_repo"
    if [ ! -d ".git" ]; then
	git init
	
	echo "# Ignore all but .gitignore by default; whitelist as needed" > .gitignore
	echo "*" >> .gitignore
	echo "!.gitignore" >> .gitignore

	git add .gitignore
	git commit -m "[wsl-init] initial commit"
    fi
    git switch -c wsl
    git config receive.denyCurrentBranch updateInstead
    
    cd "$origin_path"
    mkdir -p "$wsl_repo"
    cd "$wsl_repo"
    if [ ! -d "${wsl_repo}/.git" ]; then
	git init
	
	echo "# Ignore all but .gitignore by default; whitelist as needed" > .gitignore
	echo "*" >> .gitignore
	echo "!.gitignore" >> .gitignore

	git add .gitignore
	git commit -m "[wsl-init] initial commit"
    fi
    git switch -c wsl

    git remote add -t wsl wsl "$windows_repo"
    git fetch
    git branch --set-upstream-to=wsl/wsl
}

# Usage: wsl-pull
wsl-pull() {
    local wsl_repo=$(pwd)
    local windows_repo=$(git remote get-url wsl)
    
    cd "$windows_repo" || return
    git switch wsl || return

    git add .
    git commit -m "[wsl-commit-remote] commiting previous work"

    cd "$wsl_repo" || return
    git pull
}

# Usage: wsl-push
wsl-push() {
    git push
}

# Usage: wsl-publish src-file windows-subpath
# where windows-subpath is a subpath inside your profile (e.g., inside C:/Users/username)
wsl-publish() {
    local src_path="$1"
    local src_file=$(basename $src_path)
    local windows_subpath="$2"
    local windows_path="${WINDOWS_HOME}/${windows_subpath}"
    local windows_file="${windows_path}/${src_file}"
    mkdir -p "$windows_path"
    cp -r "$src_path" "$windows_file"
}
