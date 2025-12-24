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

        stage('Terraform Apply') {
            steps {
                sh "terraform apply -auto-approve -var-file=${env.BRANCH_NAME}.tfvars"
            }
        }

        stage('Capture Terraform Outputs') {
            steps {
                script {
                    env.INSTANCE_IP = sh(
                        script: "terraform output -raw instance_public_ip",
                        returnStdout: true
                    ).trim()

                    env.INSTANCE_ID = sh(
                        script: "terraform output -raw instance_id",
                        returnStdout: true
                    ).trim()

                    echo "Captured INSTANCE_IP = ${env.INSTANCE_IP}"
                    echo "Captured INSTANCE_ID = ${env.INSTANCE_ID}"
                }
            }
        }
    }
}
