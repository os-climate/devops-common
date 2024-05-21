# os-climate/devops-common

## Shared DevOps tooling, including linting tools, GitHub Actions

This repository shares common GitHub Actions, workflows, linting settings, etc.

Deployment is automated using a single GitHub workflow, defined in this file:

[workflows/bootstrap.yaml](workflows/bootstrap.yaml)

...and a complementary shell script location here:

[scripts/bootstrap.sh](scripts/bootstrap.sh)

The workflow runs weekly to ensure downstream repositories are regularly updated.
