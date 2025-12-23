pipeline {
    agent any
    
    [cite_start]// Task 2: Pipeline Environment & Credentials [cite: 6, 7, 8]
    environment {
        // Set required Terraform automation variables
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS      = '-no-color'
        
        // Inject AWS Credentials (ID must match what you saved in Jenkins)
        AWS_ACCESS_KEY_ID     = credentials('aws-creds')
        AWS_SECRET_ACCESS_KEY = credentials('aws-creds')
        
        // Inject SSH Key Credential ID
        SSH_CRED_ID           = 'ssh-key'
    }
    
    stages {
        [cite_start]// Task 3: Initialization & Variable Inspection [cite: 9, 10, 11]
        stage('Initialization') {
            steps {
                script {
                    // Initialize Terraform
                    sh 'terraform init'
                    
                    // Display the content of the branch-specific .tfvars file
                    echo "Inspecting variables for branch: ${env.BRANCH_NAME}"
                    sh "cat ${env.BRANCH_NAME}.tfvars"
                }
            }
        }
        
        [cite_start]// Task 4: Branch-Specific Terraform Planning [cite: 12, 13, 14]
        stage('Terraform Plan') {
            steps {
                // Generate plan using the variable file for the current branch
                sh "terraform plan -var-file=${env.BRANCH_NAME}.tfvars"
            }
        }
        
        [cite_start]// Task 5: Conditional Manual Approval Gate [cite: 15, 16, 17]
        stage('Validate Apply') {
            when {
                // Only ask for approval if we are on the 'dev' branch
                branch 'dev'
            }
            steps {
                // Input step acting as a manual gate
                input message: 'Plan looks good. Proceed to Apply?', ok: 'Yes, Deploy'
            }
        }
    }
}