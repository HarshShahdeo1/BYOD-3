pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS = '-no-color'
    }

    stages {

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            environment {
                AWS_ACCESS_KEY_ID     = credentials('aws-creds').usr
                AWS_SECRET_ACCESS_KEY = credentials('aws-creds').psw
            }
            steps {
                sh "terraform plan -var-file=${BRANCH_NAME}.tfvars"
            }
        }

        stage('Validate Apply') {
            when {
                branch 'dev'
            }
            steps {
                input message: "Do you want to proceed with the deployment to dev?",
                      ok: "Approve"
            }
        }
    }
}
