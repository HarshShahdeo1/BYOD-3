pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS = '-no-color'
    }

    stages {
        // -----------------------------
        // Task 1: Provisioning
        // -----------------------------
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
                    sh 'terraform apply -auto-approve -var-file=dev.tfvars'
                }
            }
        }

        // -----------------------------
        // Task 1 & 2: Output Capture & Inventory
        // -----------------------------
        stage('Capture Outputs & Create Inventory') {
            steps {
                script {
                    // Task 1: Capture Variables [cite: 5]
                    env.INSTANCE_IP = sh(script: 'terraform output -raw instance_public_ip', returnStdout: true).trim()
                    env.INSTANCE_ID = sh(script: 'terraform output -raw instance_id', returnStdout: true).trim()

                    echo "Captured EC2 IP: ${env.INSTANCE_IP}"
                    echo "Captured EC2 ID: ${env.INSTANCE_ID}"

                    // Task 2: Create Dynamic Inventory File [cite: 7, 8]
                    sh "echo '[splunk]' > dynamic_inventory.ini"
                    sh "echo '${env.INSTANCE_IP} ansible_user=ec2-user ansible_ssh_private_key_file=byod3-key.pem ansible_ssh_common_args=\"-o StrictHostKeyChecking=no\"' >> dynamic_inventory.ini"
                    
                    sh "cat dynamic_inventory.ini"
                }
            }
        }

        // -----------------------------
        // Task 3: AWS Health Verification
        // -----------------------------
        stage('AWS Health Check') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    script {
                        echo "Waiting for instance ${env.INSTANCE_ID} to be fully healthy..."
                        // Task 3: Poll until 2/2 checks pass [cite: 10, 11]
                        sh "aws ec2 wait instance-status-ok --instance-ids ${env.INSTANCE_ID} --region us-east-1"
                        echo "Instance is healthy. Proceeding..."
                    }
                }
            }
        }

        // -----------------------------
        // Task 4: Splunk Installation & Testing
        // -----------------------------
        stage('Splunk Installation & Testing') {
            steps {
                script {
                    echo "Starting Splunk Installation..."
                    
                    // Safety check: Fix key permissions if Terraform created it locally
                    sh 'if [ -f byod3-key.pem ]; then chmod 400 byod3-key.pem; fi'
                    
                    // Task 4 Part A: Install Splunk [cite: 13]
                    sh 'ansible-playbook -i dynamic_inventory.ini playbooks/splunk.yml'
                    
                    // Task 4 Part B: Verify Service is Active [cite: 14]
                    sh 'ansible-playbook -i dynamic_inventory.ini playbooks/test-splunk.yml'
                }
            }
        }

        // -----------------------------
        // Task 5: Destruction Gate
        // -----------------------------
        stage('Validate Destroy') {
            input {
                message "Do you want to destroy the infrastructure?"
                ok "Destroy"
            }
            steps {
                echo "Proceeding with destruction..."
            }
        }

        stage('Terraform Destroy') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    // Task 5: Destroy resources 
                    sh 'terraform destroy -auto-approve -var-file=dev.tfvars'
                }
            }
        }
    }

    // -----------------------------
    // Task 5: Post-Build Cleanup
    // -----------------------------
    post {
        always {
            script {
                echo "Cleaning up temporary files..."
                // Task 5: Ensure inventory file is deleted [cite: 17]
                sh 'rm -f dynamic_inventory.ini'
            }
        }
        failure {
            script {
                echo "Pipeline failed! Triggering automatic destroy..."
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    // Task 5: Auto-destroy on failure [cite: 17]
                    sh 'terraform destroy -auto-approve -var-file=dev.tfvars'
                }
            }
        }
        aborted {
            script {
                echo "Pipeline aborted! Triggering automatic destroy..."
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    // Task 5: Auto-destroy on abort [cite: 17]
                    sh 'terraform destroy -auto-approve -var-file=dev.tfvars'
                }
            }
        }
    }
}