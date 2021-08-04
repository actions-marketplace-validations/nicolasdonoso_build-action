#!/bin/sh -l

echo "Building docker image $CI_PROJECT_NAME"

aws ecr get-login --region $AWS_REGION --no-include-email | sh;
docker build -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$CI_PROJECT_NAME:$CI_PIPELINE_ID .
docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$CI_PROJECT_NAME:$CI_PIPELINE_ID