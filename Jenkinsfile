#!groovy

pipeline {
  agent none
  stages {
    stage('Node.JS base image') {
      agent {
        docker {
          image 'node:9'
        }
      }
      steps {
		sh 'chown -R node:node /usr/local'
        sh 'npm install -g grunt express'
      }
    } 
	stage('Docker Build') {
      agent any
      steps {
        sh 'docker build -t prince11itc/node:latest .'
      }
    }
	
	 stage('Docker Push') {
      agent any
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'prince123', usernameVariable: 'prince11itc')]) {
          sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
          sh 'docker push prince11itc/node:latest'
        }
      }
    }
  }
}



