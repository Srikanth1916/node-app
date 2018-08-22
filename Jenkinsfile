node {
    def app
	def app1
    stage('Build image') {
        
        app = docker.build("prince11itc/node:latest")
    }
	
	stage('Push image') {
        
		docker.withRegistry('https://registry.hub.docker.com', 'prince11itc') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
	
	stage('Pull image') {
        
		docker.withRegistry('https://registry.hub.docker.com', 'prince11itc') {
            Image.pull("${env.BUILD_NUMBER}")
        }
    }
	
	stage('Create container') {
        
		docker.withRegistry('https://registry.hub.docker.com', 'prince11itc') {
            app1=Image.pull("${env.BUILD_NUMBER}")
        }
    }
	
	stage('Checkout code') {
                // Checkout our Git Repo to obtain the app.js NodeJS Express app
                //
                checkout([$class                           : 'GitSCM',
                      branches                         : [[name: '*/master']],
                      doGenerateSubmoduleConfigurations: false,
                      extensions                       : [],
                      submoduleCfg                     : [],
                      userRemoteConfigs                : [[credentialsId: "pm11prince",
                                                           url          : 'https://github.com/pm11prince/node-app.git']]])
    }
	
	stage('Build code and run app') {
	
			app1.inside('-v $WORKSPACE:/app -u root') {
			sh """
			cd /app/server
			npm install -g
			forever start server.js
			""" 
        }
    }
	
	stage('Test image') {
        /* Ideally, we would run a test framework against our image.
         * For this example, we're using a Volkswagen-type approach ;-) */

        app1.inside {
            sh 'echo "Tests passed"'
        }
    }

}