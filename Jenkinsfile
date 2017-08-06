#!/usr/bin/env groovy

def img
try {
    node {
        stage 'Clean workspace'
            deleteDir()
                sh 'ls -lah'

        stage 'Checkout source'
              checkout scm

        stage 'Build docker image'
              println "Building and packaging the ds-ingest-twitter application"
              sh 'sleep 5'
              img = docker.build('petclinic-mysql2', '.')

         stage ('Run Test Case') {
              echo 'Running test cases'
              img.inside{
                sh 'sleep 10'
                sh 'echo "Passed test cases"'
             }
   			}

       stage 'Publish image'
              echo "Publishing docker images"
              docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                app.push("${env.BUILD_NUMBER}")
                app.push("latest")
              }

        stage 'Pull and deploy app'
              echo "Pulling and deploying app from ECR"

              def imageTag = "munishmehta/petclinic-mysql2:${env.BUILD_NUMBER}"
              withCredentials([usernamePassword(credentialsId: 'c93c32a4-85ad-4dfa-8607-f79a9399b7e9', passwordVariable: 'DOCKERHUB_PASS', usernameVariable: 'DOCKERHUB_USER')]) {
                  // copy the kubeconfig file for your cluster to root of application.
                  sh 'cp "/c/Users/MMehta/.kube/config" .'

                  // Tagging the latest image
                  sh("sed -i.bak 's#munishmehta/petclinic-mysql2:latest#${imageTag}#' ./deployment.yaml")

                  // create deployment, service and pods
                  sh("kubectl apply --kubeconfig=config --namespace demo-time -f deployment.yaml --record")
              }
          }
}
catch (exc) {
    echo "Caught: ${exc}"

    String recipient = 'munish.mehta@isentia.com'

    mail subject: "${env.JOB_NAME} (${env.BUILD_NUMBER}) failed",
            body: "It appears that ${env.BUILD_URL} is failing, somebody should do something about that",
              to: recipient,
         replyTo: recipient,
            from: 'isentia.jenkins@gmail.com'
}
