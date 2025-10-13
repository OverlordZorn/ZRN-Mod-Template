#!/usr/bin/env python3

import os
import sys
import traceback
import subprocess as sp
import difflib
from github import Github

# Path to stringtablediag.py
STRINGTABLEDIAG_PATH = os.path.join("tools", "stringtablediag.py")
if not os.path.isfile(STRINGTABLEDIAG_PATH):
    print(f"❌ Error: {STRINGTABLEDIAG_PATH} not found.")
    print("   Hint: Ensure that the repository contains 'tools/stringtablediag.py' and that you ran 'actions/checkout'.")
    sys.exit(1)

def generate_markdown():
    """Runs stringtablediag.py and returns enhanced markdown output."""
    result = sp.run(
        ["python3", STRINGTABLEDIAG_PATH, "--markdown"],
        stdout=sp.PIPE,
        stderr=sp.PIPE,
        text=True,
        check=True
    )
    return result.stdout

def update_translations(repo, issue_number):
    new_body = generate_markdown()

    issue = repo.get_issue(issue_number)
    old_body = issue.body or ""

    if old_body.strip() == new_body.strip():
        print("ℹ️ Translation issue is already up to date. No changes made.")
        return

    # Show diff
    diff = difflib.unified_diff(
        old_body.splitlines(),
        new_body.splitlines(),
        fromfile="current_issue",
        tofile="new_issue",
        lineterm=""
    )
    print("📝 Changes detected in translation issue:")
    print("\n".join(diff))

    # Update issue
    issue.edit(body=new_body)
    print("✅ Translation issue updated.")

def main():
    # Get GitHub token
    try:
        token = os.environ["GH_TOKEN"]
    except KeyError:
        print("❌ Error: GH_TOKEN environment variable not set.")
        sys.exit(1)

    # Get translation issue number
    try:
        translation_issue = int(os.environ["TRANSLATION_ISSUE"])
    except KeyError:
        print("❌ Error: TRANSLATION_ISSUE environment variable not set.")
        sys.exit(1)
    except ValueError:
        print(f"❌ Error: TRANSLATION_ISSUE must be an integer, got '{os.environ['TRANSLATION_ISSUE']}'.")
        sys.exit(1)

    # Get repo info
    github_repo = os.getenv("GITHUB_REPOSITORY")
    if not github_repo:
        print("❌ Error: GITHUB_REPOSITORY environment variable not set.")
        sys.exit(1)
    user, repo_name = github_repo.split("/")

    # Connect to GitHub
    try:
        repo = Github(token).get_repo(f"{user}/{repo_name}")
    except Exception:
        print("❌ Could not obtain repo object from GitHub.")
        print(traceback.format_exc())
        sys.exit(1)

    print(f"\n📝 Updating translation issue #{translation_issue} ...")
    try:
        update_translations(repo, translation_issue)
    except Exception:
        print("❌ Failed to update translation issue.")
        print(traceback.format_exc())
        sys.exit(1)

if __name__ == "__main__":
    main()
