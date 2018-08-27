#!/usr/bin/env groovy

pipeline {
  agent any
  //All parameters which will be used to run the pipeline.
  parameters {
		string(name: 'DOCKERHUB_URL', defaultValue: 'https://registry.hub.docker.com', description: 'Dockerhub Url')
        string(name: 'DOCKERHUB_CREDETIAL_ID', defaultValue: 'prince11itc', description: 'Dockerhub CredentialId')
		string(name: 'GIT_CREDETIAL_ID', defaultValue: 'pm11prince', description: 'Dockerhub CredentialId')
		string(name: 'DOCKER_IMAGE_NAME', defaultValue: 'prince11itc/node-base-img', description: 'Docker Image Name')
		string(name: 'DOCKER_TAG', defaultValue: 'latest', description: 'Docker Image Tag')
		string(name: 'GIT_URL', defaultValue: 'https://github.com/pm11prince/node-app.git', description: 'Git Url')
		string(name: 'SONARQUBE_URL', defaultValue: 'http://ec2-54-156-240-215.compute-1.amazonaws.com:9000/', description: 'SonarQube Url')
		string(name: 'SONARQUBE_PROJECT_NAME', defaultValue: 'Node-Project', description: 'SonarQube Project Name')
		string(name: 'Email_List', defaultValue: '', description: 'Emails for the notification')
		
		}
  stages {
    stage('Collect the parameters') {
      steps { 
   script {
		
    def app
	
	try {
	
  stage('Build image') {
        app = docker.build("${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG}")
    }
	} catch (e) {
			// If there was an exception thrown, the build failed.
			currentBuild.result = "FAILED"
			notifyFailedBuild('Build image')
			throw e
			}
	
		try {
			
		//Push the image into Docker hub	
  stage('Push image') {
        
		docker.withRegistry("${params.DOCKERHUB_URL}", "${params.DOCKERHUB_CREDETIAL_ID}") {
            app.push("${env.BUILD_NUMBER}")//tag the image with the current build no.
            app.push("${params.DOCKER_TAG}") // tag the image with the param tag
			}
		}
		} catch (e) {
			// If there was an exception thrown, the build failed
			currentBuild.result = "FAILED"
			notifyFailedBuild('Push image')
			throw e
			}
				
// checkout the code in the current workspace 
	  checkout(	[$class                          : 'GitSCM',
				  branches                         : [[name: '*/master']],
				  doGenerateSubmoduleConfigurations: false,
				  extensions                       : [],
				  submoduleCfg                     : [],
				  userRemoteConfigs                : [[credentialsId: "${params.GIT_CREDETIAL_ID}",
				  url          					   : "${params.GIT_URL}"]]])
			
//Pull the image from Docker hub.			
			docker.withRegistry("${params.DOCKERHUB_URL}", "${params.DOCKERHUB_CREDETIAL_ID}") {
             docker.image("${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG}").inside('-v $WORKSPACE:/app -u root') 
			 {
			 try {
				
 stage('Build NPM'){
			 sh """
			 cd /app/server
			
			 npm install -g #Build the code using NPM
			 npm install sonarqube-scanner --save-dev #install sonarqube-scanner
			 """ 
			 }
			 } catch (e) {
			// If there was an exception thrown, the build failed
			currentBuild.result = "FAILED"
			notifyFailedBuild('Build NPM')
			throw e
			}
			 
			 try {
			 			 
 stage('Sonar Analysis'){
			 sh """
			 cd /app/server
			 
			 #create the temporary .js file to execute the sonar scan.
			 cat > sonar-project.js <<- "EOF"
			 const sonarqubeScanner = require('sonarqube-scanner');
			 sonarqubeScanner({
			 serverUrl: "${params.SONARQUBE_URL}",// Sonar server url param
			 options : {
			'sonar.sources': '.',
			'sonar.projectName': "${params.SONARQUBE_PROJECT_NAME}", //Name of the project which will be created in the Sonar server
			}
			}, () => {});
			EOF
			
			node sonar-project.js //execute the sonar scan
			rm sonar-project.js
			""" 
			 }
			 
			 } catch (e) {
			// If there was an exception thrown, the build failed
			currentBuild.result = "FAILED"
			notifyFailedBuild('Sonar Analysis')
			throw e
			}
			
			try {
			
  stage('Start the Node App'){
			 sh """
			  cd /app/server
			 forever start server.js //start the app
			 """ 
			 }
			 } catch (e) {
			// If there was an exception thrown, the build failed
			currentBuild.result = "FAILED"
			notifyFailedBuild('Start the Node App')
			throw e
			}
			try {		 
  stage('Push artifacts to Artifactory'){
			sh """
			touch ${env.JOB_NAME}${env.BUILD_NUMBER}.tar.gz
			tar --exclude='./server/node_modules' --exclude='./.git' --exclude='./.gitignore' --exclude=${env.JOB_NAME}${env.BUILD_NUMBER}.tar.gz -zcvf ${env.JOB_NAME}${env.BUILD_NUMBER}.tar.gz .
			curl -v \
				-F r="test-repo-01" \
				-F v="BUILD_"${env.BUILD_NUMBER} \
				-F p="tar.gz" \
				-F file="@./${env.JOB_NAME}${env.BUILD_NUMBER}.tar.gz" \
				-u admin:zicosadmin \
				http://54.210.74.64:8081/nexus/service/local/artifact/maven/content

				""" 
			 
			 }
			 
			 } catch (e) {
			// If there was an exception thrown, the build failed
			currentBuild.result = "FAILED"
			notifyFailedBuild('Push artifacts to Artifactory')
			throw e
			} 
			
          }
         }
		}
       }
      }
    }
	post { 
        always { 
            cleanWs()
        }
		
    }
}     

// function to handle the failed build notification.
		def notifyFailedBuild(String stage) {
		
		emailext(
		  to: emailextrecipients([[$class: 'DevelopersRecipientProvider'],[$class: 'CulpritsRecipientProvider'],[$class: 'RequesterRecipientProvider']]),,
		  subject: "Build Failed: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
		  body: "This email is to notify that Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' has been failed. Failed stage: [${stage}]"
		)
		}
		
// function to handle successful build notification.
		def notifySuccessBuild() {
		
		emailext(
		  to: emailextrecipients([[$class: 'DevelopersRecipientProvider'],[$class: 'CulpritsRecipientProvider'],[$class: 'RequesterRecipientProvider']]),,
		  subject: "Build Success: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
		  body: "This email is to notify that Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' has been completed successfully"
		)
		}