import urllib.request
import json
import pykakasi
import os
import base64
from github import Github
from github import InputGitTreeElement
from datetime import datetime
from time import sleep
from bs4 import BeautifulSoup
import ssl
import sys

# Determines whether the build result is for live or develop
ENABLE_LIVE_MODE = False
MODE_NAME = ENABLE_LIVE_MODE and "live" or "dev"

# This variable indicates the version of the game like 'clan', 'festo'
LATEST_GAME_VERSION = 10

ssl._create_default_https_context = ssl._create_unverified_context


class MusicData:
    music_id = 0
    music_name = ""
    uppercased_romaji_music_name = ""
    artist_name = ""
    uppercased_romaji_artist_name = ""
    basic_level = 0
    advanced_level = 0
    extreme_level = 0
    music_version = 0

    def __init__(self, music_id: int, music_version: int):
        self.music_id = music_id
        self.music_name = ""
        self.uppercased_romaji_music_name = ""
        self.artist_name = ""
        self.uppercased_romaji_artist_name = ""
        self.basic_level = 0
        self.advanced_level = 0
        self.extreme_level = 0
        self.music_version = music_version


kakasi = pykakasi.kakasi()
kakasi.setMode("H", "a")
kakasi.setMode("K", "a")
kakasi.setMode("J", "a")
kakasi.setMode("r", "Hepburn")
kakasi.setMode("s", False)
kakasi.setMode("C", True)
japaneseConverter = kakasi.getConverter()

music_data_pool = dict()
cmd_json = "{\"music\":{"


# Parse all of the music version from cmd json.
def process_music_version():
    cmd_url = "https://raw.githubusercontent.com/ggomdyu/jubiinfo/master/jubiinfo.client/Resource/DataTable/cmd_" + MODE_NAME + ".json"

    request = urllib.request.Request(cmd_url)
    response = urllib.request.urlopen(request)
    prev_cmd_json = response.read();

    json_data = json.loads(prev_cmd_json.decode('utf-8'))
    for key, value in json_data["music"].items():
        music_id = int(key)
        music_version = int(value[5])

        music_data_pool[music_id] = MusicData(music_id, music_version)


# Parse all of the original music data.
def process_music_list_cell(parsed_html):
    musicListElems = parsed_html.select("#music_list")[0].find_all("div", "list_data")
    for musicListElem in musicListElems:
        tds = musicListElem.find("table").find_all("td")

        music_cover_image_path = tds[0].find("img").attrs['src']
        music_id_start_pos = music_cover_image_path.rfind("id") + 2
        music_id_end_pos = music_cover_image_path.rfind(".")
        music_id = int(music_cover_image_path[music_id_start_pos:music_id_end_pos])

        music_name = tds[1].text
        artist_name = tds[3].text

        lis = tds[4].find_all("li")
        basic_level = int(float(lis[1].text) * 10.0)
        advanced_level = int(float(lis[3].text) * 10.0)
        extreme_level = int(float(lis[5].text) * 10.0)

        if music_id not in music_data_pool:
            music_data_pool[music_id] = MusicData(music_id, LATEST_GAME_VERSION)

        music_data = music_data_pool[music_id]
        music_data.music_name = music_name
        music_data.uppercased_romaji_music_name = japaneseConverter.do(music_name).replace(" ", "").upper()
        music_data.artist_name = artist_name.replace('"', '\\"')
        music_data.uppercased_romaji_artist_name = japaneseConverter.do(artist_name).replace(" ", "").replace('"',
                                                                                                              '\\"').upper()
        music_data.basic_level = basic_level
        music_data.advanced_level = advanced_level
        music_data.extreme_level = extreme_level


# Parse all of the license music data.
def process_license_music():
    license_music_url = "https://p.eagate.573.jp/game/jubeat/festo/information/music_list1.html?page="

    # First of all, we have to query the page count.
    request = urllib.request.Request(license_music_url + "1")
    response = urllib.request.urlopen(request)
    parsed_html = BeautifulSoup(response.read().decode("shift_jisx0213").encode("utf-8"), "html.parser",
                                from_encoding='utf-8')

    max_page_index = len(parsed_html.select("#contents > div.page_navi > div.page")[0].find_all("div"))

    print("License music processing... " + "(1/" + str(max_page_index) + ")")
    process_music_list_cell(parsed_html)

    for i in range(2, max_page_index + 1):
        sleep(0.2)

        url = license_music_url + str(i)
        request2 = urllib.request.Request(url)
        response2 = urllib.request.urlopen(request2)
        parsed_html2 = BeautifulSoup(response2.read().decode("shift_jisx0213").encode("utf-8"), "html.parser",
                                     from_encoding='utf-8')

        print("License music processing... " + "(" + str(i) + "/" + str(max_page_index) + ")")
        process_music_list_cell(parsed_html2)


def process_original_music():
    original_music_url = "https://p.eagate.573.jp/game/jubeat/festo/information/music_list2.html?page="

    # First of all, we have to query the page count.
    request = urllib.request.Request(original_music_url + "1")
    response = urllib.request.urlopen(request)
    parsed_html = BeautifulSoup(response.read().decode("shift_jisx0213").encode("utf-8"), "html.parser",
                                from_encoding='utf-8')

    max_page_index = len(parsed_html.select("#contents > div.page_navi > div.page")[0].find_all("div"))

    print("Original music processing... " + "(1/" + str(max_page_index) + ")")
    process_music_list_cell(parsed_html)

    for i in range(2, max_page_index + 1):
        sleep(0.2)

        url = original_music_url + str(i)
        request2 = urllib.request.Request(url)
        response2 = urllib.request.urlopen(request2)
        parsed_html2 = BeautifulSoup(response2.read().decode("shift_jisx0213").encode("utf-8"), "html.parser",
                                     from_encoding='utf-8')

        print("Original music processing... " + "(" + str(i) + "/" + str(max_page_index) + ")")

        process_music_list_cell(parsed_html2)


def pushCmdJsonToGithubRepo(cmd_json):
    g = Github(sys.argv[1])
    repo = g.get_user().get_repo("jubiinfo")
    file_data = [
        datetime.now().strftime("%Y%m%d%H%M%S"),
        cmd_json
    ]
    file_path_list = [
        "jubiinfo.client/Resource/DataTable/cmdChecksum_" + MODE_NAME,
        "jubiinfo.client/Resource/DataTable/cmd_" + MODE_NAME + ".json"
    ]
    commit_message = "Update cmd"
    master_ref = repo.get_git_ref("heads/master")
    master_sha = master_ref.object.sha
    base_tree = repo.get_git_tree(master_sha)

    element_list = list()
    index = 0
    for file_path in file_path_list:
        element = InputGitTreeElement(file_path, "100644", "blob", file_data[index])
        element_list.append(element)
        index += 1

    tree = repo.create_git_tree(element_list, base_tree)
    parent = repo.get_git_commit(master_sha)
    commit = repo.create_git_commit(commit_message, tree, [parent])
    master_ref.edit(commit.sha)

if __name__ == "__main__":
    process_music_version()
    process_license_music()
    process_original_music()

    for music_data in music_data_pool.values():
        if music_data.music_name == "":
            continue

        cmd_json += '"' + str(music_data.music_id) + '"' + ":[" + '"' + music_data.artist_name + '"' + "," + '"' + music_data.uppercased_romaji_artist_name + '"' + "," + str(music_data.basic_level) + "," \
                    + str(music_data.advanced_level) + "," + str(music_data.extreme_level) + "," + str(music_data.music_version) + "],"
    cmd_json = cmd_json[:-1]
    cmd_json += "}}"

    pushCmdJsonToGithubRepo(cmd_json)

    print("All task complete!")
