"""Renders docs/og.png and landing page verification screenshots via Playwright."""
import http.server
import socketserver
import sys
import threading
from playwright.sync_api import sync_playwright


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass


def main() -> int:
    httpd = socketserver.TCPServer(("127.0.0.1", 0), QuietHandler)
    port = httpd.server_address[1]
    thread = threading.Thread(target=httpd.serve_forever, daemon=True)
    thread.start()

    base = f"http://127.0.0.1:{port}"
    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True)

            # 1. OG image (1200x630)
            page = browser.new_page(viewport={"width": 1200, "height": 630})
            page.goto(f"{base}/tool/og/og.html", wait_until="networkidle")
            page.evaluate("() => document.fonts.ready")
            page.screenshot(path="docs/og.png")
            page.close()

            # 2. Landing page + network audit + screenshots
            requests_seen: list[str] = []
            ctx = browser.new_context(viewport={"width": 1440, "height": 900}, color_scheme="light")
            page = ctx.new_page()
            page.on("request", lambda req: requests_seen.append(req.url))
            page.goto(f"{base}/docs/", wait_until="networkidle")
            page.evaluate("() => document.fonts.ready")
            page.evaluate("() => { for (const img of document.querySelectorAll('img')) img.loading = 'eager'; }")
            page.wait_for_load_state("networkidle")
            page.screenshot(path="handover/design/landing/built-desktop.png", full_page=True)

            page.set_viewport_size({"width": 1040, "height": 900})
            page.screenshot(path="handover/design/landing/built-1040.png", full_page=True)

            page.set_viewport_size({"width": 768, "height": 900})
            page.screenshot(path="handover/design/landing/built-768.png", full_page=True)

            page.set_viewport_size({"width": 390, "height": 844})
            page.screenshot(path="handover/design/landing/built-mobile.png", full_page=True)

            # 320px overflow check
            page.set_viewport_size({"width": 320, "height": 800})
            overflow_320 = page.evaluate(
                "() => ({ sw: document.documentElement.scrollWidth, cw: document.documentElement.clientWidth })"
            )

            # 200% font size check at 390px
            page.set_viewport_size({"width": 390, "height": 844})
            page.evaluate("() => { document.documentElement.style.fontSize = '32px'; }")
            overflow_200 = page.evaluate(
                "() => ({ sw: document.documentElement.scrollWidth, cw: document.documentElement.clientWidth })"
            )
            ctx.close()

            # Dark mode 1440px
            ctx_dark = browser.new_context(viewport={"width": 1440, "height": 900}, color_scheme="dark")
            page_dark = ctx_dark.new_page()
            page_dark.goto(f"{base}/docs/", wait_until="networkidle")
            page_dark.evaluate("() => document.fonts.ready")
            page_dark.evaluate("() => { for (const img of document.querySelectorAll('img')) img.loading = 'eager'; }")
            page_dark.wait_for_load_state("networkidle")
            page_dark.screenshot(path="handover/design/landing/built-dark.png", full_page=True)
            ctx_dark.close()

            browser.close()

        print("NETWORK REQUESTS:")
        external = []
        for u in requests_seen:
            print(" ", u)
            if not u.startswith(base):
                external.append(u)
        print(f"320px check: {overflow_320}")
        print(f"200% font check (390px): {overflow_200}")
        if external:
            print("ERROR: External requests detected:", external, file=sys.stderr)
            return 1
        if overflow_320["sw"] > overflow_320["cw"]:
            print("ERROR: Horizontal overflow at 320px!", file=sys.stderr)
            return 1
        if overflow_200["sw"] > overflow_200["cw"]:
            print("WARNING: Horizontal overflow at 200% font size on 390px!", file=sys.stderr)
            return 1
        return 0
    finally:
        httpd.shutdown()


if __name__ == "__main__":
    raise SystemExit(main())
