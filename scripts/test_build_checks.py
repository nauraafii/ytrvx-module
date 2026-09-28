"""Offline regression checks; run python -m unittest discover -s scripts."""

import tempfile
import unittest
import zipfile
from pathlib import Path

from check_build import expected_outputs, verify_outputs


class BuildChecks(unittest.TestCase):
    def setUp(self):
        self.config = {"YouTube": {"version": "21.16.256", "build-mode": "both",
                                  "archive-dlurl": "https://example.org/apks"}}

    def test_complete_release(self):
        names = expected_outputs(self.config)
        with tempfile.TemporaryDirectory() as temp:
            directory = Path(temp)
            for name in names:
                with zipfile.ZipFile(directory / name, "w") as archive:
                    archive.writestr("fixture", "offline test")
            self.assertEqual(verify_outputs(names, directory), sorted(names))

    def test_partial_release_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            directory = Path(temp)
            names = expected_outputs(self.config)
            with zipfile.ZipFile(directory / names[0], "w") as archive:
                archive.writestr("fixture", "APK exists, module is missing")
            with self.assertRaises(ValueError):
                verify_outputs(names, directory)

    def test_html_download_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            directory = Path(temp)
            names = expected_outputs(self.config)
            for name in names:
                (directory / name).write_text("<html>download failed</html>")
            with self.assertRaises(ValueError):
                verify_outputs(names, directory)

    def test_abi_expansion(self):
        self.config["YouTube"]["arch"] = "both"
        self.assertEqual(len(expected_outputs(self.config)), 4)

    def test_invalid_config(self):
        for change in ({"enabled": False}, {"enabled": "false"}, {"arch": "typo"},
                       {"version": "auto", "included-patches": '"Some patch"'}):
            with self.subTest(change=change), self.assertRaises(ValueError):
                expected_outputs({"YouTube": self.config["YouTube"] | change})

    def test_stale_release_files_are_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            directory = Path(temp)
            names = expected_outputs(self.config)
            for name in names + ["old.apk"]:
                with zipfile.ZipFile(directory / name, "w") as archive:
                    archive.writestr("fixture", "offline test")
            with self.assertRaises(ValueError):
                verify_outputs(names, directory)


if __name__ == "__main__":
    unittest.main()
