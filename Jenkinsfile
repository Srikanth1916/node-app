#!groovy

pipeline {
  agent {
      dockerfile true
   }
  stages {
    stage('Docker Build') {
      agent any
      steps {
	   sh 'echo in docker build'
        }
    }
	
	 stage('Docker Push') {
      agent any
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerHub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
          sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
          sh 'docker push prince11itc/node:latest'
        }
      }
    }
  }
}



