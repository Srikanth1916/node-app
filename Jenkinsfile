#!groovy

pipeline {
  agent none
  stages {
    stage('Node base image') {
      agent {
        docker {
          image 'node:9'
        }
      }
      steps {
        sh 'npm install -g grunt express'
      }
    } 
  }
}