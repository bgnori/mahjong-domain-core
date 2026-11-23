import tempfile
import unittest
from pathlib import Path

import build_ci_page


class BuildCiPageTest(unittest.TestCase):
    def test_build_preserves_content_and_adds_ci_assets(self):
        with tempfile.TemporaryDirectory() as temporary:
            site = Path(temporary)
            (site / "index.html").write_text("content")
            build_ci_page.build(site)
            self.assertEqual((site / "index.html").read_text(), "content")
            for name in build_ci_page.CI_FILES:
                self.assertTrue((site / "ci" / name).is_file())

    def test_reserved_path_collision_is_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            site = Path(temporary)
            (site / "ci").mkdir()
            (site / "ci" / "index.html").write_text("existing")
            with self.assertRaises(FileExistsError):
                build_ci_page.build(site)
            self.assertEqual((site / "ci" / "index.html").read_text(), "existing")


if __name__ == "__main__":
    unittest.main()
