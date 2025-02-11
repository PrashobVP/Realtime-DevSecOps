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

        stage("Deployment to Dockerhost"){
            steps{
                sh "docker-compose up -d"
                
       
    }

    
}
