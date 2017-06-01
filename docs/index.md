# Bedrock Configurator

This is the documentation for the configuration system for [Bedrock][] instances.

## Quick Start

Let's say you want to flip a switch in prod. Follow the following procedure:

1. Clone the `mozmar/www-config` repo.
2. Fork the repo into your Github account.
3. Edit the `configs/bedrock-prod.env` file to add the name and value you need. You'd add a line like `SWITCH_DO_PHRASING=on` to set that key and value in the environment for prod. Or you can find the line that already has the variable you need and change the value if it already exists.
4. Commit the change.
5. Push the change to a branch on your fork.
6. Submit a pull-request against the `www-config` repo.
7. Ask for a review in the `#www` IRC channel or in the PR itself.
8. Once the PR is reviewed and merged it can be applied: `git pull origin master && ./set-config bedrock-prod` (assuming `origin` is your remote name for the `mozmar` repo)

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

The configurations are in the `configs` directory in the repo. They are simple environment files in the [format usable by Foreman](https://ddollar.github.io/foreman/#ENVIRONMENT). The final list of variables to apply will be the mix of 3 possible files.

1. `configs/global.env`: applied to every app.
2. `configs/{cluster-name}.env`: applied to every app in `{cluster-name}` (e.g. `usw` or `virginia`). See `jenkins/regions.yml` for more on the clusters.
3. `configs/{app-name}.env`: applied to the app named for the file in every cluster.

You'll almost always only need to edit the file for a particular app, but the others are available should you need them.

[Bedrock]: https://github.com/mozilla/bedrock
