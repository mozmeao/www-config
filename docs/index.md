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

Static configurations are stored in the `config` directory in this repo and can only be updated via a push to the app-name
branch (as described below). The dynamic configs however will automatically roll out after a change is merged to the master
branch.

## Quick Start

### Dynamic Configs

So you want to flip a waffle switch in production? Great! Do this:

1. Clone the `mozmeao/www-config` repo.
2. Fork the repo into your Github account.
3. Edit the `waffle_configs/bedrock-prod.env` file to add the name and value you need. You'd add a line like `SWITCH_WE_DO_PHRASING=on` to set that key and value in the settings database for prod. Or you can find the line that already has the variable you need and change the value if it already exists.
4. Commit the change.
5. Push the change to a branch on your fork.
6. Submit a pull-request against the `mozmeao/www-config` repo.
7. Ask for a review in the `#www` IRC channel or in the PR itself.
8. Once the PR is reviewed and merged it will automatically roll out to our production instances in 5 to 10 minutes.

### Static Configs

Let's say you want to change a static config value in prod. Follow the following procedure:

1. Clone the `mozmeao/www-config` repo.
2. Fork the repo into your Github account.
3. Edit the `configs/bedrock-prod.env` file to add the name and value you need. You'd add a line like `STAFF_NAMES=Woodhouse` to set that key and value in the environment for prod. Or you can find the line that already has the variable you need and change the value if it already exists.
4. Commit the change.
5. Push the change to a branch on your fork.
6. Submit a pull-request against the `mozmeao/www-config` repo.
7. Ask for a review in the `#www` IRC channel or in the PR itself.
8. Once the PR is reviewed and merged it can be applied: `git pull origin master && ./set-config bedrock-prod` (assuming `origin` is your remote name for the `mozmeao` repo)

## How it Works

This repo is designed to hold the [non-secret environment variable configuration options](configs.md) for the various instances of [Bedrock][]. The idea is that you edit the `*.env` file associated with the bedrock Deis app you'd like to update (e.g. `bedrock-prod.env`). This would be submitted as a pull-request to the `www-config` repo, the PR would then be reviewed and merged to `master`. Once the config in the `master` branch was ready to apply, that revision of `master` would be pushed to a branch named after the Deis app name that needed updating (e.g. `bedrock-prod`). This would start the process of applying the configuration to our Deis clusters in sequence, and running our `headless` tests against them in turn.

If the change to be applied needed to be done as quickly as possible, for example if something is broken, you can alternately push `master` to a similar branch as above but prefixed with `fast/` (e.g. `fast/bedrock-prod`). This will do the same thing as above but every Deis cluster will be pushed and tested simultaneously (or in parallel, instead of in series).

There is a script in the repo to help with this called `./set-config`. It allows you to do the following:

```shell
$ ./set-config bedrock-stage
```

This will push your currently checked out revision of the configurations to the app name passed to it. You can also invoke it with `-f` or `--fast` and it will cause the configurations to be applied in parallel as mentioned above.

```shell
$ ./set-config -f bedrock-prod
```

## Editing the Configs

The configurations are in the `configs` and `waffle_configs` directories in the repo. They are simple environment files in the [format usable by Foreman](https://ddollar.github.io/foreman/#ENVIRONMENT). The final list of variables to apply for static values will be the mix of 3 possible files.

1. `configs/global.env`: applied to every app.
2. `configs/{cluster-name}.env`: applied to every app in `{cluster-name}` (e.g. `frankfurt`). See `jenkins/regions.yml` for more on the clusters.
3. `configs/{app-name}.env`: applied to the app named for the file in every cluster.

You'll almost always only need to edit the file for a particular app, but the others are available should you need them.

You can also delete a static environment variable from an app. Simply set the value of the variable to nothing or whitespace:

```bash
# configs to set
DUDE=Abides

# configs to delete
WALTER=
```

In the above example, if the app had `WALTER=bowling` set, then this would remove the `WALTER` environment variable from the app
via the `deis config:unset` command. It is recommended to keep deleted variables grouped together at the bottom of the env files.

Deleting a dynamic value (those in the `waffle_config` directory) is simply deleting the line from the file. The full list of configurations are refreshed every time for those values.

[Bedrock]: https://github.com/mozilla/bedrock
