pipeline {
    agent any

    environment {
        /* Task 2: Infrastructure environment flags */
        TF_IN_AUTOMATION = 'true' [cite: 7]
        TF_CLI_ARGS = '-no-color' [cite: 7]

        /* Task 2: Securely inject AWS credentials and SSH key ID */
        /* Ensure 'aws-access-key-id' and 'aws-secret-access-key' exist in Jenkins Credentials */
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id') [cite: 8]
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key') [cite: 8]
        
        /* Task 2: Injecting the SSH key credential ID string */
        /* Replace 'my-ssh-key' with the actual ID you created in Jenkins */
        SSH_CRED_ID = 'my-ssh-key' [cite: 8]
    }

    stages {
        stage('Initialization & Variable Inspection') {
            steps {
                /* Task 3: Implement Terraform Initialization */
                sh 'terraform init' [cite: 10]

                /* Task 3: Display contents of branch-specific variable file for verification */
                sh "cat ${env.BRANCH_NAME}.tfvars" [cite: 11]
            }
        }

        stage('Terraform Plan') {
            steps {
                /* Task 4: Generate execution plan using the branch-specific variable file */
                /* The planning details are automatically logged in the Jenkins console */
                sh "terraform plan -var-file=${env.BRANCH_NAME}.tfvars" [cite: 13, 14]
            }
        }

        stage('Validate Apply') {
            /* Task 5: Conditional Gate - Only appears if the branch is 'dev' */
            when {
                branch 'dev' [cite: 17]
            }
            steps {
                /* Task 5: Manual Approval step for confirmation */
                input message: "Do you want to proceed with the deployment to dev?", ok: "Approve" [cite: 16]
            }
        }
    }
}