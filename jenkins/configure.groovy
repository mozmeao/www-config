all_jobs = [:]
app_regions = config.regions ?: ['usw']
app_names = config.app_names ?: [env.BRANCH_NAME]
for (regionId in app_regions) {
    region = regions[regionId]
    for ( app_name in app_names ) {
        app_url = "https://${app_name}.${region.name}.moz.works"
        stageName = "Configure ${app_name}-${region.name}"
        // ensure no deploy/test cycle happens in parallel for an app/region
        lock (stageName) {
            milestone()
            stage (stageName) {
                withEnv(["DEIS_PROFILE=${region.deis_profile}",
                         "DEIS_BIN=${region.deis_bin}",
                         "DEIS_APP=${app_name}"]) {
                    sh 'bin/configure.sh'
                }
                utils.integrationTestJob(app_url)()
                utils.ircNotification([status: 'success', message: "Configured ${app_url}"])
            }
        }
    }
}
