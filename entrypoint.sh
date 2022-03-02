#!/bin/sh -l

export PROJECT_NAME=$(echo $GITHUB_REPOSITORY|cut -d '/' -f2)
echo "Building docker image $PROJECT_NAME"
echo $GITHUB_REF_NAME

aws ecr get-login --region $AWS_REGION --no-include-email | sh;
if [[ $GITHUB_REF_NAME == 'master' ]];
    then 
    export TAG="latest"
    docker build -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:$TAG -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:$GITHUB_RUN_ID .
    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:$TAG
    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:$GITHUB_RUN_ID
else
    export TAG=$GITHUB_RUN_ID
    docker build -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:$TAG .
    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME:$TAG
fi