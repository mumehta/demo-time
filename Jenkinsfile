#!/usr/bin/env groovy

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
              def img = docker.build('ds-ingest-twitter', '.')

         stage ('Run Test Case') {
              echo 'Running test cases'
             docker.image('ds-ingest-twitter').inside{
              sh 'invoke test'
             }
   			  echo "Passed test cases"
        }

       stage 'Publish image'
              echo "Publishing docker images"
              sh "\$(aws ecr get-login --region ap-southeast-2)"
              // need the following steps below if the token has expired.
              sh  '''
                    aws_login=$(aws ecr get-login --region ap-southeast-2)
                    if echo "$aws_login" | grep -q -E '^docker login -u AWS -p \\S{1092} -e none https://[0-9]{12}.dkr.ecr.\\S+.amazonaws.com$'; then $aws_login; fi
                  '''
              docker.withRegistry('https://077077460384.dkr.ecr.ap-southeast-2.amazonaws.com', 'ecr:ap-southeast-2:AWS-SVC-ECS') {
                  docker.image('ds-ingest-twitter').push('latest')
                  docker.image('ds-ingest-twitter').push("build-develop-${env.BUILD_NUMBER}")
                }

        stage 'Pull and deploy app'
              echo "Pulling and deploying app from ECR"

              def imageTag = "077077460384.dkr.ecr.ap-southeast-2.amazonaws.com/ds-ingest-twitter:build-develop-${env.BUILD_NUMBER}"

              withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'b0097933-cea0-4729-8b7a-1e1f8702299f', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                  // copy the kubeconfig file for your cluster to root of application.
                  sh 'aws s3 cp s3://isentia-kube-config/dev/kubeconfig .'

                  // Tagging the latest image
                  sh("sed -i.bak 's#077077460384.dkr.ecr.ap-southeast-2.amazonaws.com/ds-ingest-twitter:latest#${imageTag}#' ./deployment.yaml")

                  // create deployment, service and pods
                  sh("kubectl apply --kubeconfig=kubeconfig --namespace daas-social -f deployment.yaml --record")

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
