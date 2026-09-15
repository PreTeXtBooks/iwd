from pretext import resources

RUNESTONE_VERSION = "8.2.10"
RUNESTONE_CDN_URL = f"https://runestone.academy/cdn/runestone/{RUNESTONE_VERSION}/"
RUNESTONE_JS_FILES = [
    "prefix-runtime.e3f9706509fcf6f7.bundle.js",
    "prefix-runestone.c5ba0ffa5f963084.bundle.js",
]
RUNESTONE_CSS_FILES = ["prefix-runestone.efe427683fc41f98.css"]

cache_dir = resources.resource_base_path() / "rs_cache"
cache_dir.mkdir(parents=True, exist_ok=True)

js_items = "\n".join(f"    <item>{name}</item>" for name in RUNESTONE_JS_FILES)
css_items = "\n".join(f"    <item>{name}</item>" for name in RUNESTONE_CSS_FILES)

(cache_dir / "rs_services.xml").write_text(
    "\n".join(
        [
            "<all>",
            "  <js>",
            js_items,
            "  </js>",
            "  <css>",
            css_items,
            "  </css>",
            f"  <cdn-url>{RUNESTONE_CDN_URL}</cdn-url>",
            f"  <version>{RUNESTONE_VERSION}</version>",
            "</all>",
            "",
        ]
    ),
    encoding="utf-8",
)
