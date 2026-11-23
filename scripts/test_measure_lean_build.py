import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / "scripts" / "measure_lean_build.py"


class MeasureBuildTest(unittest.TestCase):
    def test_samples_module_and_propagates_exit(self):
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / "metrics.json"
            command = [
                sys.executable, str(SCRIPT), "--output", str(output),
                "--module", "MahjongDomain/Hand.lean", "--",
                sys.executable, "-c",
                "import subprocess, sys; "
                "p = subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(.8)', "
                "'/tmp/MahjongDomain/Hand.lean']); p.wait(); sys.exit(7)",
            ]
            result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
            self.assertEqual(result.returncode, 7, result.stderr)
            metrics = json.loads(output.read_text())
            self.assertEqual(metrics["exitCode"], 7)
            self.assertGreater(metrics["peakTreePssMiB"], 0)
            self.assertGreater(metrics["modulePeakPssMiB"]["MahjongDomain/Hand.lean"], 0)
            self.assertGreaterEqual(metrics["elapsedSeconds"], 0.7)
            self.assertEqual(metrics["leanThreads"], os.environ.get("LEAN_NUM_THREADS"))

    def test_unobserved_module_is_null(self):
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / "metrics.json"
            result = subprocess.run(
                [sys.executable, str(SCRIPT), "--output", str(output),
                 "--module", "missing.lean", "--", sys.executable, "-c", "import time; time.sleep(.3)"],
                cwd=ROOT, capture_output=True, text=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIsNone(json.loads(output.read_text())["modulePeakPssMiB"]["missing.lean"])


if __name__ == "__main__":
    unittest.main()
