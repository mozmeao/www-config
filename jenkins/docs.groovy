sh 'bin/docker-docs.sh'
withCredentials([[$class: 'StringBinding',
                  credentialsId: 'GH_TOKEN_MOZMAR_ROBOT',
                  variable: 'GH_TOKEN']]) {
    sh 'bin/publish-docs.sh'
}
