"""Choose the next Android version code from GitHub release tags."""
import sys


def next_version(tags):
    versions = [int(tag) for line in tags if (tag := line.strip()).isascii() and tag.isdigit()]
    version = max(versions, default=0) + 1
    if version > 2147483647:
        raise ValueError("Release version code exceeds Android limit")
    return version


if __name__ == "__main__":
    try:
        print(next_version(sys.stdin))
    except ValueError as error:
        sys.exit(str(error))
