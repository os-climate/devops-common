<!-- markdownlint-disable -->
<!-- prettier-ignore-start -->
> [!IMPORTANT]
> On June 26 2024, Linux Foundation announced the merger of its financial services umbrella, the Fintech Open Source Foundation ([FINOS](https://finos.org)), with OS-Climate, an open source community dedicated to building data technologies, modeling, and analytic tools that will drive global capital flows into climate change mitigation and resilience; OS-Climate projects are in the process of transitioning to the [FINOS governance framework](https://community.finos.org/docs/governance); read more on [finos.org/press/finos-join-forces-os-open-source-climate-sustainability-esg](https://finos.org/press/finos-join-forces-os-open-source-climate-sustainability-esg)
<!-- prettier-ignore-end -->
<!-- markdownlint-enable -->

# os-climate/devops-common

## Shared DevOps tooling, including linting tools, GitHub Actions

This repository shares common GitHub Actions, workflows, linting settings, etc.

Deployment is automated using a single GitHub workflow, defined in this file:

[workflows/bootstrap.yaml](workflows/bootstrap.yaml)

...and a complementary shell script location here:

[scripts/bootstrap.sh](scripts/bootstrap.sh)

The workflow runs weekly to ensure downstream repositories are regularly updated.
