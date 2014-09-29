# GitHub create deployment step

A wercker step for creating a GitHub deployments. It has a few parameters, but only two are required: `token` and `tag`. See [Creating a GitHub token](#creating-a-github-token).

This step will export the id of the deployment in an environment variable (default: `$WERCKER_GITHUB_CREATE_DEPLOYMENT_ID`).

Currently this step does not do any json escaping. So be careful when using quotes or newlines in parameters.

More information about GitHub deployments:

- https://developer.github.com/v3/repos/deployments/

# Example

A minimal example, this will get the token from a environment variable and do a release:

``` yaml
deploy:
    steps:
        - github-create-deployment:
            token: $GITHUB_TOKEN
            environment: demo
```
