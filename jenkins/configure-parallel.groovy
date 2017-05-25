all_jobs = [:]
app_regions = config.regions ?: ['usw']
app_names = config.app_names ?: [env.BRANCH_NAME]

for (regionId in app_regions) {
    region = regions[regionId]
    for ( app_name in app_names ) {
        all_jobs["${app_name}-${region.name}".toString()] = utils.getConfigJob(region, app_name)
    }
}

stage('Configure & Test') {
    parallel all_jobs
}
