#!/bin/bash
yum update -y
yum install -y git
yum install -y maven
yum install -y docker
systemctl start docker
systemctl enable docker

cd /root
git clone https://github.com/nikhilkothare2106/AWS_DEMO.git
git clone https://github.com/nikhilkothare2106/AWS_DEMO_2.git
cd ./AWS_DEMO

aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin $(echo ${ecr_repo_url} | cut -d'/' -f1)

docker build -t my-app-repo .
docker tag my-app-repo:latest ${ecr_repo_url}:latest
docker push ${ecr_repo_url}:latest

cd ../AWS_DEMO_2

docker build -t my-app-repo1 .
docker tag my-app-repo1:latest ${ecr_repo_url1}:latest
docker push ${ecr_repo_url1}:latest