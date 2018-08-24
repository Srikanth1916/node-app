#!/usr/bin/env groovy

pipeline {
  agent any
  //All parameters which will be used to run the pipeline.
  parameters {
		string(name: 'DOCKERHUB_URL', defaultValue: 'https://registry.hub.docker.com', description: 'Dockerhub Url')
        string(name: 'DOCKERHUB_CREDETIAL_ID', defaultValue: 'prince11itc', description: 'Dockerhub CredentialId')
		string(name: 'DOCKER_IMAGE_NAME', defaultValue: 'prince11itc/node', description: 'Docker Image Name')
		string(name: 'DOCKER_TAG', defaultValue: 'latest', description: 'Docker Image Tag')
		string(name: 'GIT_URL', defaultValue: 'https://github.com/pm11prince/node-app.git', description: 'Git Url')
		string(name: 'SONARQUBE_URL', defaultValue: 'http://ec2-54-156-240-215.compute-1.amazonaws.com:9000/', description: 'SonarQube Url')
		string(name: 'SONARQUBE_PROJECT_NAME', defaultValue: 'Node-Project', description: 'SonarQube Project Name')
		string(name: 'Email_List', defaultValue: 'prince.mathew@itcinfotech', description: 'Emails')
		
		}
  stages {
        stage('Collect the Job parameters') {
            steps { 
                script {
		
    def app
	
	try {
	notifyBuild('STARTED')
  stage('Build image') {
        
        app = docker.build("${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG}")
    }
	} catch (e) {
			// If there was an exception thrown, the build failed
			currentBuild.result = "FAILED"
			throw e
			} finally {
			// Success or failure, always send notifications
			notifyBuild(currentBuild.result)
			}
	
		try {
			notifyBuild('STARTED')
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
				throw e
				} finally {
				// Success or failure, always send notifications
				notifyBuild(currentBuild.result)
				}
				
// checkout the code in the current workspace 
	  checkout(	[$class                          : 'GitSCM',
				  branches                         : [[name: '*/master']],
				  doGenerateSubmoduleConfigurations: false,
				  extensions                       : [],
				  submoduleCfg                     : [],
				  userRemoteConfigs                : [[credentialsId: "${params.DOCKERHUB_CREDETIAL_ID}",
				  url          					   : "${params.GIT_URL}"]]])
			
//Pull the image from Docker hub.			
			docker.withRegistry("${params.DOCKERHUB_URL}", "${params.DOCKERHUB_CREDETIAL_ID}") {
             docker.image("${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG}").inside('-v $WORKSPACE:/app -u root') 
			 {
			 try {
				
			notifyBuild('STARTED')

 stage('Build npm'){
			 sh """
			 cd /app/server
			
			 npm install -g /*build the code with npm*/
			 npm install sonarqube-scanner --save-dev /*install the sonarqube-scanner*/
			 """ 
			 }
			 } catch (e) {
			// If there was an exception thrown, the build failed
			currentBuild.result = "FAILED"
			throw e
			} finally {
			// Success or failure, always send notifications
			notifyBuild(currentBuild.result)
			}
			 
			 try {
			 notifyBuild('STARTED')
			 
 stage('Sonar Analysis'){
			 sh """
			 cd /app/server
			 
			 // create the temporary .js file to execute the sonar scan.
			 cat > sonar-project.js <<- "EOF"
			 const sonarqubeScanner = require('sonarqube-scanner');
			 sonarqubeScanner({
			 serverUrl: "${params.SONARQUBE_URL}",// Sonar server url param
			 options : {
			'sonar.sources': '.',
			'sonar.projectName': "${params.SONARQUBE_PROJECT_NAME}", //Name of the project which will be created in the Sonar server
			'sonar.inclusions' : '.', // 
			'sonar.exclusions' : 'node_modules/**' //exclude the node modules from the scan
			}
			}, () => {});
			EOF
			
			node sonar-project.js //execute the sonar scan
			""" 
			 }
			 
			 } catch (e) {
			// If there was an exception thrown, the build failed
			currentBuild.result = "FAILED"
			throw e
			} finally {
			// Success or failure, always send notifications
			notifyBuild(currentBuild.result)
			}
			
			try {
			notifyBuild('STARTED')
  stage('Start the Node App'){
			 sh """
			  cd /app/server
			 forever start server.js //start the app
			 """ 
			 }
			 } catch (e) {
			// If there was an exception thrown, the build failed
			currentBuild.result = "FAILED"
			throw e
			} finally {
			// Success or failure, always send notifications
			notifyBuild(currentBuild.result)
			}
             }
         }
		}
       }
      }
    }
}     // function to handle the notification.
		def notifyBuild(String buildStatus = 'STARTED') {
		// build status of null means successful
		buildStatus =  buildStatus ?: 'SUCCESSFUL'

		emailext(
		  to: '${params.Email_List}',
		  subject: "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
		  body: "This is sample email related to job status",
		  recipientProviders: [[$class: 'DevelopersRecipientProvider']]
		)
		}