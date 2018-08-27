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
		string(name: 'NEXUS_REPO_NAME', defaultValue: 'test-repo-01', description: 'Nexus repository name')
		string(name: 'NEXUS_GROUP_NAME', defaultValue: 'node-pipeline', description: 'Nexus Group name')
		string(name: 'NEXUS_ARTIFACT_NAME', defaultValue: 'BUILD', description: 'Nexus Artifact name')
		string(name: 'NEXUS_USER_NAME', defaultValue: 'admin', description: 'Nexus repository user name')
		string(name: 'NEXUS_PASSWORD', defaultValue: 'zicosadmin', description: 'Nexus repository password')
		string(name: 'NEXUS_URL', defaultValue: 'http://54.210.74.64:8081/nexus/service/local/artifact/maven/content', description: 'Nexus repository URL')
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
			cleanup()
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
			cleanup()
			throw e
			}
			
		try {
 stage('Create Bridge') {
			sh """
			sh 'docker network create --driver bridge spadelite'
			"""
			}
		} catch (e) {
			// If there was an exception thrown, the build failed
			currentBuild.result = "FAILED"
			notifyFailedBuild('Create Bridge')
			cleanup()
			throw e
			}
			
//Pull the image from Docker hub.			
			docker.withRegistry("${params.DOCKERHUB_URL}", "${params.DOCKERHUB_CREDETIAL_ID}") {
             docker.image("${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG}").withRun('--network-alias splite --net spadelite -e "MINIO_ACCESS_KEY=mykey" -e "MINIO_SECRET_KEY=mysecret"', 'server /data').inside('--net spadelite -v $WORKSPACE:/app -u root') 
			 {
			  try {
				
 stage('Checkout code'){
			 // checkout the code in the current workspace 
		checkout(	[$class                          : 'GitSCM',
				  branches                         : [[name: '*/master']],
				  doGenerateSubmoduleConfigurations: false,
				  extensions                       : [],
				  submoduleCfg                     : [],
				  userRemoteConfigs                : [[credentialsId: "${params.GIT_CREDETIAL_ID}",
				  url          					   : "${params.GIT_URL}"]]])
			 }
			} catch (e) {
			// If there was an exception thrown, the build failed
			currentBuild.result = "FAILED"
			notifyFailedBuild('Checkout code')
			cleanup()
			throw e
			}
			 
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
			cleanup()
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
			cleanup()
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
			cleanup()
			throw e
			}
			try {		 
  stage('Push artifacts to Artifactory'){
			sh """
			touch ${env.JOB_NAME}${env.BUILD_NUMBER}.tar.gz
			tar --exclude='./server/node_modules' --exclude='./.git' --exclude='./.gitignore' --exclude=${env.JOB_NAME}${env.BUILD_NUMBER}.tar.gz -zcvf ${env.JOB_NAME}${env.BUILD_NUMBER}.tar.gz .
			curl -v \
				-F r="${params.NEXUS_REPO_NAME}" \
				-F g="${params.NEXUS_GROUP_NAME}" \
				-F a="${params.NEXUS_ARTIFACT_NAME}" \
				-F v="${env.BUILD_NUMBER}" \
				-F p="tar.gz" \
				-F file="@./${env.JOB_NAME}${env.BUILD_NUMBER}.tar.gz" \
				-u ${params.NEXUS_USER_NAME}:${params.NEXUS_PASSWORD} \
				${params.NEXUS_URL}

				""" 
			 
			 }
			 
			 } catch (e) {
			// If there was an exception thrown, the build failed
			currentBuild.result = "FAILED"
			notifyFailedBuild('Push artifacts to Artifactory')
			cleanup()
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
		    cleanup()
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
		def cleanup() {
		sh """
		docker ps -q -f status=exited | xargs --no-run-if-empty docker rm
		docker images -q -f dangling=true | xargs --no-run-if-empty docker rmi
		docker volume ls -qf dangling=true | xargs -r docker volume rm
		"""
		}