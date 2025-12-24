pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS = '-no-color'
    }

    stages {
        // -----------------------------
        // Task 1: Provisioning & Output Capture
        // -----------------------------
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    // Task 1: Execute terraform apply with auto-approve [cite: 4]
                    sh 'terraform apply -auto-approve -var-file=dev.tfvars'
                }
            }
        }

        stage('Capture Outputs') {
            steps {
                script {
                    // Task 1: Capture instance_public_ip and instance_id into Jenkins env variables 
                    env.INSTANCE_IP = sh(script: 'terraform output -raw instance_public_ip', returnStdout: true).trim()
                    env.INSTANCE_ID = sh(script: 'terraform output -raw instance_id', returnStdout: true).trim()

                    echo "Captured EC2 IP: ${env.INSTANCE_IP}"
                    echo "Captured EC2 ID: ${env.INSTANCE_ID}"
                }
            }
        }

        // -----------------------------
        // Task 2: Dynamic Inventory Management
        // -----------------------------
        stage('Create Inventory') {
            steps {
                script {
                    // Task 2: Write captured INSTANCE_IP into dynamic_inventory.ini [cite: 7]
                    // Formatted correctly for Ansible consumption [cite: 8]
                    sh "echo '[splunk]' > dynamic_inventory.ini"
                    sh "echo '${env.INSTANCE_IP} ansible_user=ec2-user ansible_ssh_private_key_file=byod3-key.pem ansible_ssh_common_args=\"-o StrictHostKeyChecking=no\"' >> dynamic_inventory.ini"
                    
                    echo "Inventory file created successfully."
                    sh "cat dynamic_inventory.ini"
                }
            }
        }

        // -----------------------------
        // Task 3: AWS Health Status Verification
        // -----------------------------
        stage('AWS Health Check') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    script {
                        echo "Waiting for instance ${env.INSTANCE_ID} to reach 'ok' status..."
                        // Task 3: Use AWS CLI wait command to poll health status 
                        sh "aws ec2 wait instance-status-ok --instance-ids ${env.INSTANCE_ID} --region us-east-1"
                        echo "Instance health check passed. Proceeding to configuration."
                    }
                }
            }
        }

        // -----------------------------
        // Task 4: Splunk Installation & Testing
        // -----------------------------
        stage('Splunk Configuration') {
            steps {
                script {
                    // Safety: Ensure key permissions are correct before Ansible runs
                    sh 'if [ -f byod3-key.pem ]; then chmod 400 byod3-key.pem; fi'
                    
                    // Task 4: Run installation and testing playbooks 
                    sh 'ansible-playbook -i dynamic_inventory.ini playbooks/splunk.yml'
                    sh 'ansible-playbook -i dynamic_inventory.ini playbooks/test-splunk.yml'
                }
            }
        }

        // -----------------------------
        // Task 5: Infrastructure Destruction Gate
        // -----------------------------
        stage('Validate Destroy') {
            // Task 5: Implement a Validate Destroy input gate [cite: 16]
            input {
                message "Deployment complete. Verify Splunk at http://${env.INSTANCE_IP}:8000. Destroy infrastructure?"
                ok "Destroy Now"
            }
            steps {
                echo "User validated destruction."
            }
        }

        stage('Destroy Infrastructure') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    // Task 5: Destroy stage using terraform destroy [cite: 16]
                    sh 'terraform destroy -auto-approve -var-file=dev.tfvars'
                }
            }
        }
    }

    // -----------------------------
    // Task 5: Post-Build Actions
    // -----------------------------
    post {
        always {
            script {
                // Task 5: Ensure dynamic_inventory.ini is deleted [cite: 17]
                sh 'rm -f dynamic_inventory.ini'
                echo "Temporary inventory file removed."
            }
        }
        failure {
            script {
                // Task 5: Auto-trigger destroy if pipeline fails [cite: 17]
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    sh 'terraform destroy -auto-approve -var-file=dev.tfvars'
                }
            }
        }
        aborted {
            script {
                // Task 5: Auto-trigger destroy if pipeline is aborted [cite: 17]
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                    sh 'terraform destroy -auto-approve -var-file=dev.tfvars'
                }
            }
        }
    }
}