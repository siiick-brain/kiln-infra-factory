"""Capture public GitHub pages of this repository to PNG with Playwright.

The pages are loaded signed out, so each image shows what any visitor sees. Nothing on the
page is edited. Captures run at 1440 by 900 in the light theme.

Usage: python scripts/capture_github.py [name ...]
Names: ci-green, drift-workflow, readme-top, readme-architecture, contributors (default: all)
"""

import sys
from pathlib import Path

from playwright.sync_api import sync_playwright

REPO = "https://github.com/siiick-brain/kiln-infra-factory"
OUT = Path(__file__).resolve().parent.parent / "docs" / "images"
VIEWPORT = {"width": 1440, "height": 900}

# name -> (url, README heading to scroll to first). None means no scrolling. Workflow pages show main only.
PAGES = {
    "ci-green": (f"{REPO}/actions/workflows/ci.yml?query=branch%3Amain", None),
    "drift-workflow": (f"{REPO}/actions/workflows/drift.yml?query=branch%3Amain", None),
    "readme-top": (REPO, None),
    "readme-architecture": (REPO, "Architecture"),
    "contributors": (f"{REPO}/graphs/contributors", None),
}


def usage() -> None:
    print(__doc__.strip(), file=sys.stderr)


def main(argv: list[str]) -> int:
    if any(a in ("-h", "--help") for a in argv):
        usage()
        return 0
    names = argv or list(PAGES)
    unknown = [n for n in names if n not in PAGES]
    if unknown:
        print(f"Unknown page: {', '.join(unknown)}", file=sys.stderr)
        usage()
        return 2

    OUT.mkdir(parents=True, exist_ok=True)
    failed = 0
    with sync_playwright() as p:
        # Installed Chrome avoids a Playwright browser download.
        browser = p.chromium.launch(channel="chrome")
        context = browser.new_context(viewport=VIEWPORT, color_scheme="light", locale="en-US")
        page = context.new_page()
        for name in names:
            url, anchor = PAGES[name]
            target = OUT / f"github-{name}.png"
            try:
                # GitHub keeps background requests open, so wait for load and then the content.
                response = page.goto(url, wait_until="load", timeout=60_000)
                if response is None or response.status != 200:
                    status = "no response" if response is None else response.status
                    raise RuntimeError(f"HTTP {status}")
                page.locator("main").first.wait_for(timeout=30_000)
                if anchor:
                    heading = page.get_by_role("heading", name=anchor, exact=True).first
                    heading.wait_for(timeout=30_000)
                    heading.evaluate("el => el.scrollIntoView({block: 'start'})")
                    page.evaluate("window.scrollBy(0, -16)")
                page.wait_for_timeout(1_500)
                page.screenshot(path=str(target))
                print(f"PASS {name} -> {target.relative_to(OUT.parent.parent).as_posix()}")
            except Exception as exc:  # report every page, then fail at the end
                print(f"FAIL {name}: {exc}")
                failed += 1
        browser.close()
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
