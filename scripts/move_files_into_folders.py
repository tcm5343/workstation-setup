import os
import json
from typing import List
import re

import ffmpeg
import hashlib
import shutil

# yt_dlp_dir = '/home/miller/Desktop/testing'
yt_dlp_dir = '/home/miller/dev/workstation-setup/'


def move_file_to_directory(source_file, destination_directory, filename):
    os.makedirs(destination_directory, exist_ok=True)
    destination_file = os.path.join(destination_directory, filename)
    shutil.move(source_file, destination_file)


def sanitize(input: str):
    # sanitize file system (titles are still accessible via metadata on the file)
    invalid_chars = ['NUL', '\\', '/', ':', '*', '?', '"', '<', '>', '|']
    for invalid_char in invalid_chars:
        input = input.replace(invalid_char, '_')

    input = input.strip().rstrip('.') # remove whitespace and then any trailing .
    input = input[:255] # file name limit for NTFS is 255
    return input


def move_files_to_sub_folders():
    for subdir, dirs, files in os.walk(yt_dlp_dir):
        level = subdir.count(os.sep) - yt_dlp_dir.count(os.sep)
        if level > 1:
            continue
        # if subdir
        for file in files:
            filePath = os.path.join(subdir, file)
            if filePath.endswith('.mkv'):
                try:
                    videoMetadata = ffmpeg.probe(filePath)
                    videoTitle = videoMetadata['format']['tags']['title']
                    sanitizedTitle = sanitize(videoTitle)

                    newFolderName = f'{videoMetadata["format"]["tags"]["DATE"]} - {sanitizedTitle}'
                    videoExt = file[file.rfind('.'):]
                    newFileName = sanitizedTitle + videoExt

                    if os.path.dirname(subdir) == yt_dlp_dir:
                        move_file_to_directory(
                            filePath,
                            os.path.join(subdir, newFolderName),
                            newFileName
                        )
                    else:
                        print(f'skipping - {file} already in a sub dir')
                except Exception as err:
                    print(f'err - {filePath} \n{err}')


def get_files_at_level(level: int):
    res = []
    for subdir, dirs, files in os.walk(yt_dlp_dir):
        actualLevel = subdir.count(os.sep) - yt_dlp_dir.count(os.sep)
        if actualLevel > level:
            continue
        # if subdir
        for file in files:
            filePath = os.path.join(subdir, file)
            if not filePath.endswith(('.log', '.zip', '.json')):
                # print(filePath)
                res.append(filePath)
    return res


def map_id_to_data():
    res = {}
    for subdir, dirs, files in os.walk(yt_dlp_dir):
        # level = subdir.count(os.sep) - yt_dlp_dir.count(os.sep)
        # if level > 1:
        #     continue
        # if subdir
        for file in files:
            filePath = os.path.join(subdir, file)
            if filePath.endswith('.mkv'):
                try:
                    videoMetadata = ffmpeg.probe(filePath)
                    videoTitle = videoMetadata['format']['tags']['title']
                    videoUrl = videoMetadata['format']['tags']['PURL']

                    res[videoTitle] = {
                        'id': videoUrl[videoUrl.rfind('?v=')+3:],
                        'path': filePath,
                    }
                except Exception as err:
                    print(f'err - {filePath} \n{err}')
    return res


def get_all_extensions():
    extensions = set()
    for subdir, dirs, files in os.walk(yt_dlp_dir):
        for file in files:
            extensions.add(file[file.rfind('.'):])
    return extensions


def parse_id_from_file_names(fileNames: List):
    ids = []
    video_id_pattern = re.compile(r'(?<= - )([A-Za-z0-9_-]+)(?=\.)')
    for file in fileNames:
        matches = video_id_pattern.search(file)
        if matches:
            video_id = matches.group(0)
            ids.append(video_id)
    return ids


if __name__ == "__main__":
    # ext = get_all_extensions()
    # print(ext)

    # for subdir, dirs, files in os.walk(yt_dlp_dir):
    #     for file in files:
    #         filePath = os.path.join(subdir, file)
    #         ext = file[file.rfind('.'):]
    #         if ext not in ['.mkv', '.log', '.zip']:
    #             try:
    #                 ffmpeg.probe(filePath)
    #                 # print(json.dumps(, indent=2))
    #                 print('worked on:', filePath)
    #             except Exception:
    #                 print('err on:', filePath)
    #             # print(file)

    leftover_files = get_files_at_level(1)
    leftover_ids = parse_id_from_file_names(leftover_files)

    # deleted = {}
    # with open('/media/miller/Primary/yt-dlp/output.txt', "r") as file:
    #     for line in file:
    #         id, status = line.strip().split(',')
    #         deleted[id] = status

    ids = []
    with open('/media/miller/Primary/yt-dlp/archive.log', "r") as file:
        for line in file:
            _, id = line.strip().split(' ')
            ids.append(id+'\n')
    with open('/media/miller/Primary/yt-dlp/channels.txt', "w") as file:
        file.writelines(ids)

    # for id in leftover_ids:
    #     if id in deleted.keys():
            # print(id)
    set_ids = set(leftover_ids)
    for id in set_ids:
        print(id)

    # mapped_data = map_id_to_data()
    # print('here')
    # for file in leftover_files:
    #     a=file[:file.find('.')][file.rfind('/')+1:]
    #     id = a[a.rfind("-")+2:]
    #     if id in mapped_data:
    #         print(id)

