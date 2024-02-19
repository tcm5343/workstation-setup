import os
import shutil
import sys
import requests
import stat

from pathlib import Path
from subprocess import Popen, PIPE


def __check_system_for_git():
    result = False
    try:
        cmd_output = str(Popen(['git', '--version'], stdout=PIPE).stdout.read().decode("utf-8"))
        if "git version" in cmd_output:
            result = True
    except OSError as e:
        print("git is either not installed or on the path, exiting")
        sys.exit()
    return result


def __create_dir(path: str):
    try:
        os.makedirs(path, exist_ok=True)
    except OSError as e:
        print(e)


# https://stackoverflow.com/a/1889686
def __remove_readonly(func, path, excinfo):
    os.chmod(path, stat.S_IWRITE)
    func(path)


def __clone_repo(repo: dict, destination_path: str):
    repo_folder = Path(destination_path) / repo['name']
    if os.path.exists(repo_folder):
        shutil.rmtree(repo_folder, onerror=__remove_readonly)
    print("started cloning:", repo['name'])
    Popen(['git', 'clone', repo['clone_url']], shell=False)


def main():
    __check_system_for_git()

    owner = None
    if sys.argv[1]:
        owner = sys.argv[1]
    else:
        print('error: you must include the user name of the account you want to copy')
        sys.exit()

    payload_json = requests.get(f'https://api.github.com/users/{owner}/repos').json()
    destination_path = Path(os.path.expanduser("~")) / "Desktop" / "github-backup" / payload_json[0]['owner']['login']

    __create_dir(destination_path)

    for repo in payload_json:
        os.chdir(destination_path)
        __clone_repo(repo, destination_path)


if __name__ == '__main__':
    main()
