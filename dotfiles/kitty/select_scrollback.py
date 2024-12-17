import re
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import List, Optional

from kittens.tui.handler import result_handler
from kitty.boss import Boss

PROMPT_REGEX = r"^$\n[^\n]+\n[^$\n]*\$\xa0"


def main(args: List[str]) -> Optional[str]:
    scrollback = sys.stdin.read()
    chunks = re.split(PROMPT_REGEX, scrollback, flags=re.MULTILINE)

    with TemporaryDirectory() as tmpdir:
        tmppath = Path(tmpdir)
        commands = []
        for i, chunk in enumerate(
            chunk for chunk in (c.strip() for c in reversed(chunks)) if chunk
        ):
            chunk = "$ " + chunk
            commands.append(chunk.splitlines()[0])
            (tmppath / str(i)).write_text(chunk)

        proc = None
        try:
            proc = subprocess.run(
                [
                    "fzf",
                    "--exit-0",
                    "--multi",
                    "--with-nth=2..",
                    "--layout=default",
                    "--color=fg:-1,bg:-1,hl:green,fg+:bright-yellow,bg+:-1,hl+:bright-green,prompt:cyan,pointer:bright-red,marker:red",
                    "--preview",
                    f"cat {tmpdir}/{{n}}",
                    "--preview-window=down,~1",
                ],
                check=True,
                text=True,
                input="\n".join(f"{i} {cmd}" for i, cmd in enumerate(commands)),
                stdout=subprocess.PIPE,
            )
        except subprocess.CalledProcessError as e:
            if proc is not None and proc.returncode != 130:
                print(e)
            return None
        selected_indexes = [line.split()[0] for line in proc.stdout.splitlines()]
        selected_text = "\n".join(
            Path(tmppath / i).read_text() for i in selected_indexes
        )
        return "\n".join(line.strip() for line in selected_text.splitlines())


# "history" tells Kitty to pass the screen history to the kitten on stdin
# https://sw.kovidgoyal.net/kitty/kittens/custom/
@result_handler(type_of_input="history")
def handle_result(
    args: List[str], selected_text: Optional[str], target_window_id: int, boss: Boss
) -> None:
    if selected_text:
        subprocess.run(["cb"], check=True, text=True, input=selected_text)
