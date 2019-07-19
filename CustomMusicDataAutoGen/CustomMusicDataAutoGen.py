import urllib.request
import json
import pykakasi
from bs4 import BeautifulSoup

FESTO_MUSIC_VERSION = 10

class MusicData:
    musicId: int
    musicName: str
    romajiMusicName: str
    artistName: str
    romajiArtistName: str
    basicLevel: int
    advancedLevel: int
    extremeLevel: int
    musicVersion: int

    def __init__(self, musicId: int, musicVersion: int):
        self.musicId = musicId
        self.musicVersion = musicVersion

kakasi = pykakasi.kakasi()
kakasi.setMode("H","a")
kakasi.setMode("K","a")
kakasi.setMode("J","a")
kakasi.setMode("r","Hepburn")
kakasi.setMode("s", False)
kakasi.setMode("C", True)
japaneseConverter = kakasi.getConverter()

musicDataPool = {int: MusicData}
cmdJson: str = "{\"music\":{"

# Parse all of the music version from cmd json.
def processMusicVersion():
    cmdUrl = "https://raw.githubusercontent.com/ggomdyu/jubiinfo/master/jubiinfo.client/Resource/DataTable/customMusicDatas_dev.json"

    request = urllib.request.Request(cmdUrl)
    response = urllib.request.urlopen(request)
    cmdJson = response.read();

    jsonData = json.loads(cmdJson)
    for key, value in jsonData["music"].items():
        musicId = int(key)
        musicVersion = int(value[5])

        musicDataPool[musicId] = MusicData(musicId, musicVersion)

# Parse all of the original music data.
def processMusicListCell(parsedHtml):
    musicListElems = parsedHtml.select("#music_list")[0].find_all("div", "list_data")
    for musicListElem in musicListElems:
        tds = musicListElem.find("table").find_all("td")

        musicCoverImagePath = tds[0].find("img").attrs['src']
        musicIdStartPos = musicCoverImagePath.rfind("id") + 2
        musicIdEndPos = musicCoverImagePath.rfind(".")
        musicId = int(musicCoverImagePath[musicIdStartPos:musicIdEndPos])

        musicName = tds[1].text
        artistName = tds[3].text

        lis = tds[4].find_all("li")
        basicLevel = int(float(lis[1].text) * 10.0)
        advancedLevel = int(float(lis[3].text) * 10.0)
        extremeLevel = int(float(lis[5].text) * 10.0)

        if musicId in musicDataPool == False:
            musicDataPool[musicId] = MusicData(musicId, FESTO_MUSIC_VERSION)

        musicData = musicDataPool[musicId]
        musicData.musicName = musicName
        musicData.romajiMusicName = japaneseConverter.do(musicName)
        musicData.artistName = artistName
        musicData.romajiArtistName = japaneseConverter.do(artistName)
        musicData.basicLevel = basicLevel
        musicData.advancedLevel = advancedLevel
        musicData.extremeLevel = extremeLevel

# Parse all of the license music data.
def processLicenseMusic():
    licenseMusicUrl = f"https://p.eagate.573.jp/game/jubeat/festo/information/music_list1.html?page="

    # First of all, we have to query the page count.
    request = urllib.request.Request(f"{licenseMusicUrl}1")
    response = urllib.request.urlopen(request)
    parsedHtml = BeautifulSoup(response.read().decode("Shift_JIS").encode("utf-8"), "html.parser", from_encoding='utf-8')

    maxPageIndex = len(parsedHtml.select("#contents > div.page_navi > div.page")[0].find_all("div"))
    processMusicListCell(parsedHtml)

    for i in range(2, maxPageIndex):
        break

def processOriginalMusic():
    originalMusicUrl = f"https://p.eagate.573.jp/game/jubeat/festo/information/music_list2.html?page="

    # First of all, we have to query the page count.
    request = urllib.request.Request(f"{originalMusicUrl}1")
    response = urllib.request.urlopen(request)
    parsedHtml = BeautifulSoup(response.read().decode("Shift_JIS").encode("utf-8"), "html.parser",
                               from_encoding='utf-8')

    maxPageIndex = len(parsedHtml.select("#contents > div.page_navi > div.page")[0].find_all("div"))
    processMusicListCell(parsedHtml)

    for i in range(2, maxPageIndex):
        break

if __name__ == "__main__":
    processMusicVersion()
    processLicenseMusic()
    processOriginalMusic()