pipeline {
    agent any
    environment {
        SONAR_HOME = tool "Sonar"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials" 
    }
    stages {
        stage("Code Checkout"){ 
            steps{
                git(
                    url: "https://github.com/amigo-nishant/Capstone_Project_Clone.git",
                    branch: "main",
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
                sh "trivy fs --format  table -o trivy-fs-report.html ."
            }
        }
        stage("OWASP Dependency Check"){
            steps{
                echo "Skipping due to some dependency test cases are yet to be merged to master"
                // dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'dc'
                // dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage("PROD Deployment"){
            steps{
                sh "helm ls"
                sh "kubectl get nodes"
                sh "cd /var/lib/jenkins/workspace/PROD/Helm"
                sh "ls -l /var/lib/jenkins/workspace/PROD/Helm/Chart.yaml"
                sh "helm upgrade --install mern-stack /var/lib/jenkins/workspace/PROD/Helm --dry-run --debug"
                sh "helm upgrade --install mern-stack /var/lib/jenkins/workspace/PROD/Helm"
            }
        }
    }
}
