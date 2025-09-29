# Script 2: import_labels.py
import requests
import json
import os

# Config (edit these)
GITHUB_TOKEN = "your_personal_access_token"   # required for creating/updating/deleting labels
TARGET_REPO = "target_owner/target_repo"      # e.g. "myuser/myrepo"
INPUT_FILE = "./backups/labels.json"          # path to load labels.json
PURGE_OLD_LABELS = False                      # delete old labels not in INPUT_FILE
DRY_RUN = True                                # if True, only print actions (no changes)

HARDCODED_LABELS = [
    {"name": "Needs Review", "color": "d73a4a", "description": "Requires review before merging"},
    {"name": "Blocked", "color": "b60205", "description": "Work cannot proceed until resolved"}
]

BASE_URL = "https://api.github.com"
LABELS_URL = f"{BASE_URL}/repos/{TARGET_REPO}/labels"

headers = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github+json"
}

def load_labels(path):
    with open(path, "r", encoding="utf-8") as f:
        imported_labels = json.load(f)
    return imported_labels + HARDCODED_LABELS

def get_existing_labels():
    labels = []
    page = 1
    while True:
        response = requests.get(LABELS_URL, headers=headers, params={"per_page": 100, "page": page})
        response.raise_for_status()
        data = response.json()
        if not data:
            break
        labels.extend([l["name"] for l in data])
        page += 1
    return labels

def create_label(label):
    if DRY_RUN:
        print(f"[DRY RUN] Would create label: {label['name']}")
        return
    response = requests.post(LABELS_URL, headers=headers, json=label)
    if response.status_code == 201:
        print(f"✅ Created label: {label['name']}")
    elif response.status_code == 422:
        print(f"⚠️ Label already exists: {label['name']}")
    else:
        print(f"❌ Failed to create {label['name']}: {response.status_code} {response.text}")

def delete_label(name):
    if DRY_RUN:
        print(f"[DRY RUN] Would delete old label: {name}")
        return
    response = requests.delete(f"{LABELS_URL}/{name}", headers=headers)
    if response.status_code == 204:
        print(f"🗑️ Deleted old label: {name}")
    else:
        print(f"❌ Failed to delete {name}: {response.status_code} {response.text}")

def main():
    labels_to_add = load_labels(INPUT_FILE)
    label_names_to_add = {l["name"] for l in labels_to_add}
    existing_labels = get_existing_labels()

    new_labels = [l for l in labels_to_add if l["name"] not in existing_labels]
    skipped_labels = [l for l in labels_to_add if l["name"] in existing_labels]
    labels_to_delete = [name for name in existing_labels if name not in label_names_to_add] if PURGE_OLD_LABELS else []

    # Show summary
    print(f"📊 Summary for {TARGET_REPO}:")
    print(f"- {len(new_labels)} labels would be created")
    print(f"- {len(skipped_labels)} labels already exist and would be skipped")
    if PURGE_OLD_LABELS:
        print(f"- {len(labels_to_delete)} old labels would be deleted")
    else:
        print(f"- Purge disabled, no deletions")

    # Apply (or simulate) changes
    for label in labels_to_add:
        create_label(label)
    if PURGE_OLD_LABELS:
        for name in labels_to_delete:
            delete_label(name)

    if DRY_RUN:
        print("ℹ️ DRY RUN enabled — no changes were made.")

if __name__ == "__main__":
    main()
