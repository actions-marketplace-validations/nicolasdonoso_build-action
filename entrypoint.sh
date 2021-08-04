#!/bin/sh -l

export PROJECT_NAME=$(echo $GITHUB_REPOSITORY|cut -d '/' -f2)
export TAG=$GITHUB_JOB
echo "Building docker image $PROJECT_NAME"

aws ecr get-login --region $AWS_REGION --no-include-email | sh;
docker build -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:$TAG .
docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:$TAG