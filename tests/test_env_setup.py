import os
import unittest
from unittest.mock import patch
import env_setup
from env_setup import EnvItem, DIR_VALUE, FILE_VALUE


class TestEnvItem(unittest.TestCase):
    @patch.dict(os.environ, {}, clear=True)
    @patch("os.path.isdir", return_value=True)
    def test_check_and_export_dir(self, mock_isdir):
        item = EnvItem("TEST_DIR", "/path/to/dir", DIR_VALUE)
        item.check_and_export()
        mock_isdir.assert_called_once_with("/path/to/dir")
        self.assertEqual(os.environ["TEST_DIR"], "/path/to/dir")

    @patch.dict(os.environ, {}, clear=True)
    @patch("os.path.isfile", return_value=True)
    def test_check_and_export_file(self, mock_isfile):
        item = EnvItem("TEST_FILE", "/path/to/file", FILE_VALUE)
        item.check_and_export()
        mock_isfile.assert_called_once_with("/path/to/file")
        self.assertEqual(os.environ["TEST_FILE"], "/path/to/file")

    def test_check_and_export_invalid_type(self):
        item = EnvItem("TEST_ITEM", "/path/to/item", "invalid_type")
        with self.assertRaises(Exception) as context:
            item.check_and_export()
        self.assertTrue("Invalid type: invalid_type" in str(context.exception))


class TestMain(unittest.TestCase):
    @patch("os.path.isdir", return_value=True)
    @patch("os.path.isfile", return_value=True)
    @patch(
        "os.getenv",
        side_effect=lambda x: (
            "/path/to/github/workspace"
            if x == "GITHUB_WORKSPACE"
            else "/path/to/env_setup.py/env_setup.py"
        ),
    )
    @patch("os.path.realpath", return_value="/path/to/env_setup.py/env_setup.py")
    @patch.dict("os.environ", {})
    def test_main_ci(self, mock_realpath, mock_getenv, mock_isfile, mock_isdir):
        env_setup.main()
        mock_realpath.assert_called_once()
        mock_getenv.assert_called()
        mock_isfile.assert_called()
        mock_isdir.assert_called()
        self.assertEqual(os.environ["DOTFILES_DIR"], "/path/to/env_setup.py")
        self.assertEqual(
            os.environ["DOTFILES_CONIG_DIR"], "/path/to/env_setup.py/config"
        )
        self.assertEqual(
            os.environ["DOTFILES_SCRIPTS_DIR"], "/path/to/env_setup.py/scripts"
        )
        self.assertEqual(
            os.environ["DOTFILES_FONTS_CONFIG"],
            "/path/to/env_setup.py/config/fonts.json",
        )


class TestMain(unittest.TestCase):
    @patch("os.path.isdir", return_value=True)
    @patch("os.path.isfile", return_value=True)
    @patch(
        "os.getenv",
        side_effect=lambda x: (
            "/path/to/github/workspace"
            if x == "GITHUB_WORKSPACE"
            else "/path/to/env_setup.py/env_setup.py"
        ),
    )
    @patch("os.path.realpath", return_value="/path/to/env_setup.py/env_setup.py")
    @patch.dict("os.environ", {})
    def test_main_ci(self, mock_realpath, mock_getenv, mock_isfile, mock_isdir):
        env_setup.main()
        mock_realpath.assert_called_once()
        mock_getenv.assert_called()
        mock_isfile.assert_called()
        mock_isdir.assert_called()
        self.assertEqual(os.environ["DOTFILES_DIR"], "/path/to/env_setup.py")
        self.assertEqual(
            os.environ["DOTFILES_CONIG_DIR"], "/path/to/env_setup.py/config"
        )
        self.assertEqual(
            os.environ["DOTFILES_SCRIPTS_DIR"], "/path/to/env_setup.py/scripts"
        )
        self.assertEqual(
            os.environ["DOTFILES_FONTS_CONFIG"],
            "/path/to/env_setup.py/config/fonts.json",
        )

    @patch("os.path.isdir", return_value=True)
    @patch("os.path.isfile", return_value=True)
    @patch(
        "os.getenv",
        side_effect=lambda x: (
            None if x == "CI" else "/path/to/env_setup.py/env_setup.py"
        ),
    )
    @patch("os.path.realpath", return_value="/path/to/env_setup.py/env_setup.py")
    @patch.dict("os.environ", {})
    def test_main_non_ci(self, mock_realpath, mock_getenv, mock_isfile, mock_isdir):
        env_setup.main()
        mock_realpath.assert_called_once()
        mock_getenv.assert_called()
        mock_isfile.assert_called()
        mock_isdir.assert_called()
        self.assertEqual(os.environ["DOTFILES_DIR"], "/path/to/env_setup.py")
        self.assertEqual(
            os.environ["DOTFILES_CONIG_DIR"], "/path/to/env_setup.py/config"
        )
        self.assertEqual(
            os.environ["DOTFILES_SCRIPTS_DIR"], "/path/to/env_setup.py/scripts"
        )
        self.assertEqual(
            os.environ["DOTFILES_FONTS_CONFIG"],
            "/path/to/env_setup.py/config/fonts.json",
        )


if __name__ == "__main__":
    unittest.main()
