import os
import unittest
from unittest.mock import patch, mock_open, MagicMock
from scripts.fetch_fonts import fetch_fonts


class TestFetchFonts(unittest.TestCase):
    @patch("requests.get")
    @patch("builtins.open", new_callable=mock_open)
    @patch.dict(os.environ, {"DOTFILES_FONTS_CONFIG": "/path/to/dir"}, clear=True)
    def test_fetch_fonts(self, mock_open, mock_get):
        # Mock the response from requests.get
        mock_response = MagicMock()
        mock_response.content = """
        <div class="item">
            <div class="nerd-font-buttons-wrapper">
                <a class="nerd-font-button nf-fa-download" href="/download-link"></a>
                <a class="nerd-font-button nf-oct-link_external" alt="Full Preview of Font on ProgrammingFonts.org"></a>
            </div>
        </div>
        """.encode()  # Convert the string to bytes
        mock_get.return_value = mock_response

        # Call the function
        fetch_fonts()

        # Check that requests.get was called with the correct URL
        mock_get.assert_called_once_with("https://www.nerdfonts.com/font-downloads")

        # Check that the file was written to with the correct content
        write_calls = mock_open().write.call_args_list
        written_content = "".join(call.args[0] for call in write_calls)
        expected_content = '{\n    "Font": "/download-link"\n}'
        self.assertEqual(written_content, expected_content)

    @patch("requests.get")
    @patch.dict(os.environ, {}, clear=True)
    def test_fetch_fonts_no_dotfiles_fonts_config(self, mock_get):
        # Mock the response from requests.get
        mock_response = MagicMock()
        mock_response.content = """
        <div class="item">
            <div class="nerd-font-buttons-wrapper">
                <a class="nerd-font-button nf-fa-download" href="/download-link"></a>
                <a class="nerd-font-button nf-oct-link_external" alt="Full Preview of Font on ProgrammingFonts.org"></a>
            </div>
        </div>
        """
        mock_get.return_value = mock_response

        # Call the function and check that it raises an exception
        with self.assertRaises(Exception) as context:
            fetch_fonts()
        self.assertTrue(
            "DOTFILES_FONTS_CONFIG environment variable not set"
            in str(context.exception)
        )


if __name__ == "__main__":
    unittest.main()
