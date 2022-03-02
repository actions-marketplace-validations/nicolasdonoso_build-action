#!/bin/sh -l

echo "Building docker image $REPO_NAME"
if [[ -z $ECR_REPO ]]
    then export REPO_NAME=$(echo $GITHUB_REPOSITORY|cut -d '/' -f2)
else
    export REPO_NAME=$ECR_REPO
fi

aws ecr get-login --region $AWS_REGION --no-include-email | sh;
if [[ $GITHUB_REF_NAME == 'master' ]];
    then 
    export TAG="latest"
    docker build -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$GITHUB_RUN_ID .
    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG
    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$GITHUB_RUN_ID
else
    export TAG=$GITHUB_RUN_ID
    docker build -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG .
    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG
fi