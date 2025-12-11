```markdown
# Hosting dbt docs on GitHub Pages (automated)

This repository can use a GitHub Actions workflow to build and deploy dbt documentation to GitHub Pages.

What the workflow does

- Runs on pushes to `main` and manually via `workflow_dispatch`.
- Installs `dbt-core` and any adapter packages you configure via the repository secret `DBT_ADAPTER_PACKAGES` (for example `dbt-postgres` or `dbt-bigquery`).
- Optionally writes `profiles.yml` from a repository secret `DBT_PROFILES_YML` into `~/.dbt/profiles.yml` (recommended for CI).
- Runs `dbt docs generate` to produce docs into the `target/` directory.
- Copies generated files from `target/` into a `site/` folder and uploads that folder as the Pages artifact.
- Deploys the artifact to GitHub Pages using the official Pages actions.

Required repository configuration

1. Secrets

- `DBT_ADAPTER_PACKAGES` (optional but recommended): space-separated adapter packages to `pip install` (e.g. `dbt-postgres` or `dbt-bigquery`).
- `DBT_PROFILES_YML` (optional, recommended for CI): paste your profiles.yml content (including any credentials you want the runner to use) into a secret named `DBT_PROFILES_YML`. The workflow will write it to `~/.dbt/profiles.yml`.

Security note: storing `profiles.yml` in a secret is more secure than committing it to the repo. If your profiles contain very sensitive credentials, consider using environment-specific CI secrets or a secrets manager.

2. Pages & Actions permissions

- The workflow sets the `pages` and `contents` permissions required to upload and deploy the site artifact. Ensure repository settings allow GitHub Actions to create and manage Pages for the repo.
- For private repositories: GitHub Pages can publish from private repos via Actions; make sure your account/organization plan supports this.

Alternative: generate docs locally and push

If you prefer not to run docs generation in CI:

1. Locally:
   - Run `dbt docs generate`
   - Copy `target/` contents into a `docs/` root folder (`cp -r target/* docs/`)
   - Commit and push `docs/` to `main`.

2. In the repository Settings > Pages, set the source to the `docs/` folder on the `main` branch.

Troubleshooting

- If `dbt docs generate` fails, check that:
  - The adapter package is installed (via `DBT_ADAPTER_PACKAGES`).
  - `profiles.yml` is valid and pointed to by `~/.dbt/profiles.yml` or `DBT_PROFILES_DIR`.
- Check the full Actions logs for the run step that failed. Logs include the environment and the dbt error output.
- Common issues: missing adapter packages, invalid credentials in profiles, or expecting secrets that haven't been defined.
```
