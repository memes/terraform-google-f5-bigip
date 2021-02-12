# How to contribute

Contributions are welcome to this repo, but we do have a few guidelines for
contributors.

## Open an issue and pull request for changes

All submissions, including those from project members, are required to go through
review. We use GitHub Pull Requests for this workflow, which should be linked with
an issue for tracking purposes.
See [GitHub](https://help.github.com/articles/about-pull-requests/) for more details.

## Pre-Commit

[Pre-commit](https://pre-commit.com/) is used to ensure that all files have
consistent formatting and to avoid committing secrets. Please install and
integrate the tool before pushing changes to GitHub.

1. Install pre-commit in venv or globally: see [instructions](https://pre-commit.com/#installation)
2. Fork and clone this repo
3. Install pre-commit hook to git

   ```shell
   pre-commit install
   ```

The hook will ensure that `pre-commit` will be run against all staged changes
during `git commit`.

## Testing

This project uses
[kitchen-terraform](https://newcontext-oss.github.io/kitchen-terraform/) to
validate that BIG-IP VMs are instantiated correctly. Any PRs must pass this test
suite before they will be merged.
