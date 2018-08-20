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
        sh 'npm install -g grunt express'
      }
    } 
	stage('Docker Build') {
      agent any
      steps {
        sh 'docker build -t prince11itc/node:latest .'
      }
    }
  }
}



