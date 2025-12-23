pipeline {
    agent any
    
    // Task 2: Pipeline Environment & Credentials
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS      = '-no-color'
        
        // Securely injecting credentials
        AWS_ACCESS_KEY_ID     = credentials('aws-creds')
        AWS_SECRET_ACCESS_KEY = credentials('aws-creds')
        SSH_CRED_ID           = 'ssh-key'
    }
    
    stages {
        // Task 3: Initialization & Variable Inspection
        stage('Initialization') {
            steps {
                sh 'terraform init'
                // Displays variables for the current branch
                sh "cat ${env.BRANCH_NAME}.tfvars"
            }
        }
        
        // Task 4: Branch-Specific Terraform Planning
        stage('Terraform Plan') {
            steps {
                // Generates plan using specific variable file
                sh "terraform plan -var-file=${env.BRANCH_NAME}.tfvars"
            }
        }
        
        // Task 5: Conditional Manual Approval Gate
        stage('Validate Apply') {
            when {
                branch 'dev'
            }
            steps {
                input message: 'Do you want to proceed?', ok: 'Yes'
            }
        }
    }
}