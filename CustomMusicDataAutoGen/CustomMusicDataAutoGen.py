import urllib.request
from bs4 import BeautifulSoup

customMusicDataJson: str = "{\"music\":{"

def processMusicListCell(parsedHtml):
    musicListElems = parsedHtml.select("#music_list")[0].find_all("div", "list_data")
    for musicListElem in musicListElems:
        tds = parsedHtml.find("table").find_all("td");
        musicName = tds[1].text;
        artistName = tds[3].text;

        lis = tds[4].find_all("li");
        basicLevel = int(float(lis[1].text) * 10.0);
        advancedLevel = int(float(lis[3].text) * 10.0);
        extremeLevel = int(float(lis[5].text) * 10.0);
        print(f"{musicName}, {artistName}, {basicLevel}, {advancedLevel}, {extremeLevel}")


def processLicenseMusic():
    licenseMusicUrl = f"https://p.eagate.573.jp/game/jubeat/festo/information/music_list1.html?page="

    # First of all, we have to query the page count.
    response = urllib.request.urlopen(f"{licenseMusicUrl}1")
    html = response.read();
    parsedHtml = BeautifulSoup(html, "html.parser")
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