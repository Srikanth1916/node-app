#!groovy

pipeline {
  agent none
  parameters {
        string(name: 'DOCKERHUB_CREDETIAL_ID', defaultValue: 'prince11itc', description: 'Dockerhub CredentialId')
		string(name: 'DOCKER_IMAGE_NAME', defaultValue: 'prince11itc/node', description: 'Docker Image Name')
		string(name: 'DOCKER_TAG', defaultValue: 'latest', description: 'Docker Image Tag')
		}
  stages {
    stage('Docker Build') {
      agent any
      steps {
	   sh "docker build -t ${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG} ."
        }
    }
	
	 stage('Docker Push') {
      agent any
      steps {
        withCredentials([usernamePassword(credentialsId: "${params.DOCKERHUB_CREDETIAL_ID}", passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
          sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
          sh "docker push ${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG}"
        }
      }
    }
	
	stage('Docker Pull') {
      agent any
      steps {
        withCredentials([usernamePassword(credentialsId: "${params.DOCKERHUB_CREDETIAL_ID}", passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
          sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
          sh "docker pull ${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG}"
        }
      }
    }
	
	stage('test in docker') {
      agent {
        docker {
          image '${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG}'
          reuseNode true
        }
      }
      steps {
        sh "./run-tests-in-docker.sh"
      }
    }
	
		
	}
}



