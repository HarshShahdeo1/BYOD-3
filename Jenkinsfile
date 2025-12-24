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
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                      terraform apply -auto-approve -var-file=dev.tfvars
                    '''
                }
            }
        }

        stage('Capture Terraform Outputs') {
            steps {
                script {
                    env.INSTANCE_IP = sh(
                        script: 'terraform output -raw instance_public_ip',
                        returnStdout: true
                    ).trim()

                    env.INSTANCE_ID = sh(
                        script: 'terraform output -raw instance_id',
                        returnStdout: true
                    ).trim()

                    echo "Captured EC2 IP: ${env.INSTANCE_IP}"
                    echo "Captured EC2 ID: ${env.INSTANCE_ID}"
                }
            }
        }
    }
}
