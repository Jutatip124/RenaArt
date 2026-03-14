#!/usr/bin/env python3
"""Find Wikimedia Commons image URLs for artworks and merge into artworks.json."""
import json, urllib.request, urllib.parse, time, sys

WIKI_API = "https://commons.wikimedia.org/w/api.php"

def search_wikimedia(query, retries=2):
    """Search Wikimedia Commons for an image, return thumb URL at 500px."""
    params = urllib.parse.urlencode({
        "action": "query",
        "generator": "search",
        "gsrsearch": query,
        "gsrnamespace": "6",
        "gsrlimit": "3",
        "prop": "imageinfo",
        "iiprop": "url",
        "iiurlwidth": "500",
        "format": "json",
    })
    url = f"{WIKI_API}?{params}"
    for attempt in range(retries + 1):
        try:
            req = urllib.request.Request(url)
            req.add_header("User-Agent", "RenaArtBot/1.0 (educational project)")
            resp = urllib.request.urlopen(req, timeout=15)
            data = json.loads(resp.read().decode())
            pages = data.get("query", {}).get("pages", {})
            if pages:
                # Sort by index to get most relevant
                sorted_pages = sorted(pages.values(), key=lambda p: p.get("index", 999))
                for page in sorted_pages:
                    ii = page.get("imageinfo", [{}])[0]
                    thumb = ii.get("thumburl", "")
                    if thumb and not thumb.endswith(".svg.png"):
                        return thumb
            return ""
        except Exception as e:
            if attempt < retries:
                time.sleep(3)
            else:
                print(f"  ERROR: {e}")
                return ""

def find_image_url(title, artist):
    """Try multiple search strategies to find the artwork image."""
    # Strategy 1: exact title + artist
    queries = [
        f"{title} {artist} painting",
        f"{title} {artist}",
        f"{title} Renaissance",
        title,
    ]
    for q in queries:
        result = search_wikimedia(q)
        if result:
            return result
        time.sleep(1)
    return ""

def main():
    with open("/tmp/new_artworks.json") as f:
        new_artworks = json.load(f)

    with open("renaart/assets/data/artworks.json") as f:
        existing = json.load(f)

    print(f"Existing: {len(existing)} artworks")
    print(f"New to add: {len(new_artworks)} artworks")
    print()

    added = 0
    failed = []
    for i, art in enumerate(new_artworks):
        title = art["title"]
        artist = art["artist"]
        print(f"[{i+1}/{len(new_artworks)}] {title} by {artist}...", end=" ", flush=True)

        img_url = find_image_url(title, artist)
        if img_url:
            art["imageUrl"] = img_url
            art["thumbnailUrl"] = img_url
            art["sourceUrl"] = f"https://commons.wikimedia.org/wiki/Special:Search/{urllib.parse.quote(title)}"
            existing.append(art)
            added += 1
            print(f"OK")
        else:
            failed.append(f"{art['id']}: {title}")
            print(f"FAILED - no image found")

        time.sleep(1.5)

    with open("renaart/assets/data/artworks.json", "w") as f:
        json.dump(existing, f, indent=2, ensure_ascii=False)

    print(f"\n=== RESULTS ===")
    print(f"Added: {added}")
    print(f"Failed: {len(failed)}")
    print(f"Total artworks: {len(existing)}")
    if failed:
        print(f"\nFailed artworks:")
        for f_item in failed:
            print(f"  {f_item}")

if __name__ == "__main__":
    main()
