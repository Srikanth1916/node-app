node {
    def app
	def app1
    stage('Build image') {
        
        app = docker.build("prince11itc/node:${env.BUILD_NUMBER}")
    }
	
	stage('Push image') {
        
		docker.withRegistry('https://registry.hub.docker.com', 'prince11itc') {
            app.push("${env.BUILD_NUMBER}")
            //app.push("latest")
        }
    }
	
	
	
	stage('pull the image, Checkout & Build code and run app') {
	
	checkout(		  [$class                          : 'GitSCM',
                      branches                         : [[name: '*/master']],
                      doGenerateSubmoduleConfigurations: false,
                      extensions                       : [],
                      submoduleCfg                     : [],
                      userRemoteConfigs                : [[credentialsId: "pm11prince",
                                                           url          : 'https://github.com/pm11prince/node-app.git']]])
			
			 docker.withRegistry('https://registry.hub.docker.com', 'prince11itc') {
             docker.image("prince11itc/node:${env.BUILD_NUMBER}").inside('-v $WORKSPACE:/app -u root') 
			 {
		  sh """
			 cd /app/server
			 npm install -g
			 npm install sonarqube-scanner@2.8 --save-dev
			 
			 cat > sonar-project.js <<- "EOF"
			 const sonarqubeScanner = require('sonarqube-scanner');
			 sonarqubeScanner({
			 serverUrl: 'http://ec2-54-173-54-193.compute-1.amazonaws.com:9000/',
			 options : {
			'sonar.sources': '.',
			'sonar.inclusions' : 'server/**' // Entry point of your code
			}
			}, () => {});
			EOF
			ls /app/server
			 node sonar-project.js
			 forever start server.js
			 """ 
             }
         }
	}
	
	
	
	
}