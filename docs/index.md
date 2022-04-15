# Bedrock Configurator

This is the documentation for the configuration system for [Bedrock][] instances. We have two distinct types
of configuration values: static and dynamic. Static configurations are those that are loaded at app startup in
the `bedrock/settings/base.py` file primarily. They require an app restart to pick up new values and get their
values from either the environment or a .env file in the app root directory.

The second kind of configuration is one that can change while the app is running. At the moment the only use of
these is waffle switches and funnelcake configuration. These can be loaded from the same places as static configs
(environment and .env) but also from the database. So you can continue using your `.env` file locally to test
settings, but we can distribute said settings to our running instances via the database update process. This is why
we've separated these values into separate files.

Static configurations are currently stored in the directories named after the cluster and namespace (e.g. [iowa-a/bedrock-dev](https://github.com/mozmeao/www-config/tree/main/iowa-a/bedrock-dev)).


## Quick Start

So you want to flip a waffle switch in production? Great! Do this:

1. Clone the `mozmeao/www-config` repo.
2. Fork the repo into your Github account.
3. Edit the `waffle_configs/bedrock-stage.env` file to add the name and value you need. You'd add a line like `SWITCH_WE_DO_PHRASING=on` to set that key and value in the settings database for the stage environment. Or you can find the line that already has the variable you need and change the value if it already exists.
4.  (**Optional**) If you'd like to test the switch on the staging environment prior to pushing to production, create a pull-request, request review, merge the ticket, and visit the environment at https://www.allizom.org/.
5. Edit the `waffle_configs/bedrock-prod.env` file to make the same changes for production that you just made for stage.
6. Commit the change.
7. Push the change to a branch on your fork.
8. Submit a pull-request against the `mozmeao/www-config` repo.
9. Ask for a review in the `#www` IRC channel or in the PR itself.
10. Once the PR is reviewed and merged, it will automatically roll out to our production instances at in 5 to 10 minutes.

## Editing the Configs

The configurations are in the `waffle_configs` directory in the repo. They are simple environment files in the [format usable by Foreman](https://ddollar.github.io/foreman/#ENVIRONMENT).

Deleting a variable is simply deleting the line from the file. The full list of configurations are refreshed every time for those values.

[Bedrock]: https://github.com/mozilla/bedrock

## Testing

Any commit that triggers a deployment to our dev, staging, or prod environments will also trigger a suite of test jobs configured in [.gitlab-ci.yml](https://github.com/mozmeao/www-config/blob/main/.gitlab-ci.yml). That file also specifies a number of jobs to be run if a pipeline provided a BASE_URL, which we can use to test independent of deployment.

  - visit [https://gitlab.com/mozmeao/www-config/pipelines/new](https://gitlab.com/mozmeao/www-config/pipelines/new)
  - by default the `main` branch is populated
  - Add a new variable:
    - **Input variable key** is `BASE_URL`
    - **Input variable value** should be equal to the URL you want to run the tests against (example: https://www-demo1.allizom.org)
  - By default the latest bedrock_test image is used for the tests
    - this can be overridden by adding a `TEST_IMAGE` variable
    - example: mozmeao/bedrock_test:096fb7dd6a588dee093557ebe57bcc151d893462
      - see [bedrock_test tags](https://hub.docker.com/r/mozmeao/bedrock_test/tags) for a current list
      - Custom images can be built by pushing to the `build-test` branch of bedrock as of [mozilla/bedrock#8286](https://github.com/mozilla/bedrock/pull/8286)
