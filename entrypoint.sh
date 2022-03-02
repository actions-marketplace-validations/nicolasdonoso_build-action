#!/bin/sh -l

export PROJECT_NAME=$(echo $GITHUB_REPOSITORY|cut -d '/' -f2)
echo "Building docker image $PROJECT_NAME"
echo $GITHUB_REF_NAME

aws ecr get-login --region $AWS_REGION --no-include-email | sh;
if [[ $GITHUB_REF_NAME == 'master' ]];
    then 
    docker build -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:latest -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:$GITHUB_RUN_ID .
    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:latest
    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:$GITHUB_RUN_ID
else
    docker build -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:$TAG .
    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:$TAG
fi