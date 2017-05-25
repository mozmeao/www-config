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

def integrationTestJob(appURL) {
    return {
        node {
            unstash 'workspace'
            withEnv(["BASE_URL=${appURL}"]) {
                retry(1) {
                    try {
                        sh 'bin/run-tests.sh'
                    }
                    finally {
                        junit 'results/*.xml'
                    }
                }
            }
        }
    }
}

return this;
