pipeline {
    agent any

    environment {
        // Task 2: Define environment block [cite: 7, 8]
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS = '-no-color'
        AWS_CREDS = credentials('aws-creds') 
        SSH_CRED_ID = credentials('SSH_CRED_ID')
    }

    stages {
        // Task 3: Initialization & Inspection [cite: 9]
        stage('Terraform Init & Inspect') {
            steps {
                sh 'terraform init' // [cite: 10]
                // Display content of the branch-specific .tfvars file [cite: 11]
                sh "cat ${env.BRANCH_NAME}.tfvars" 
            }
        }

        // Task 4: Branch-Specific Planning [cite: 12]
        stage('Terraform Plan') {
            steps {
                // Generate plan using the branch-specific variable file [cite: 13]
                // Output is automatically logged to Jenkins console [cite: 14]
                sh "terraform plan -var-file=${env.BRANCH_NAME}.tfvars"
            }
        }

        // Task 5: Conditional Manual Approval [cite: 15]
        stage('Validate Apply') {
            // Only trigger this stage if pushing to the 'dev' branch [cite: 17]
            when {
                branch 'dev'
            }
            steps {
                // Manual confirmation gate [cite: 16]
                input message: "Do you want to proceed with the deployment to dev?", ok: "Approve"
            }
        }
    }
}