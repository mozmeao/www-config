app_regions = config.regions ?: ['usw']
app_names = config.app_names ?: [env.BRANCH_NAME]
for (regionId in app_regions) {
    region = regions[regionId]
    for ( app_name in app_names ) {
        app_url = "https://${app_name}.${region.name}.moz.works".toString()
        stage_name = "Configure ${app_name}-${region.name}".toString()
        stage(stage_name) {
            lock(stage_name) {
                utils.configAndTest(region, app_name)
            }
        }
    }
}
