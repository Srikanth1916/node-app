#!groovy

node any {
    try {
            stage('Start NodeJS Container'){
                container() {
                    image = 'node:9-slim'
                    ports = [[container: '3000', host: '3000' ]]
                }
            }
            stage('Yarn install NodeJS Packages') {
                packageInstall(pkg: 'yarn') {
                                    echo "Installing NodeJS Packages grunt & express"
                                    become = false
                                    packages = [[name:  'grunt'], [name:  'express']]
                                }
            }
            stage('Checkout deploy & run NodeJS App on port 3000') {
                // Checkout our Git Repo to obtain the app.js NodeJS Express app
                //
                checkout([$class                           : 'GitSCM',
                      branches                         : [[name: '*']],
                      doGenerateSubmoduleConfigurations: false,
                      extensions                       : [],
                      submoduleCfg                     : [],
                      userRemoteConfigs                : [[credentialsId: "pm11prince",
                                                           url          : 'https://github.com/pm11prince/node-app.git']]])
                // Copy all the contents of the current workspace dir to the / dir in the container
                containerCopy() {}
                // Run node app.js
                nodejs(args: 'app.js', background: true) {}
            }
            
            
    } catch (err) {
        echo "${err}"
        println err
            
    }finally{

       // clean up   
    }
}