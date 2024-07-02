import os
import shutil
import argparse

def is_git_repo(path):
    return os.path.isdir(os.path.join(path, '.git'))

def find_git_repos(root_dir):
    git_repos = []
    for root, dirs, _ in os.walk(root_dir):
        if is_git_repo(root):
            git_repos.append(root)
            dirs[:] = []  # Don't traverse into subdirectories of a git repo
    return git_repos

def copy_commit_msg_hook(git_repos, hook_file, dry_run=False):
    for repo in git_repos:
        hooks_dir = os.path.join(repo, '.git', 'hooks')
        target_file = os.path.join(hooks_dir, 'commit-msg')

        if dry_run:
            print(f"cp {hook_file} {target_file}")
        else:
            shutil.copy(hook_file, target_file)
            print(f"Copied {hook_file} to {target_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Copy commit-msg hook to all Git repositories in a directory.')
    parser.add_argument('root_dir', help='The root directory to search for Git repositories.')
    parser.add_argument('hook_file', help='The commit-msg hook file to copy.')
    parser.add_argument('--dry-run', action='store_true', help='Perform a dry run without copying the files.')

    args = parser.parse_args()

    git_repos = find_git_repos(args.root_dir)
    copy_commit_msg_hook(git_repos, args.hook_file, args.dry_run)
