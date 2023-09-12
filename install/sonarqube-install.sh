#!/bin/bash

sudo hostnamectl set-hostname sonarqube
/bin/bash

sudo apt update
sudo apt install openjdk-17-jre -y

wget -O sonarqube.zip https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.1.0.47736.zip
sudo apt install -y unzip
unzip sonarqube.zip
rm sonarqube.zip
cd ./sonarqube-9.1.0.47736/bin/linux-x86-64
./sonar.sh console