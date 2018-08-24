#!/usr/bin/env groovy

def tag

pipeline {
  agent any
  parameters {
		string(name: 'DOCKERHUB_URL', defaultValue: 'https://registry.hub.docker.com', description: 'Dockerhub Url')
        string(name: 'DOCKERHUB_CREDETIAL_ID', defaultValue: 'prince11itc', description: 'Dockerhub CredentialId')
		string(name: 'DOCKER_IMAGE_NAME', defaultValue: 'prince11itc/node', description: 'Docker Image Name')
		string(name: 'DOCKER_TAG', defaultValue: 'latest', description: 'Docker Image Tag')
		string(name: 'GIT_URL', defaultValue: 'https://github.com/pm11prince/node-app.git', description: 'Git Url')
		string(name: 'SONARQUBE_URL', defaultValue: 'http://ec2-54-156-240-215.compute-1.amazonaws.com:9000/', description: 'SonarQube Url')
		string(name: 'SONARQUBE_PROJECT_NAME', defaultValue: 'Node-Project', description: 'SonarQube Project Name')
		string(name: 'Email_List', defaultValue: 'prince.mathew@itcinfotech', description: 'Emails')
		string(name: 'NODE_PACKAGE_LIST', defaultValue: 'forever,sonarqube-scanner', description: 'Provide the comma separated Node package list which should be installed on the new Docker container. Like forever,sonarqube-scanner ')
		}
	stages {
        stage('params') {
            steps { 
                script {
    def app
	
	try {
		//notifyBuild('STARTED')
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
		
	stage('Push image') {
        
		docker.withRegistry("${params.DOCKERHUB_URL}", "${params.DOCKERHUB_CREDETIAL_ID}") {
            app.push("${env.BUILD_NUMBER}")
            app.push("${params.DOCKER_TAG}")
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
	
	checkout(		  [$class                          : 'GitSCM',
                      branches                         : [[name: '*/master']],
                      doGenerateSubmoduleConfigurations: false,
                      extensions                       : [],
                      submoduleCfg                     : [],
                      userRemoteConfigs                : [[credentialsId: "${params.DOCKERHUB_CREDETIAL_ID}",
                                                           url          : "${params.GIT_URL}"]]])
			
			
			docker.withRegistry("${params.DOCKERHUB_URL}", "${params.DOCKERHUB_CREDETIAL_ID}") {
             docker.image("${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG}").inside('-v $WORKSPACE:/app -u root') 
			 {
			 try {
				notifyBuild('STARTED')

			 stage('Build npm'){
			 sh """
			 cd /app/server
			
			 npm install -g
			 npm install sonarqube-scanner --save-dev
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
			 
			 cat > sonar-project.js <<- "EOF"
			 const sonarqubeScanner = require('sonarqube-scanner');
			 sonarqubeScanner({
			 serverUrl: "${params.SONARQUBE_URL}",
			 options : {
			'sonar.sources': '.',
			'sonar.projectName': "${params.SONARQUBE_PROJECT_NAME}",
			'sonar.inclusions' : '.', // Entry point of your code
			'sonar.exclusions' : 'node_modules/**'
			}
			}, () => {});
			EOF
			
			node sonar-project.js
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
			 forever start server.js
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
	}
def notifyBuild(String buildStatus = 'STARTED') {
// build status of null means successful
buildStatus =  buildStatus ?: 'SUCCESSFUL'

emailext(
  to: 'prince.mathew@itcinfotech.com',
  subject: "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
  body: "details",
  recipientProviders: [[$class: 'DevelopersRecipientProvider']]
)
}