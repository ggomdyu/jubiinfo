import urllib.request
from bs4 import BeautifulSoup

customMusicDataJson: str = "{\"music\":{"

def processMusicListCell(parsedHtml):
    filteredMusicListElem: []
    musicListElems = parsedHtml.select("#music_list")[0].find_all("div")

def processLicenseMusic():
    licenseMusicUrl = f"https://p.eagate.573.jp/game/jubeat/festo/information/music_list1.html?page="

    # First of all, we have to query the page count.
    response = urllib.request.urlopen(f"{licenseMusicUrl}1")
    html = response.read();
    parsedHtml = BeautifulSoup(html)
    maxPageIndex = len(parsedHtml.select("#contents > div.page_navi > div.page")[0].find_all("div"))
    processMusicListCell(parsedHtml)

    for i in range(2, maxPageIndex):
        break
    return

def processOriginalMusic():
    originalMusicUrl = f"https://p.eagate.573.jp/game/jubeat/festo/information/music_list1.html?page="
    return

if __name__ == "__main__":
    processLicenseMusic()
    processOriginalMusic()