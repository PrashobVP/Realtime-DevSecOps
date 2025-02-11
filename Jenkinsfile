pipeline {
    agent any
    environment {
        SONAR_HOME = tool "Sonar"
    }

    stages {
        stage("Code Checkout"){ 
            steps{
                git(
                    url: "https://github.com/PrashobVP/Realtime-DevSecOps.git",
                    branch: "master",
                    credentialsId: "jenkins-secret",
                    changelog: true,
                    poll: true
                )
            }
        }

        stage("SonarQube Code Analysis") {
            steps {
                withSonarQubeEnv("Sonar") {
                    sh "$SONAR_HOME/bin/sonar-scanner -Dsonar.projectName=mern-stack -Dsonar.projectKey=mern-stack"
                }
            }
        }

        stage("Trivy File System Scan"){
            steps{
                sh "trivy fs --format table -o trivy-fs-report.html ."
            }
        }

        // Local Deployment using Docker Compose
        stage("Deployment to Dockerhost"){
            steps {
                script {
                    sh "docker-compose up -d"
                }
            }
        }
    }

    post {
        always {
            echo "Deployment completed."
        }
    }
}
