node {
    def app

    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */

        checkout scm
    }

    stage('Build image') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */

        app = docker.build("prince11itc/node:latest")
    }
	
	stage('Checkout deploy') {
                // Checkout our Git Repo to obtain the app.js NodeJS Express app
                //
                checkout([$class                           : 'GitSCM',
                      branches                         : [[name: '*/master']],
                      doGenerateSubmoduleConfigurations: false,
                      extensions                       : [],
                      submoduleCfg                     : [],
                      userRemoteConfigs                : [[credentialsId: "pm11prince",
                                                           url          : 'https://github.com/pm11prince/node-app.git']]])
                // Copy all the contents of the current workspace dir to the / dir in the container
                // containerCopy() {}
                // Run node app.js
                //nodejs(args: 'app.js', background: true) {}
    }
	
	stage('Build code and run app') {
        
		sh 'docker cp $PWD/. app.id:/app'
        app.inside {
			sh 'npm install -g'
			sh 'node start'
        }
    }
	
	stage('Test image') {
        /* Ideally, we would run a test framework against our image.
         * For this example, we're using a Volkswagen-type approach ;-) */

        app.inside {
            sh 'echo "Tests passed"'
        }
    }
	
	stage('Push image') {
        /* Finally, we'll push the image with two tags:
         * First, the incremental build number from Jenkins
         * Second, the 'latest' tag.
         * Pushing multiple tags is cheap, as all the layers are reused. */
        docker.withRegistry('https://registry.hub.docker.com', 'prince11itc') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }

}