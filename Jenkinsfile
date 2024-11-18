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
      

        stage("PROD Deployment") {
            steps {
                script {
                    // Print the current workspace for debugging
                    sh "echo 'Workspace path: ${WORKSPACE}'"
                    sh "ls -l ${WORKSPACE}/Helm"
                    // Check if Chart.yaml exists in the workspace
                    sh """
                    if [ -f ${WORKSPACE}/Helm/Chart.yaml ]; then
                    echo 'Chart.yaml found'
                    else
                    echo 'Chart.yaml not found' && exit 1
                    fi
                    """
                    // Run Helm dry-run and actual deployment
                    sh "helm upgrade --install mern-stack ${WORKSPACE}/Helm --dry-run --debug"
                    sh "helm upgrade --install mern-stack ${WORKSPACE}/Helm"
                }
            }
        }

    }

    post {
        always {
            dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        }
    }
}
