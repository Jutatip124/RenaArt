#!/usr/bin/env python3
"""Batch-fetch Wikimedia Commons image URLs for Renaissance artworks."""

import json
import time
import urllib.parse
import urllib.request

INPUT_FILE = "/tmp/new_200.json"
OUTPUT_FILE = "/tmp/new_200_with_urls.json"
USER_AGENT = "RenaArtApp/1.0 (educational project; contact: github.com/Jutatip124/RenaArt)"
DELAY = 0.5

API_BASE = "https://commons.wikimedia.org/w/api.php"


def api_get(params: dict) -> dict:
    params["format"] = "json"
    url = f"{API_BASE}?{urllib.parse.urlencode(params)}"
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode())


def search_commons(query: str) -> list[str]:
    """Return file titles from a Commons search."""
    data = api_get({
        "action": "query",
        "list": "search",
        "srsearch": query,
        "srnamespace": "6",
        "srlimit": "5",
    })
    return [r["title"] for r in data.get("query", {}).get("search", [])]


def get_thumb_url(title: str) -> str | None:
    """Get the 500px thumbnail URL for a Commons file."""
    data = api_get({
        "action": "query",
        "titles": title,
        "prop": "imageinfo",
        "iiprop": "url|size",
        "iiurlwidth": "500",
    })
    pages = data.get("query", {}).get("pages", {})
    for page in pages.values():
        for info in page.get("imageinfo", []):
            return info.get("thumburl") or info.get("url")
    return None


def pick_image_file(titles: list[str]) -> str | None:
    """Return the first title ending in .jpg or .png (case-insensitive)."""
    for t in titles:
        lower = t.lower()
        if lower.endswith(".jpg") or lower.endswith(".png"):
            return t
    return None


def find_url_for_artwork(artwork: dict) -> str | None:
    title = artwork.get("title", "")
    artist = artwork.get("artist", "")
    art_type = artwork.get("type", "Painting")
    kind = "sculpture" if art_type == "Sculpture" else "painting"

    # Primary search: quoted title + artist
    query1 = f'"{title}" {artist}'
    results = search_commons(query1)
    time.sleep(DELAY)

    match = pick_image_file(results)
    if match:
        url = get_thumb_url(match)
        time.sleep(DELAY)
        if url:
            return url

    # Fallback search: unquoted title + artist + type
    query2 = f"{title} {artist} {kind}"
    results = search_commons(query2)
    time.sleep(DELAY)

    match = pick_image_file(results)
    if match:
        url = get_thumb_url(match)
        time.sleep(DELAY)
        if url:
            return url

    return None


def main():
    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        artworks = json.load(f)

    total = len(artworks)
    found = 0
    not_found = 0

    print(f"Processing {total} artworks...")

    for i, artwork in enumerate(artworks, start=1):
        try:
            url = find_url_for_artwork(artwork)
        except Exception as e:
            print(f"  [{i}] Error for '{artwork.get('title', '?')}': {e}")
            url = None

        if url:
            artwork["imageUrl"] = url
            artwork["thumbnailUrl"] = url
            found += 1
        else:
            not_found += 1

        if i % 10 == 0:
            print(f"  Progress: {i}/{total}  (found: {found}, missing: {not_found})")

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(artworks, f, indent=2, ensure_ascii=False)

    print(f"\nDone! {found}/{total} artworks got URLs, {not_found} without.")
    print(f"Output written to {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
