from pretext import resources
import xml.etree.ElementTree as ET

RUNESTONE_VERSION = "8.2.10"
RUNESTONE_CDN_URL = f"https://runestone.academy/cdn/runestone/{RUNESTONE_VERSION}/"
RUNESTONE_JS_FILES = [
    "prefix-runtime.e3f9706509fcf6f7.bundle.js",
    "prefix-runestone.c5ba0ffa5f963084.bundle.js",
]
RUNESTONE_CSS_FILES = ["prefix-runestone.efe427683fc41f98.css"]

cache_dir = resources.resource_base_path() / "rs_cache"
cache_dir.mkdir(parents=True, exist_ok=True)
cache_file = cache_dir / "rs_services.xml"

if cache_file.exists():
    try:
        root = ET.fromstring(cache_file.read_text(encoding="utf-8"))

        def local_name(tag: str) -> str:
            return tag.split("}", 1)[-1]

        def find_first_text(element: ET.Element, name: str) -> str:
            for child in element:
                if local_name(child.tag) == name:
                    return child.text or ""
            return ""

        def find_items(element: ET.Element, parent_name: str) -> list[str]:
            for child in element:
                if local_name(child.tag) == parent_name:
                    return [grandchild.text or "" for grandchild in child if local_name(grandchild.tag) == "item"]
            return []

        version = find_first_text(root, "version")
        cdn_url = find_first_text(root, "cdn-url")
        js_items_existing = find_items(root, "js")
        css_items_existing = find_items(root, "css")
        if (
            version == RUNESTONE_VERSION
            and cdn_url == RUNESTONE_CDN_URL
            and js_items_existing == RUNESTONE_JS_FILES
            and css_items_existing == RUNESTONE_CSS_FILES
        ):
            raise SystemExit(0)
    except ET.ParseError:
        pass

js_items = "\n".join(f"    <item>{name}</item>" for name in RUNESTONE_JS_FILES)
css_items = "\n".join(f"    <item>{name}</item>" for name in RUNESTONE_CSS_FILES)

cache_file.write_text(
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
