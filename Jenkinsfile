#!groovy

@Library('github.com/mozmar/jenkins-pipeline@20170315.1')

def loadBranch(String branch) {
    // load the utility functions used below
    utils = load 'jenkins/utils.groovy'
    // defined in the Library loaded above
    setGitEnvironmentVariables()
    if ( fileExists("./jenkins/branches/${branch}.yml") ) {
        config = readYaml file: "./jenkins/branches/${branch}.yml"
        regions = readYaml file: 'jenkins/regions.yml'
        config_script = config.script ? "./jenkins/${config.script}.groovy" : './jenkins/configure.groovy'
        println "Loading ${config_script}"
        load config_script
    } else {
        println "No config for ${branch}. Nothing to do. Good bye."
        return
    }
}

node {
    stage ('Prepare') {
        checkout scm
        // save the files for later
        stash 'workspace'
    }
    loadBranch(env.BRANCH_NAME)
}
