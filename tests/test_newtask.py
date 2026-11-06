"""Isolated setup tests: every git/gh operation is a local stub, never a remote call."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = os.environ.get("TASK_TEST_BASH", "bash")


class NewTaskTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        shutil.copytree(ROOT / "scripts", self.root / "scripts")
        shutil.copytree(ROOT / "tasks" / "templates", self.root / "tasks" / "templates")
        shutil.copytree(ROOT / "tasks" / "lightweight-template", self.root / "tasks" / "lightweight-template")
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "calls"
        self.stub("where.exe", 'if [[ "$1" == python ]]; then command -v python; fi\n')
        self.stub("git", '''printf 'git %s\\n' "$*" >> "$CALL_LOG"
case "$1" in
  rev-parse) if [[ "$2" == --show-toplevel ]]; then pwd; else echo abc123; fi ;;
  cat-file) if [[ "$3" == "abc123:${MISSING_BASE_TEMPLATE:-}" ]]; then exit 1; fi
    echo "${BASE_TEMPLATE_TYPE:-blob}" ;;
  ls-remote) if [[ "${FAIL_REMOTE:-}" == 1 ]]; then exit 1; fi
    printf '%s\\n' "${REMOTE_REFS:-}" ;;
  fetch|switch) : ;;
  *) exit 1 ;;
esac
''')
        self.stub("gh", '''printf 'gh %s\\n' "$*" >> "$CALL_LOG"
case "$1 $2" in
  'auth status') : ;;
  'repo view') echo example/repo ;;
  'api --method') [[ "${FAIL_CREATE:-}" != 1 ]] ;;
  *) exit 1 ;;
esac
''')
        def bash_path(path):
            value = path.as_posix()
            return "/" + value[0].lower() + value[2:] if len(value) > 1 and value[1] == ":" else value

        env_file = self.root / "bash_env"
        env_file.write_text('git() ( source "$MOCK_BIN/git" "$@" )\n'
                            'gh() ( source "$MOCK_BIN/gh" "$@" )\n'
                            'where.exe() ( source "$MOCK_BIN/where.exe" "$@" )\n', encoding="utf-8")
        self.env = os.environ.copy()
        self.env.update(BASH_ENV=bash_path(env_file), MOCK_BIN=bash_path(self.bin),
                        CALL_LOG=bash_path(self.log))

    def stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/usr/bin/env bash\nset -e\n" + body, encoding="utf-8")
        path.chmod(0o755)

    def run_setup(self, *args, **env):
        return subprocess.run([BASH, str(self.root / "scripts" / "newtask.sh"), *args],
                              cwd=self.root, env={**self.env, **env}, text=True,
                              capture_output=True)

    def test_default_full_and_description(self):
        result = self.run_setup('A "quoted" request & details')
        self.assertEqual(result.returncode, 0, result.stderr)
        task = self.root / "tasks" / "TASK0001"
        self.assertEqual({p.name for p in task.iterdir()},
                         {p.name for p in (self.root / "tasks" / "templates").iterdir()})
        self.assertIn('A "quoted" request & details', (task / "README.md").read_text(encoding="utf-8"))
        self.assertIn('ref=refs/heads/feature/task0001', self.log.read_text())

    def test_lightweight_uses_unused_local_and_remote_ids(self):
        (self.root / "tasks" / "TASK0001").mkdir()
        result = self.run_setup("--lightweight", "Small change", REMOTE_REFS="abc refs/heads/feature/task0002")
        self.assertEqual(result.returncode, 0, result.stderr)
        task = self.root / "tasks" / "TASK0003"
        self.assertEqual([p.name for p in task.iterdir()], ["README.md"])
        text = (task / "README.md").read_text(encoding="utf-8")
        self.assertIn("feature/task0003", text)
        self.assertIn("Small change", text)
        self.assertIn("## Short plan", text)
        self.assertIn("ref=refs/heads/feature/task0003", self.log.read_text())

    def test_remote_lookup_failure_does_not_create_branch_or_record(self):
        result = self.run_setup("--lightweight", "Change", FAIL_REMOTE="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Could not list remote", result.stderr)
        self.assertNotIn("gh api", self.log.read_text())
        self.assertFalse((self.root / "tasks" / "TASK0001").exists())

    def test_branch_creation_failure_leaves_no_record(self):
        result = self.run_setup("Change", FAIL_CREATE="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.root / "tasks" / "TASK0001").exists())
        self.assertNotIn("git switch", self.log.read_text())

    def test_missing_lightweight_description_has_no_side_effects(self):
        result = self.run_setup("--lightweight")
        self.assertEqual(result.returncode, 2)
        self.assertFalse(self.log.exists())

    def test_missing_base_templates_fail_before_branch_creation(self):
        for args, missing in [
            (("--lightweight", "Change"), "tasks/lightweight-template/README.md"),
            (("Change",), "tasks/templates/review.md"),
        ]:
            with self.subTest(missing=missing):
                result = self.run_setup(*args, MISSING_BASE_TEMPLATE=missing)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(missing, result.stderr)
                self.assertIn("no branch was created", result.stderr)
                self.assertNotIn("gh api", self.log.read_text())
                self.assertNotIn("git switch", self.log.read_text())
                self.assertFalse((self.root / "tasks" / "TASK0001").exists())

    def test_base_template_must_be_a_blob(self):
        result = self.run_setup("--lightweight", "Change", BASE_TEMPLATE_TYPE="tree")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("no branch was created", result.stderr)
        self.assertNotIn("gh api", self.log.read_text())


if __name__ == "__main__":
    unittest.main()
