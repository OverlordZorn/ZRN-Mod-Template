# Script 1: export_labels.py
import requests
import json
import os

# Config (edit these)
GITHUB_TOKEN = ""   # not required for public repos
SOURCE_REPO = "acemod/ACE3"                   # e.g. "octocat/Hello-World"
OUTPUT_FILE = "./backups/labels.json"         # path to store labels.json
DRY_RUN = False                                # if True, only print summary (no file written)

BASE_URL = "https://api.github.com"
headers = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json"
}

def get_labels(repo):
    labels = []
    page = 1
    while True:
        url = f"{BASE_URL}/repos/{repo}/labels"
        response = requests.get(url, headers=headers, params={"per_page": 100, "page": page})
        response.raise_for_status()
        data = response.json()
        if not data:
            break
        for label in data:
            labels.append({
                "name": label["name"],
                "color": label["color"],
                "description": label.get("description") or ""
            })
        page += 1
    return labels

def main():
    labels = get_labels(SOURCE_REPO)

    if DRY_RUN:
        print(f"📊 Summary for {SOURCE_REPO}:")
        print(f"- {len(labels)} labels would be exported")
        print("Labels:")
        for label in labels:
            print(f"  • {label['name']} (#{label['color']}) : {label['description']}")
        print("ℹ️ DRY RUN enabled — no file was written.")
    else:
        os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
        with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
            json.dump(labels, f, indent=2)
        print(f"✅ Exported {len(labels)} labels to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
