pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS = '-no-color'
    }

    stages {

        stage('Terraform Init & Inspect') {
            steps {
                sh 'terraform init'
                sh "cat ${env.BRANCH_NAME}.tfvars"
            }
        }

        stage('Terraform Plan') {
            steps {
                sh "terraform plan -var-file=${env.BRANCH_NAME}.tfvars"
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
