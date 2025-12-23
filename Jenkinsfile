pipeline {
    agent any
    
    environment {
        // Task 2: Required Environment Variables [cite: 7]
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS      = '-no-color'
        
        // Task 2: Secure Credential Injection 
        AWS_ACCESS_KEY_ID     = credentials('aws-creds')
        AWS_SECRET_ACCESS_KEY = credentials('aws-creds')
        SSH_CRED_ID           = 'ssh-key'
    }
    
    stages {
        // Task 3: Initialization & Variable Inspection [cite: 10, 11]
        stage('Initialization') {
            steps {
                sh 'terraform init'
                sh "cat ${env.BRANCH_NAME}.tfvars"
            }
        }
        
        // Task 4: Branch-Specific Terraform Planning [cite: 13, 14]
        stage('Terraform Plan') {
            steps {
                sh "terraform plan -var-file=${env.BRANCH_NAME}.tfvars"
            }
        }
        
        // Task 5: Conditional Manual Approval Gate [cite: 16, 17]
        stage('Validate Apply') {
            when {
                branch 'dev'
            }
            steps {
                input message: 'Do you want to proceed to Apply?', ok: 'Yes'
            }
        }
    }
}