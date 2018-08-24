#!/usr/bin/env groovy

def tag

pipeline {
  agent any
  parameters {
        string(name: 'DOCKERHUB_CREDETIAL_ID', defaultValue: 'prince11itc', description: 'Dockerhub CredentialId')
		string(name: 'DOCKER_IMAGE_NAME', defaultValue: 'prince11itc/node', description: 'Docker Image Name')
		string(name: 'DOCKER_TAG', defaultValue: 'latest', description: 'Docker Image Tag')
		string(name: 'Email_List', defaultValue: 'prince.mathew@itcinfotech', description: 'Emails')
		}
	stages {
        stage('params') {
            steps { 
                script {
    def app
	
	try {
		//notifyBuild('STARTED')
    stage('Build image') {
        
        app = docker.build("prince11itc/node:${tag}")
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
        
		docker.withRegistry('https://registry.hub.docker.com', 'prince11itc') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
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
                      userRemoteConfigs                : [[credentialsId: "pm11prince",
                                                           url          : 'https://github.com/pm11prince/node-app.git']]])
			
			 docker.withRegistry('https://registry.hub.docker.com', 'prince11itc') {
             docker.image("prince11itc/node:latest}").inside('-v $WORKSPACE:/app -u root') 
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
			 serverUrl: 'http://ec2-54-156-240-215.compute-1.amazonaws.com:9000/',
			 options : {
			'sonar.sources': 'server/**,resources/**',
			'sonar.projectName': 'Node-Project',
			'sonar.inclusions' : 'server/**,resources/**' // Entry point of your code
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
            }
        }
    }
	}
