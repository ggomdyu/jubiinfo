import urllib.request
import json
import pykakasi
import os
from bs4 import BeautifulSoup

ENABLE_LIVE_MODE = False
MODE_NAME = ENABLE_LIVE_MODE and "live" or "dev"
FESTO_MUSIC_VERSION = 10

class MusicData:
    music_id: int
    music_name: str
    romaji_music_name: str
    artist_name: str
    romaji_artist_name: str
    basic_level: int
    advanced_level: int
    extreme_level: int
    music_version: int

    def __init__(self, music_id: int, music_version: int):
        self.music_id = music_id
        self.music_name = ""
        self.romaji_music_name = ""
        self.artist_name = ""
        self.romaji_artist_name = ""
        self.basic_level = 0
        self.advanced_level = 0
        self.extreme_level = 0
        self.music_version = music_version

kakasi = pykakasi.kakasi()
kakasi.setMode("H","a")
kakasi.setMode("K","a")
kakasi.setMode("J","a")
kakasi.setMode("r","Hepburn")
kakasi.setMode("s", False)
kakasi.setMode("C", True)
japaneseConverter = kakasi.getConverter()

music_data_pool: {int, MusicData} = {}
cmd_json: str = "{\"music\":{"

# Parse all of the music version from cmd json.
def process_music_version():
    cmd_url = "https://raw.githubusercontent.com/ggomdyu/jubiinfo/master/jubiinfo.client/Resource/" \
              "DataTable/customMusicDatas_dev.json"

    request = urllib.request.Request(cmd_url)
    response = urllib.request.urlopen(request)
    prev_cmd_json = response.read();

    json_data = json.loads(prev_cmd_json)
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
            music_data_pool[music_id] = MusicData(music_id, FESTO_MUSIC_VERSION)

        music_data = music_data_pool[music_id]
        music_data.music_name = music_name
        music_data.romaji_music_name = japaneseConverter.do(music_name).replace(" ", "")
        music_data.artist_name = artist_name
        music_data.romaji_artist_name = japaneseConverter.do(artist_name).replace(" ", "")
        music_data.basic_level = basic_level
        music_data.advanced_level = advanced_level
        music_data.extreme_level = extreme_level

# Parse all of the license music data.
def process_license_music():
    license_music_url = f"https://p.eagate.573.jp/game/jubeat/festo/information/music_list1.html?page="

    # First of all, we have to query the page count.
    request = urllib.request.Request(f"{license_music_url}1")
    response = urllib.request.urlopen(request)
    parsed_html = BeautifulSoup(response.read().decode("Shift_JIS").encode("utf-8"), "html.parser", from_encoding='utf-8')

    max_page_index = len(parsed_html.select("#contents > div.page_navi > div.page")[0].find_all("div"))

    print(f"License music processing... ({1}/{max_page_index})")
    process_music_list_cell(parsed_html)

    # for i in range(2, max_page_index + 1):
    #     time.sleep(0.5)
    #
    #     request2 = urllib.request.Request(f"{license_music_url}{i}")
    #     response2 = urllib.request.urlopen(request2)
    #     parsed_html2 = BeautifulSoup(response2.read(), "html.parser", from_encoding='utf-8')
    #
    #     print(f"License music processing... ({i}/{max_page_index})")
    #     process_music_list_cell(parsed_html2)

def process_original_music():
    original_music_url = f"https://p.eagate.573.jp/game/jubeat/festo/information/music_list2.html?page="

    # First of all, we have to query the page count.
    request = urllib.request.Request(f"{original_music_url}1")
    response = urllib.request.urlopen(request)
    parsed_html = BeautifulSoup(response.read().decode("Shift_JIS").encode("utf-8"), "html.parser",
                               from_encoding='utf-8')

    max_page_index = len(parsed_html.select("#contents > div.page_navi > div.page")[0].find_all("div"))

    print(f"Original music processing... ({1}/{max_page_index})")
    process_music_list_cell(parsed_html)

    # for i in range(2, max_page_index + 1):
    #     time.sleep(0.5)
    #
    #     request2 = urllib.request.Request(f"{original_music_url}{i})")
    #     response2 = urllib.request.urlopen(request2)
    #     parsed_html2 = BeautifulSoup(response2.read().decode("Shift_JIS").encode("utf-8"), "html.parser", from_encoding='utf-8')
    #
    #     print(f"Original music processing... ({i}/{max_page_index})")
    #     process_music_list_cell(parsed_html2)

if __name__ == "__main__":
    process_music_version()
    process_license_music()
    process_original_music()

    for music_data in music_data_pool.values():
        print(music_data.basic_level)
        cmd_json += f"\"{music_data.music_id}\":[\"{music_data.artist_name}\",\"{music_data.romaji_artist_name}\",{music_data.basic_level}," \
                    f"{music_data.advanced_level},{music_data.basic_level},{music_data.music_version}],"
    cmd_json = cmd_json[:-1]
    cmd_json += "}}"

    print(cmd_json)

desktop_path = os.path.join(os.path.join(os.environ['USERPROFILE']), 'Desktop')
cmd_json_path = desktop_path + "/customMusicDatas_dev.json"

file = open(cmd_json_path, 'w');
file.write(cmd_json)

print("CMD json write complete!")