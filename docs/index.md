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

Static configurations are currently stored in the cluster-name directories in the `git-sync-operator` branch in this repo, but that will soon change. So for now if a change to a static configuration is needed please ask for help in the `#meao-infra` channel on Slack.

## Quick Start

So you want to flip a waffle switch in production? Great! Do this:

1. Clone the `mozmeao/www-config` repo.
2. Fork the repo into your Github account.
3. Edit the `waffle_configs/bedrock-prod.env` file to add the name and value you need. You'd add a line like `SWITCH_WE_DO_PHRASING=on` to set that key and value in the settings database for prod. Or you can find the line that already has the variable you need and change the value if it already exists.
4. Commit the change.
5. Push the change to a branch on your fork.
6. Submit a pull-request against the `mozmeao/www-config` repo.
7. Ask for a review in the `#www` IRC channel or in the PR itself.
8. Once the PR is reviewed and merged it will automatically roll out to our production instances in 5 to 10 minutes.

## Editing the Configs

The configurations are in the `waffle_configs` directory in the repo. They are simple environment files in the [format usable by Foreman](https://ddollar.github.io/foreman/#ENVIRONMENT).

Deleting a variable is simply deleting the line from the file. The full list of configurations are refreshed every time for those values.

[Bedrock]: https://github.com/mozilla/bedrock
