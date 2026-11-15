"""Run a command and render its real output and exit code to a PNG.

The text is not edited except for redaction of emails, tokens, account IDs and URLs,
which happens before rendering. The footer states how many values were redacted.

Usage: python scripts/terminal_shot.py <output.png> <title> -- <command> [args...]
"""

import re
import subprocess
import sys
from datetime import date
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

MAX_LINES = 40
MAX_COLS = 130
ANSI = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")
REDACT = [
    re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"),
    re.compile(r"https?://(?!(127\.0\.0\.1|localhost|emulator|ocsp\.kiln\.test|pki\.kiln\.test|rocky-target-\d))\S+"),
    re.compile(r"\b(ghp|gho|ghs|github_pat)_[A-Za-z0-9_]{10,}\b"),
    re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
    re.compile(r"AGE-SECRET-KEY-[0-9A-Z]+"),
    re.compile(r"\b(?<!\d)\d{12}(?!\d)\b"),
]
FONT_CANDIDATES = [
    "C:/Windows/Fonts/CascadiaMono.ttf",
    "C:/Windows/Fonts/consola.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
]


def redact(text):
    count = 0
    for pattern in REDACT:
        text, n = pattern.subn("[redacted]", text)
        count += n
    return text, count


def load_font(size):
    for candidate in FONT_CANDIDATES:
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def main(argv):
    if "--" not in argv or len(argv) < 4:
        print(__doc__, file=sys.stderr)
        return 2
    split = argv.index("--")
    out_path, title = argv[1], argv[2]
    command = argv[split + 1 :]

    proc = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=False)
    raw = proc.stdout.decode("utf-8", errors="replace")
    text, redacted = redact(ANSI.sub("", raw).replace("\r", ""))
    lines = text.rstrip("\n").split("\n")
    shown = lines
    if len(lines) > MAX_LINES:
        shown = [f"... {len(lines) - MAX_LINES} earlier lines not shown ..."] + lines[-MAX_LINES:]
    shown = [line if len(line) <= MAX_COLS else line[: MAX_COLS - 3] + "..." for line in shown]

    cmd_line, cmd_redacted = redact("$ " + " ".join(command))
    redacted += cmd_redacted
    footer = f"exit code {proc.returncode} | {date.today().isoformat()} | redacted values: {redacted}"
    font = load_font(15)
    bold = load_font(16)
    line_h = 20
    width = 9 * MAX_COLS + 40
    cmd_rows = (len(cmd_line) + MAX_COLS - 1) // MAX_COLS
    height = 70 + line_h * (len(shown) + 2 + cmd_rows)

    image = Image.new("RGB", (width, height), (24, 26, 33))
    draw = ImageDraw.Draw(image)
    draw.rectangle([0, 0, width, 36], fill=(40, 44, 54))
    draw.text((16, 9), title, font=bold, fill=(220, 223, 228))
    y = 48
    for start in range(0, len(cmd_line), MAX_COLS):
        draw.text((16, y), cmd_line[start : start + MAX_COLS], font=font, fill=(130, 200, 255))
        y += line_h
    y += 4
    for line in shown:
        colour = (215, 218, 224)
        if re.match(r"^\s*(PASS|ok |Success|passed)", line):
            colour = (120, 220, 140)
        elif re.match(r"^\s*(FAIL|not ok|Error|ERROR)", line):
            colour = (255, 120, 120)
        draw.text((16, y), line, font=font, fill=colour)
        y += line_h
    y += 6
    status_colour = (120, 220, 140) if proc.returncode == 0 else (255, 200, 90)
    draw.text((16, y), footer, font=font, fill=status_colour)

    Path(out_path).parent.mkdir(parents=True, exist_ok=True)
    image.save(out_path, optimize=True)
    size_kb = Path(out_path).stat().st_size // 1024
    print(f"SAVED {out_path} {size_kb} KB exit={proc.returncode} redacted={redacted}")
    return 0 if size_kb < 500 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
