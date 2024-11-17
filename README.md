# MERN Stack Project with DevOps Principles
## Introduction
Welcome to our open source MERN stack project! This repository serves as an educational resource for developers who want to learn how to deploy a three-tier application to **PRODUCTION** using DevOps principles. The project leverages a modern technology stack and architecture, consisting of Next.js for the frontend, Node.js for the backend, and MongoDB for the database. 
As an open source project, we encourage anyone to work on and contribute to the project. Whether you are a DevOps engineer, a full-stack developer, or someone looking to learn more about deploying a MERN stack application, you will find opportunities to gain hands-on experience and make meaningful contributions.

### Setting up the Backend
1. **Fork and Clone the Repository**
   ```bash
   git clone https://github.com/amigo-nishant/MERN-Stack-Aplication.git
   ```
2. **Navigate to the Backend Directory**
   ```bash
   cd backend
   ```
3. **Install Required Dependencies**
   ```bash
   npm i
   ```
4. **Set up your MongoDB Database**
   - Open MongoDB Compass and connect MongoDB locally at `mongodb://localhost:27017`.
5. **Import sample data**
   > To populate the database with sample posts, you can copy the content from the `backend/data/sample_posts.json` file and insert it as a document in the `wanderlust/posts` collection in your local MongoDB database using either MongoDB Compass or `mongoimport`.
   ```bash
   mongoimport --db wanderlust --collection posts --file ./data/sample_posts.json --jsonArray
   ```
6. **Configure Environment Variables**
   ```bash
   cp .env.sample .env
   ```
7. **Start the Backend Server**
   ```bash
   npm start
   ```
   > You should see the following on your terminal output on successful setup.
   >
   > ```bash
   > [BACKEND] Server is running on port 5000
   > [BACKEND] Database connected: mongodb://127.0.0.1/wanderlust
   > ```
### Setting up the Frontend
1. **Open a New Terminal**
   ```bash
   cd frontend
   ```
2. **Install Dependencies**
   ```bash
   npm i
   ```
3. **Configure Environment Variables**
   ```bash
   cp .env.sample .env.local
   ```
4. **Launch the Development Server**
   ```bash
   npm run dev
   ```

## Setting up the Backend with DB

7. Install mongodb database
```bash
https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/
```
8. Install dependencies
```bash
cd backend
npm i
```
9. start your mongodb service
```bash
sudo systemctl start mongod
sudo systemctl status mongod
```
10. To validate mongo installation
```bash
mongosh
exit
```
11. Import sample data
```bash
mongoimport --db wanderlust --collection posts --file ./data/sample_posts.json --jsonArray
```
12. Configure Environment Variables
```bash
cp .env.sample .env
```
13. Start the Backend Server
```bash
npm start
```
********************************************   **LAB-1**   ************************************************
### Setup Dockerfile for our backend 

1. Install Docker -- https://docs.docker.com/engine/install/ubuntu/
2. Add user to the docker group - sudo usermod -aG docker $USER [ exit and ssh back to to apply the changes. This step is important as it refreshes your session and grants your user the new group permissions]
3. **NOTE** If you are triggering the shell script to provision the cluster then no need to install docker manually
 
4. Create a Dockerfile for your Backend [Reference --> README.md file for Backend]
```bash
FROM node:21
WORKDIR /app
COPY . .
RUN npm i
COPY .env.docker .env
EXPOSE 5000
CMD ["npm", "start"]
```
5. Now from the Dockerfile let us build an image
```bash
docker build -t backend .
```
6. We also need mongodb database for our backend service so let's build a mongo container
```bash
docker run -d -p 27017:27017 --name mongo mongo:latest
```
7. Check the status of docker containers
```bash
docker ps
```
8. To validate mongo db is running inside the container
```bash
docker exec -it <container-id> /bin/bash
mongosh
```
9. Run the backend container
```bash
docker run -d -p 5000:5000 --name backend backend:latest
```

### Setup Dockerfile for our Frontend
1. Create a Dockerfile for your Frontend [Reference --> README.md file for Frontend]
```bash
FROM node:21
WORKDIR /app
COPY . .
RUN npm i
COPY .env.docker .env.local
EXPOSE 5173
CMD ["npm", "run", "dev", "--", "--host"]
```
2. vim .env.docker
```bash
change localhost:5000 --> public-IP:5000
```
3. Now from the Dockerfile let us build an image
```bash
docker build -t frontend .
```
4. Run the frontend container
```bash
docker run -d -p 5173:5173 --name frontend frontend:latest
```
5. Check the status of docker containers, all three containers should be up and running 
```bash
docker ps
docker rm -f <all-containers>
```
> But containers are isolated, we have to create a network or we can use docker-compose so that we can have all the three containers in one single stack and communicate with each other.

### docker-compose 

Run the command to start all the services
```bash
docker compose up -d --build
```
If you want to import some data  
```bash
docker ps
docker exec -it <mongo-container-ID> /bin/bash
docker exec -it mongo mongoimport --db wanderlust --collection posts --file ./data/sample_posts.json --jsonArray
```
Stop all the services
```bash
docker compose down
```

### Debugging Notes
> Check frontend .env.sample file and update the connection URL
> If you are building the image make sure to import the data
> Check developer tools console log to identify the API calls and errors
> Check the backend logs if it is connecting to mongo

## Deployment via custom kubernetes manifest files 
1. Check the cluster configs and install minikube cluster using the shell script
```bash
kubectl config get-contexts
```
2. Be on the project root directory
```bash
ls
Jenkinsfile		README.md		docker-compose.yml	helm			package-lock.json
LICENSE			backend			frontend		kubernetes		package.json 
```
3. Deploy the files
```bash
kubectl create -f kubernetes/
```
4. Check the configs
```bash
kubectl get all
```
5. Get the URL for the service running in minikube VM
```bash
minikube service frontend --url
```
6. Test the app locally on minikube VM
```bash
curl <URL>
```
7. Now to test the application outside the cluster via port-forwarding
```bash
kubectl get svc
kubectl port-forward svc/frontend NodePort-port:5173 --address 0.0.0.0 &
```
8. Now to test on browser 
```bash
http:PublicIP:NodePort
```
9. Delete the deployment configs
```bash
kubectl delete -f kubernetes/
```
## PROD Deployment via custom Helm Charts
1. Install minikube cluster on a t2.large instance and navigate to the directoy having helm configs
```bash
cd helm
```
2. Before deployment check the configs using dry-run 
```bash
helm upgrade --install wanderlast . --dry-run --debug
```
3. Deploy the helm chart
```bash
helm upgrade --install wanderlast .
```
4. Check the deployment
```bash
helm ls
```
5. Check the deployment status
```bash
kubectl get all
```
6. Get the URL for the service running in minikube VM
```bash
minikube service wanderlast-helm-frontend --url
```
7. Test the app locally on minikube VM
```bash
curl <URL>
```
8. Now to test the application outside the cluster via port-forwarding
```bash
kubectl get svc
kubectl port-forward svc/wanderlast-helm-frontend NodePort-port:5173 --address 0.0.0.0 &
```
9. Now to test on browser 
```bash
http://PublicIP:NodePort
```
10. Delete the deployment
```bash
helm uninstall wanderlast .
```

********************************************   **LAB-2**   ************************************************
# DevSecOps Project
### Tools Covered:
-  Linux
-  Git and GitHub
-  Docker
-  Kubernetes
-  Docker-compose
-  Jenkins CI/CD
-  SonarQube Scan
-  SonarQube Quality Gates
-  Trivy
-  Prometheus & Grafana

## Pre-requisites to implement this project:

-  AWS EC2 instance (Ubuntu) with instance type t2.large and root volume 29GB.

-  Install Docke, K8s, helm using the cluster.sh script

-  sudo usermod -aG docker $USER && newgrp docker

-  Installation of JAVA
   ```bash
   sudo apt update
   sudo apt install fontconfig openjdk-17-jre
   java -version
   ```

-  Installation of Jenkins
   ```bash
   sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
   https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
   echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
   https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
   /etc/apt/sources.list.d/jenkins.list > /dev/null
   sudo apt-get update
   sudo apt-get install jenkins
   ```
-  Setup Jenkins
   ```bash
   Public-IP:8080 (Jenkins running)
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
-  Docker, docker-compose, kubectl, helm  installled - Trigger the cluster.sh script with execute permission
    ```bash
   ./cluster.sh && chmod +x cluster.sh
   ls -lah
    ```
- Install trivy --> https://aquasecurity.github.io/trivy/v0.18.3/installation/

- SonarQube Server installed
   ```bash
    docker run -itd --name sonarqube-server -p 9000:9000 sonarqube:lts-community
   ```
#
## Steps for Jenkins CI/CD:

1)  Access Jenkins UI and setup Jenkins

![image](https://github.com/DevMadhup/node-todo-cicd/assets/121779953/1eec417e-95ab-4497-ad31-443ecd6b999e)

#

2)  Plugins Installation:

    - Go to <b><i><u>Manage Jenkins</u></i></b>, click on <b><i><u>Plugins</u></i></b> and install all the plugins listed below, we will require for other tools integration:

        - SonarQube Scanner (Version2.16.1)
        - Sonar Quality Gates (Version1.3.1)
        - Docker (Version1.5)
        - Kubernetes
#

3) Go to SonarQube Server and create token

    - Click on <b><i><u> Administration </u></i></b> tab, then <b><i><u> Security </u></i></b>, then <b><i><u> Users </u></i></b> and create Token.
    -  Create a webhook to notify Jenkins that Quality gates scanning is done. (We will need this step later)

        - Go to SonarQube Server, then <b><i><u> Administration </u></i></b>, then <b><i><u> Configuration </u></i></b> and click on <b><i><u> Webhook </u></i></b>, add webhook in below <b>Format</b>:
        > http://<jenkins_url>:8080/sonarqube-webhook/
        
        Example: 

        ```bash
            http://34.207.58.19:8080/sonarqube-webhook/
        ```

        ![image](https://github.com/DevMadhup/node-todo-cicd/assets/121779953/b9ef2301-b8ff-46f4-a457-6345d5e2dab6)


        ![image](https://github.com/DevMadhup/node-todo-cicd/assets/121779953/08a33164-f6a6-4c5d-8a34-7091cf8a5745)

#

4) Go to Jenkins UI <b><i><u> Manage Jenkins </u></i></b>, then <b><i><u> Credentials </u></i></b> and add SonarQube Credentials.

![image](https://github.com/DevMadhup/node-todo-cicd/assets/121779953/f6db72ec-7d8c-4f4c-ae7a-55d99dd20ce9)

#

5) Now, It's time to integrate SonarQube Server with Jenkins, go to <b><i><u> Manage Jenkins </u></i></b>, then <b><i><u> System </u></i></b> and look for <b><i><u> SonarQube Servers </u></i></b> and add SonarQube.

![image](https://github.com/DevMadhup/node-todo-cicd/assets/121779953/54849cb2-fe56-4acd-972d-3057a0eb3deb)

#

6) Go to <b><i><u> Manage Jenkins </u></i></b>, then <b><i><u> tools </u></i></b>, look for <b><i><u> SonarQube Scanner installations </u></i></b> and add SonarQube Scanner.

> Note: Add name as ```Sonar```
![image](https://github.com/DevMadhup/node-todo-cicd/assets/121779953/1fe926f6-a844-42d4-bce4-62193dde6640)

#

### Configure the Jenkins Job test 
- create a jenkins job "test"
- select pipeline
- Pipeline -> SCM --> credentials --> Username and PAT --> Secret name "jenkins-secret"
- ALso before triggering the build check make sure to give jenkins and docker permission 
 ```bash
sudo usermod -aG docker jenkins
sudo systemctl restart docker
sudo systemctl restart jenkins
docker ps -a
docker start <sonarqube-container-ID>
minikube status
minikube start
kubectl get nodes
```

### Configure the Jenkins and K8s integration
- We need to create a seperate namespace and create token for our cluster configuration with Jenkins scope
```bash
kubectl create namespace jenkins
kubectl create sa jenkins -n jenkins
kubectl create token jenkins -n jenkins --duration=8760h
kubectl create rolebinding jenkins-admin-binding --clusterrole=admin --serviceaccount=jenkins:jenkins --namespace=jenkins
```
- Now we need to setup the credential in Jenkins so that cluster can communicate with our Jenkins Agent for the builds
```bash
kubectl config view
```
   1. Go to manage jenkins and select cloud --> "kubernetes"
   2. Get the server URL from the above command
   3. Disable http certificate
   4. Type as "secret text" --> add the credential name as "jenkins"
   5. Lastly add the token we created --> Test the connection

### Configure the Jenkins user permission to run the job
- change the default password for jenkins user --> "admin123"
```bash
sudo su
usermod -a -G sudo jenkins
passwd jenkins
```
- Move the kubeconfig file from ubuntu user to jenkins user
```bash
sudo su - jenkins
mkdir -p $HOME/.kube
sudo cp /home/ubuntu/.minikube/profiles/minikube/client.crt /var/lib/jenkins/.kube/
sudo cp /home/ubuntu/.minikube/profiles/minikube/client.key /var/lib/jenkins/.kube/
sudo cp /home/ubuntu/.minikube/ca.crt /var/lib/jenkins/.kube/
sudo cp /home/ubuntu/.kube/config /var/lib/jenkins/.kube
```
- change the path for the kubeconfig file from ubuntu user to jenkins user
``` bash
sudo vi /var/lib/jenkins/.kube/config
```
- We need to change here the config file path for **client-certificate** **client-key** & **certificate-authority**
```bash
users:
   - name: minikube
    user:
       client-certificate: /var/lib/jenkins/.kube/client.crt      —> change it
       client-key: /var/lib/jenkins/.kube/client.key              —> change it
    clusters:
   - cluster:
       certificate-authority: /var/lib/jenkins/.kube/ca.crt     —> change it
```
- change the permission for the kubeconfig file from ubuntu user to jenkins user along with the prmission
```bash
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/client.crt
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/client.key
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/ca.crt
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/config
sudo chmod 600 /var/lib/jenkins/.kube/client.crt
sudo chmod 600 /var/lib/jenkins/.kube/client.key
sudo chmod 600 /var/lib/jenkins/.kube/ca.crt
sudo chmod 600 /var/lib/jenkins/.kube/config
```

- Change the permission for kubernetes config file to run as curent user - jenkins user
```bash
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

- Test as a jenkins user:
```bash
kubectl get nodes
```

- Get the URL for the service running in minikube VM
```bash
minikube service mern-stack-helm-frontend --url
```
- Test the app locally on minikube VM
```bash
curl <URL>
```
- Expose the App
```bash
kubectl expose service mern-stack-helm-frontend --type=NodePort --target-port=5173 --name=mern-stack-helm-frontend-ext
```
- Now to test the application outside the cluster via port-forwarding
```bash
kubectl get svc
kubectl port-forward svc/mern-stack-helm-frontend-ext NodePort-port:5173 --address 0.0.0.0 &
```
- Now to test on browser 
```bash
http://PublicIP:NodePort
```

## Observability Setup and Monitoring
1. Add the prometheus community maintained helm chart
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```
2. helm repo update
```bash
helm repo update
```
3. Test prometheus using dry-run and validate the chart configs
```bash
helm install prometheus prometheus-community/prometheus --dry-run --debug
```
4. Deploy prometheus after validation
```bash
helm install prometheus prometheus-community/prometheus
```
5. Expose the prometheus service to access prometheus-server using the browser.
```bash
kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-ext
```
6. Test the service for prometheus-server-ext
```bash
kubectl get svc
kubectl port-forward svc/prometheus-server-ext NodePort:80 --address 0.0.0.0 &
```
7. Navigate to browser --> http:PublicIP:NodePort
8. Add the Grafana community maintained helm chart
```bash
helm repo add grafana https://grafana.github.io/helm-charts
```
9. Update the repo
```bash
helm repo update
```
10. Test Grafana using dry-run and validate the chart configs
```bash
helm install grafana grafana/grafana --dry-run --debug
```
11. Deploy Grafana  after validation
```bash
helm install grafana grafana/grafana
```
12. Expose the Grafana service to access Grafana using the browser.
```bash
kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-ext
```
13. Test the service for grafana-ext
```bash
kubectl get svc
kubectl port-forward svc/grafana-ext NodePort:80 --address 0.0.0.0 &
```
14. Navigate to browser --> http://PublicIP:NodePort
15. Get your 'admin' user password by running:
```bash
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
16. Setup datasorce in Grafana dashboard
    1. Go to Home --> Add Datasource --> Prometheus
    2. In Datasources we need the connection string for our prometheus-server
    ```bash
    kubectl get svc prometheus-server
    NAME                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
    prometheus-server   ClusterIP   10.98.12.207   <none>        80/TCP    19m
    ```
    3.  Now the Connection URL should be --> http://prometheus-server-cluster-IP:Port --> Eg: http://10.98.12.207:80
    4.  Once Datasorce is connected successfully we can create Dashboard to visualize the charts
    5.  Go to dashboards and import dashboard ID - 3662
    
### To Bring down all the services after the lab
1. Bring down Application pods
```bash
helm uninstall wanderlast .
```
2. Scale down all grafana pods and services
```bash
helm uninstall grafana grafana/grafana
```
3. Lastly scale down all prometheus pods services
```bash
helm uninstall prometheus prometheus-community/prometheus
```
4. Delete the Instance 
