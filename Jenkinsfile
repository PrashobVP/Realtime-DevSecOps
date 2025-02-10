pipeline {
    agent any
    environment {
        SONAR_HOME = tool "Sonar"
         
    }

    tools {
    dependencyCheck 'Dependency-Check'
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
                sh "trivy fs --format  table -o trivy-fs-report.html ."
            }
        }
        stage("OWASP Dependency Check"){
            steps{
                echo "Skipping due to some dependency test cases are yet to be merged to master"
                dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'dc'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
      

        

    }

    post {
        always {
            dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        }
    }
}
