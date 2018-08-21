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
	
	
	stage("build") {
         writeFile file: "test.txt", text: "test"
         docker.withRegistry("https://my-private-registry.intranet.net", 'docker-registry-credentials') {
             docker.image("my-private-registry.intranet.net/tool/golang").inside("-v /home/jenkins/foo.txt:/foo.txt") { c ->
                 sh 'cat /foo.txt' // we can mount any file from host
                 sh 'cat test.txt' // we can access files from workspace
                 sh 'echo "modified-inside-container" > test.txt' // we can modify files in workspace
                 sh 'go build' // we can run command from docker image
                 sh 'printenv' // jenkins is passing all envs variables into container
             }
         }
         sh 'cat test.txt' // will be "modified-inside-container" here
     }
	
	
	
	}
}



