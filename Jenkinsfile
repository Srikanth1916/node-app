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
	   sh 'docker build -t ${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG}" .'
        }
    }
	
	 stage('Docker Push') {
      agent any
      steps {
        withCredentials([usernamePassword(credentialsId: 'prince11itc', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
          sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
          sh "docker push ${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG}"
        }
      }
    }
	
	stage('Docker Pull') {
      agent any
      steps {
        withCredentials([usernamePassword(credentialsId: ${params.DOCKERHUB_CREDETIAL_ID}, passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
          sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
          sh "docker pull ${params.DOCKER_IMAGE_NAME}:${params.DOCKER_TAG}"
        }
      }
    }
	
	stage('Docker Pull') {
	
	docker.image("prince11itc/node:latest").inside("-v /home/jenkins/foo.txt:/foo.txt") { c ->
                 sh 'cat /foo.txt' // we can mount any file from host
                 sh 'cat test.txt' // we can access files from workspace
                 sh 'echo "modified-inside-container" > test.txt' // we can modify files in workspace
                 sh 'go build' // we can run command from docker image
                 sh 'printenv' // jenkins is passing all envs variables into container
             }
  }
  }
}



