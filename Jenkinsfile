#!groovy

pipeline {
  agent {
      dockerfile true
   }
  stages {
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



