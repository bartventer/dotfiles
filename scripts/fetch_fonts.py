import os
import requests
from bs4 import BeautifulSoup
import json
from tqdm import tqdm

url = "https://www.nerdfonts.com/font-downloads"
response = requests.get(url)
soup = BeautifulSoup(response.content, "html.parser")
font_elements = soup.find_all("div", class_="item")

fonts: dict[str, str] = {}
for font_element in tqdm(font_elements, desc="Fetching fonts", unit="font"):
    buttons_wrapper = font_element.find("div", class_="nerd-font-buttons-wrapper")
    if buttons_wrapper is not None:
        font_download_link_element = buttons_wrapper.select_one(
            ".nerd-font-button.nf-fa-download"
        )
        font_name_element = buttons_wrapper.select_one(
            ".nerd-font-button.nf-oct-link_external"
        )

        if font_download_link_element is not None and font_name_element is not None:
            font_download_link = font_download_link_element["href"]
            font_name = (
                font_name_element["alt"]
                .replace("Full Preview of ", "")
                .replace(" on ProgrammingFonts.org", "")
            )
            fonts[font_name] = font_download_link

repo_dir = os.environ.get("REPO_DIR")
if repo_dir is None:
    raise Exception("REPO_DIR environment variable not set")
fonts_file = os.path.join(repo_dir, "fonts.json")

try:
    with open(fonts_file, "w") as file:
        json.dump(fonts, file, indent=4)
except Exception as e:
    print("Error writing to file:", e)
