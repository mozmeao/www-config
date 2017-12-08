/**
 * Define utility functions.
 */

/**
 * Send a notice to #www on irc.mozilla.org with the build result
 *
 * @param stage step of build/deploy
 * @param result outcome of build (will be uppercased)
*/
def ircNotification(Map args) {
    def command = "bin/irc-notify.sh"
    for (arg in args) {
        command += " --${arg.key} '${arg.value}'"
    }
    sh command
}

def configAndTest(region, app_name, run_tests) {
    def app_url = "https://${app_name}.${region.name}.moz.works".toString()
    def stage_name = "Configure ${app_name}-${region.name}".toString()
    try {
        did_config = runConfiguration(region, app_name)
        if ( did_config ) {
            ircNotification([status: 'success', message: "Configured ${app_url}"])
            if ( run_tests ) {
                runTests(app_url)
            }
        } else {
            ircNotification([status: 'info', message: "No Config Necessary ${app_url}"])
        }
    } catch(err) {
        ircNotification([stage: stage_name, status: 'failure'])
        throw err
    }
}

def getConfigJob(region, app_name, run_tests) {
    def app_url = "https://${app_name}.${region.name}.moz.works".toString()
    def stage_name = "Configure ${app_name}-${region.name}".toString()
    return {
        node {
            unstash 'workspace'
            lock(stage_name) {
                try {
                    did_config = runConfiguration(region, app_name)
                    if ( did_config ) {
                        ircNotification([status: 'success', message: "Configured ${app_url}"])
                        if ( run_tests ) {
                            retry(3) {
                                runTests(app_url)
                            }
                        }
                    } else {
                        ircNotification([status: 'info', message: "No Config Necessary ${app_url}"])
                    }
                } catch(err) {
                    ircNotification([stage: stage_name, status: 'failure'])
                    throw err
                }
            }
        }
    }
}

def runTests(appURL) {
    withEnv(["BASE_URL=${appURL}"]) {
        try {
            sh 'bin/run-tests.sh'
        }
        finally {
            junit 'results/*.xml'
        }
    }
}

def runConfiguration(region, app_name) {
    withEnv(["DEIS_PROFILE=${region.deis_profile}".toString(),
             "DEIS_BIN=${region.deis_bin}".toString(),
             "DEIS_APP=${app_name}".toString()]) {
        status = sh([script: 'bin/configure.sh', returnStatus: true])
        // true means it did something
        return status == 0
    }
}

return this;
