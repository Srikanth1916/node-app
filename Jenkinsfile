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
	
	
	
	stage('pull the image, Build code and run app') {
	
	checkout([$class                           : 'GitSCM',
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
			forever start server.js
			""" 
             }
         }
	}
	
	
}