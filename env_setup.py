#!/usr/bin/env python3

"""
This script is used to initialize environment variables for the dotfiles repository.
It checks the existence of certain directories and files, and sets them as environment variables if they exist.
If any of the checks fail, the script logs an error message and exits.
"""

import os
import sys
from dataclasses import dataclass

DIR_VALUE = "dir"
FILE_VALUE = "file"


@dataclass
class EnvItem:
    """
    Represents an environment item that needs to be checked and exported.

    Attributes:
        name (str): The name of the environment variable.
        path (str): The path to the directory or file that the environment variable should point to.
        type (str): The type of the environment item ("dir" for directories, "file" for files).
    """

    name: str
    path: str
    type: str

    def check_and_export(self):
        """
        Checks if the environment item exists and exports it if it does.
        Raises an exception if the type is invalid.

        Returns:
            None
        """
        if self.type == DIR_VALUE:
            assert os.path.isdir(self.path), f"{self.name} directory not found."
        elif self.type == FILE_VALUE:
            assert os.path.isfile(self.path), f"{self.name} file not found."
        else:
            raise Exception(f"Invalid type: {self.type}")
        os.environ[self.name] = self.path
        print(f'export {self.name}="{self.path}"')


def main():
    print("Setting environment...", file=sys.stderr)

    # Set DOTFILES_DIR
    if os.getenv("CI") == "true":
        DOTFILES_DIR = os.getenv("GITHUB_WORKSPACE")
    else:
        DOTFILES_DIR = os.path.dirname(os.path.realpath(__file__))

    # Set DOTFILES_CONIG_DIR
    DOTFILES_CONIG_DIR = os.path.join(DOTFILES_DIR, "config")

    # List of environment items to check and export
    env_items = [
        EnvItem(name="DOTFILES_DIR", path=DOTFILES_DIR, type=DIR_VALUE),
        EnvItem(name="DOTFILES_CONIG_DIR", path=DOTFILES_CONIG_DIR, type=DIR_VALUE),
        EnvItem(
            name="DOTFILES_SCRIPTS_DIR",
            path=os.path.join(DOTFILES_DIR, "scripts"),
            type=DIR_VALUE,
        ),
        EnvItem(
            name="DOTFILES_FONTS_CONFIG",
            path=os.path.join(DOTFILES_CONIG_DIR, "fonts.json"),
            type=FILE_VALUE,
        ),
    ]

    # Check and export each environment item
    for item in env_items:
        item.check_and_export()

    print("Environment set.", file=sys.stderr)


if __name__ == "__main__":
    main()
