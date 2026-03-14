#!/usr/bin/env python3
"""Validate and fix broken Wikimedia image URLs in artworks.json."""

import json
import time
import urllib.request
import urllib.parse
import ssl

ARTWORKS_PATH = "/workspaces/RenaArt/renaart/assets/data/artworks.json"

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

UA = "RenaArt-URLChecker/1.0 (educational project; contact: github.com/Jutatip124/RenaArt)"


def head_check(url, timeout=15, retries=3):
    """Return HTTP status code with retry on 429."""
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, method="HEAD")
            req.add_header("User-Agent", UA)
            with urllib.request.urlopen(req, timeout=timeout, context=ctx) as resp:
                return resp.status
        except urllib.error.HTTPError as e:
            if e.code == 429 and attempt < retries - 1:
                wait = 5 * (attempt + 1)
                print(f"429, retry in {wait}s...", end="", flush=True)
                time.sleep(wait)
                continue
            return e.code
        except Exception:
            return -1
    return -1


def search_wikimedia(title, artist):
    """Search Wikimedia Commons for a replacement thumbnail URL."""
    search_terms = f"{title} {artist}"
    params = urllib.parse.urlencode({
        "action": "query",
        "generator": "search",
        "gsrsearch": search_terms,
        "gsrnamespace": 6,
        "prop": "imageinfo",
        "iiprop": "url",
        "iiurlwidth": 400,
        "format": "json",
    })
    url = f"https://commons.wikimedia.org/w/api.php?{params}"
    for attempt in range(3):
        try:
            req = urllib.request.Request(url)
            req.add_header("User-Agent", UA)
            with urllib.request.urlopen(req, timeout=20, context=ctx) as resp:
                data = json.loads(resp.read().decode())
            pages = data.get("query", {}).get("pages", {})
            if not pages:
                return None
            sorted_pages = sorted(pages.values(), key=lambda p: p.get("index", 999))
            for page in sorted_pages:
                imageinfo = page.get("imageinfo", [])
                if imageinfo:
                    thumb = imageinfo[0].get("thumburl")
                    if thumb:
                        return thumb
            return None
        except urllib.error.HTTPError as e:
            if e.code == 429 and attempt < 2:
                time.sleep(5 * (attempt + 1))
                continue
            return None
        except Exception as e:
            print(f"  API error: {e}")
            return None
    return None


def main():
    with open(ARTWORKS_PATH, "r", encoding="utf-8") as f:
        artworks = json.load(f)

    total = len(artworks)
    fixed = 0
    removed = 0
    ok = 0
    kept = []

    for i, art in enumerate(artworks):
        title = art.get("title", "Unknown")
        artist = art.get("artist", "Unknown")
        url = art.get("imageUrl", "")
        print(f"[{i+1}/{total}] {title} — ", end="", flush=True)

        status = head_check(url)
        if status == 200:
            print("OK")
            ok += 1
            kept.append(art)
            time.sleep(1)
            continue

        print(f"HTTP {status} — searching replacement...", flush=True)
        time.sleep(2)

        new_url = search_wikimedia(title, artist)
        if new_url:
            # Trust the Wikimedia API result (avoid extra HEAD that triggers 429)
            print(f"  ✓ Fixed with new URL")
            art["imageUrl"] = new_url
            fixed += 1
            kept.append(art)
        else:
            print(f"  ✗ No replacement found, removing")
            removed += 1

        time.sleep(2)

    with open(ARTWORKS_PATH, "w", encoding="utf-8") as f:
        json.dump(kept, f, indent=2, ensure_ascii=False)

    print(f"\n{'='*50}")
    print(f"Summary:")
    print(f"  Total artworks:   {total}")
    print(f"  OK (unchanged):   {ok}")
    print(f"  Fixed:            {fixed}")
    print(f"  Removed:          {removed}")
    print(f"  Final count:      {len(kept)}")


if __name__ == "__main__":
    main()
