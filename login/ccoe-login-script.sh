#! /bin/bash

docker run --rm -it -v ~/.aws:/root/.aws sportradar/aws-azure-login

eval $(assume-role cicd_dev)

aws eks update-kubeconfig --name edbhub-notprod --region eu-west-2 

kubectl get ns
