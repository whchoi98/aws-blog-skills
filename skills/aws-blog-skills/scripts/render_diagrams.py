# Usage: python3 render_diagrams.py <images-dir>   (renders every *.html in the dir to *.png at 2x)
# Without Playwright installed: uv run --no-project --with playwright python render_diagrams.py <images-dir>
import glob, os, pathlib, sys

try:
    from playwright.sync_api import sync_playwright
except ImportError:
    sys.exit("playwright is not installed. Run with:\n"
             "  uv run --no-project --with playwright python render_diagrams.py <images-dir>\n"
             "or install it: pip install playwright && python -m playwright install chromium")

# The images dir must be the blog work folder, never this skill folder (a plugin cache that updates replace).
IMG = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("BLOG_IMAGES")
if not IMG:
    sys.exit("usage: render_diagrams.py <images-dir>  (or set BLOG_IMAGES)")
files = sorted(glob.glob(os.path.join(IMG, "*.html")))
if not files:
    sys.exit(f"no *.html in {IMG}")
with sync_playwright() as p:
    b = p.chromium.launch()
    pg = b.new_page(device_scale_factor=2, viewport={"width": 1400, "height": 800})
    for f in files:
        pg.goto("file://" + str(pathlib.Path(f).resolve()))
        pg.wait_for_function("document.fonts.ready.then(()=>true)")
        ok = pg.evaluate("document.fonts.check('600 20px \"Amazon Ember\"') && document.fonts.check('16px \"Noto Sans CJK KR\"')")
        # text overflow gate: every <text> must stay inside the svg viewBox with 8px margin
        over = pg.evaluate("""() => {
          const svg = document.querySelector('svg'); const vb = svg.viewBox.baseVal;
          const out = [];
          document.querySelectorAll('svg text').forEach(t => { const bb = t.getBBox();
            if (bb.x < 8 || bb.y < 0 || bb.x + bb.width > vb.width - 8 || bb.y + bb.height > vb.height) out.push(t.textContent + ' @' + Math.round(bb.x+bb.width)); });
          return out; }""")
        out = f[:-5] + ".png"
        pg.locator("svg").first.screenshot(path=out, omit_background=False)
        print(os.path.basename(out), "fonts:", ok, "overflow:", over)
    b.close()
