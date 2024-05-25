#!/usr/bin/env python3
"""Code to process updates in GitHub Actions workflows."""

import git  # pip install gitpython
import typer


def main(workflow: str):
    """All the heavy lifting is done here."""
    cloned_repos = []

    # Read the specified file from disk
    try:
        file = open(workflow, "r")
        print(f"Processing: {workflow}")
        file_content = file.readlines()

    except FileNotFoundError:
        print("The specified file could not be opened:")
        print(workflow)
        exit(1)

    # Reset any cloned repository local state
    # if os.path.isdir("/tmp/update"):
    #    shutil.rmtree("/tmp/update")
    # os.mkdir("/tmp/update")

    for line in file_content:
        line_text = line.replace("\n", "")

        # Extract lines referencing reusable workflows
        if "uses: " not in line_text:
            # The line does not reference a reusable workflow
            continue

        # Extract the required fields
        before_ampersand = line_text.split("@")[0]
        after_ampersand = line_text.split("@")[1]
        action = before_ampersand.split("uses: ")[1]
        repo_name = action.split("/")[1]
        version = after_ampersand.split(" ")[0]
        whitespace = before_ampersand.split("uses: ")[0]
        try:
            comment_version = after_ampersand.split("  ")[1]
        except IndexError:
            comment_version = ""

        # Print the line in the same format it was received, but by fields/components
        print(whitespace + "uses:", action + "@" + version, " " + comment_version)

        if ".github/workflows" in action and (version == "main" or version == "master"):
            print("Skipping:", action)
            continue

        # lfit/gerrit-review-action -> https://github.com/lfit/gerrit-review-action.git
        repo_url = "https://github.com/" + action + ".git"

        if action in cloned_repos:
            # The repository is a duplicate, has already been cloned
            continue
        try:
            print(f"Cloning: {repo_url}")
            git.Git("/tmp/update").clone(repo_url)
            cloned_repos.append(action)
        except Exception as error:
            print(f"The specified GIT repository could not be cloned: {error}")
            print(repo_url)

        repo = git.Repo("/tmp/update/" + repo_name)
        head_commit_sha = repo.head.object.hexsha
        print(head_commit_sha)

    # Close the file after processing
    file.close()


if __name__ == "__main__":
    typer.run(main)
