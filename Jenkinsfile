#!groovy

pipeline {
  agent none
  stages {
    stage('Docker Build') {
      agent any
      steps {
	   sh 'echo in docker build'
	   sh 'docker build -t prince11itc/node:latest .'
        }
    }
	
	 stage('Docker Push') {
      agent any
      steps {
        withCredentials([usernamePassword(credentialsId: 'prince11itc', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
          sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
          sh 'docker push prince11itc/node:latest'
        }
      }
    }
	
	stage('Docker Pull') {
      agent any
      steps {
        withCredentials([usernamePassword(credentialsId: 'prince11itc', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
          sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
          sh 'docker pull prince11itc/node:latest'
        }
      }
    }
  }
}



