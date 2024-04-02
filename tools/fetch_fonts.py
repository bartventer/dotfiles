"""
This script fetches font information from the Nerd Fonts website and writes it to a JSON file.

It uses BeautifulSoup to parse the HTML of the website, finds all font elements, and extracts the font name and download link.
The resulting dictionary of font names and download links is then written to a JSON file.

Environment Variables:
    DOTFILES_DIR: The directory where the 'fonts.json' file will be written.

Dependencies:
    requests: For making HTTP requests.
    BeautifulSoup: For parsing HTML.
    tqdm: For showing a progress bar.
"""

import os
import requests
from bs4 import BeautifulSoup
import json
from tqdm import tqdm


def fetch_fonts():
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

    fonts_file = os.environ.get("DOTFILES_FONTS_PATH")
    if fonts_file is None:
        raise Exception("DOTFILES_FONTS_PATH environment variable not set")

    try:
        with open(fonts_file, "w") as file:
            json.dump(fonts, file, indent=4)
    except Exception as e:
        print("Error writing to file:", e)


if __name__ == "__main__":
    fetch_fonts()
