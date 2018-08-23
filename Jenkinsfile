node {
    def app
	
    stage('Build image') {
        
        app = docker.build("prince11itc/node:${env.BUILD_NUMBER}")
    }
	
	stage('Push image') {
        
		docker.withRegistry('https://registry.hub.docker.com', 'prince11itc') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
	
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
			 
			 stage(Build npm ){
			 sh """
			 cd /app/server
			 npm install -g
			 npm install sonarqube-scanner --save-dev
			 """ 
			 }
			 
			 stage(Sonar Analysis){
			 sh """
			 cd /app/server
			 
			 cat > sonar-project.js <<- "EOF"
			 const sonarqubeScanner = require('sonarqube-scanner');
			 sonarqubeScanner({
			 serverUrl: 'http://ec2-54-156-240-215.compute-1.amazonaws.com:9000/',
			 options : {
			'sonar.sources': '.',
			'sonar.projectName': 'Node-Project',
			'sonar.language': 'js',
			'sonar.inclusions' : 'server/**,resources/**' // Entry point of your code
			}
			}, () => {});
			EOF
			
			node sonar-project.js
			""" 
			 }
			 
			 stage(Start the Node App){
			 sh """
			  cd /app/server
			 forever start server.js
			 """ 
			 }
             }
         }
	
}