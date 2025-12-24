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

        stage('Capture Outputs & Create Inventory') {
            steps {
                script {
                    // Task 1: Capture Variables
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

                    // Task 2: Create Dynamic Inventory File 
                    // We write the [splunk] header and the IP with SSH details [cite: 8]
                    sh "echo '[splunk]' > dynamic_inventory.ini"
                    sh "echo '${env.INSTANCE_IP} ansible_user=ec2-user ansible_ssh_private_key_file=byod3-key.pem ansible_ssh_common_args=\"-o StrictHostKeyChecking=no\"' >> dynamic_inventory.ini"
                    
                    // Verify file creation
                    sh "cat dynamic_inventory.ini"
                }
            }
        }

        stage('AWS Health Check') {
            steps {
                // Task 3: Wait for Instance Status Checks [cite: 10]
                // We reuse the 'aws-creds' so the AWS CLI can authenticate
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    script {
                        echo "Waiting for instance ${env.INSTANCE_ID} to be fully healthy..."
                        // NOTE: Ensure the region matches your dev.tfvars (e.g., us-east-1)
                        sh "aws ec2 wait instance-status-ok --instance-ids ${env.INSTANCE_ID} --region us-east-1"
                        echo "Instance is healthy. Proceeding..."
                    }
                }
            }
        }
    }
}