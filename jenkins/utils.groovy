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

def configAndTest(region, app_name) {
    try {
        status = sh([script: "bin/config-diff.py -r ${region.deis_profile} ${app_name}", returnStatus: true])
        if ( status == 0 ) {
            runConfiguration(region, app_name)
            runTests(app_url)
            ircNotification([status: 'success', message: "Configured ${app_url}"])
        } else {
            ircNotification([status: 'info', message: "No Config Necessary ${app_url}"])
        }
    } catch(err) {
        ircNotification([stage: stage_name, status: 'failure'])
        throw err
    }
}

def getConfigJob(region, app_name) {
    def app_url = "https://${app_name}.${region.name}.moz.works".toString()
    def stage_name = "Configure ${app_name}-${region.name}".toString()
    return {
        node {
            unstash 'workspace'
            lock(stage_name) {
                configAndTest(region, app_name)
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
        sh 'bin/configure.sh'
    }
}

return this;
