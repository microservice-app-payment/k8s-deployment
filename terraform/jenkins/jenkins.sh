#!/bin/bash

git clone https://github.com/microservice-app-payment/payment-project-jenkins-pack.git
cd ./payment-project-jenkins-pack
chmod 700 vm-startup-script.sh
bash vm-startup-script.sh
docker compose up -d
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword