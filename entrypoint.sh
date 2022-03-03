#!/bin/sh -l

echo "Building docker image $REPO_NAME"

if [[ -z $ECR_REPO ]]
    then echo "ECR repo name defined by repo name"
    export REPO_NAME=$(echo $GITHUB_REPOSITORY|cut -d '/' -f2)
else
    echo "ECR repo name defined by env var ECR_REPO"
    export REPO_NAME=$ECR_REPO
fi
aws ecr get-login --region $AWS_REGION --no-include-email | sh;
if [[ -z $DOCKERFILE_LOCATION ]]
    then 
    for image in $(echo $images|tr ',' '\n')
    do  
        export suffix=$(echo $image|cut -d '.' -f2)
        if [[ $suffix != "Dockerfile" ]]
            then echo "ECR repo name defined by image suffix"
            export REPO_NAME=$suffix
        fi
        echo "building image: $image, repo: $ECR_REPO"
        if [[ $GITHUB_REF_NAME == 'master' ]];
            then 
            docker build -f $image -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$GITHUB_RUN_ID .
            docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG
            docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$GITHUB_RUN_ID
        else
            docker build -f $image -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG .
            docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG
        fi
    done
else
    if [[ $GITHUB_REF_NAME == 'master' ]] || [[ $GITHUB_REF_NAME == 'main' ]];
        then 
        docker build -f $DOCKERFILE_LOCATION -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$GITHUB_RUN_ID .
        docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG
        docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$GITHUB_RUN_ID
    else
        docker build -f $DOCKERFILE_LOCATION -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG .
        docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG
    fi
fi