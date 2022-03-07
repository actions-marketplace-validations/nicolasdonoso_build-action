#!/bin/sh -l

echo "Building docker image $REPO_NAME"

export RUN_ID=$GITHUB_RUN_ID ## Make this variable depending CI/CD provider
if [[ -z $ECR_REPO ]]
    then echo "ECR repo name defined by repo name"
    export REPO_NAME=$(echo $GITHUB_REPOSITORY|cut -d '/' -f2)
else
    echo "ECR repo name defined by env var ECR_REPO"
    export REPO_NAME=$ECR_REPO
fi
aws ecr get-login --region $AWS_REGION --no-include-email | sh;
if [[ -f deploy/config.json ]]
    then
    if [[ $(cat deploy/config.json|jq .'react_env'|sed s/\"//g) != null ]]
        then export ENV=$(cat deploy/config.json|jq .'react_env'|sed s/\"//g)
    else
        export ENV=$(cat deploy/config.json|jq .'node_env'|sed s/\"//g)
    fi
fi
if [[ -z $DOCKERFILE_LOCATION ]]
    then
    if [[ -z $images ]]
        if [[ $(ls|grep Docker -c) == "1" ]]
            then echo single;
            echo "Inject npmrc...";
            cp services/npm/.npmrc .npmrc;
            for f in $( ls | grep "Dockerfile" );
                do
                file=$f;
                prefix=`echo $f | cut -d "/" -f 2 | cut -d "." -f 2`;
                if [ $prefix == "Dockerfile" ];
                    then echo "---> 2... $prefix <---"
                    docker build -f $file --build-arg ENV=$ENV --build-arg NPM_TOKEN=$NPM_TOKEN -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID .;
                    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID;
                else echo "---> 3... $prefix <---"
                    docker build --build-arg ENV=$ENV -f $file -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$prefix-$RUN_ID .;
                    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$prefix-$RUN_ID;
                fi;
            done;
        elif [[ $SERVICE == "true" ]];
            then echo service;
            echo "Inject npmrc...";
            cp services/npm/.npmrc .npmrc;
            for f in $( ls services | grep "Dockerfile" );
                do
                file=$f;
                prefix=`echo $f | cut -d "/" -f 2 | cut -d "." -f 2`;
                if [ $prefix == "Dockerfile" ];
                    then echo "---> 2... $prefix <---"
                    docker build -f services/$file --build-arg ENV=$ENV --build-arg NPM_TOKEN=$NPM_TOKEN -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID .;
                    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID;
                else echo "---> 3... $prefix <---"
                    docker build -f services/$file --build-arg ENV=$ENV --build-arg NPM_TOKEN=$NPM_TOKEN -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$prefix-$RUN_ID .;
                    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$prefix-$RUN_ID;
                fi;
            done;
        elif [[ $(ls|grep Docker -c) > 1 ]]
            then echo multiple images;
            for f in $( ls | grep "Dockerfile" );
                do
                file=$f;
                prefix=`echo $f | cut -d "/" -f 2 | cut -d "." -f 2`;
                if [ $prefix == "Dockerfile" ];
                    then echo "---> 2... $prefix <---"
                    docker build --build-arg ENV=$ENV -f $file -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:latest -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID .;
                    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID;
                    if [ "$CI_COMMIT_REF_NAME" = "master" ] || [ "$CI_COMMIT_REF_NAME" = "main" ];
                        then echo "---> tagging latest <---"
                        docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:latest;
                    fi;
                    else echo "---> 3... $prefix <---"
                    docker build --build-arg ENV=$ENV -f $file -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$prefix-$RUN_ID .;
                    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$prefix-$RUN_ID;
                    fi;
            done;
        else ## Check where is this needed
            echo multi;
            for dir in $(ls | grep -v "README.md");
                do
                for f in $(ls $dir/Dockerfile*);
                do
                    file=$f;
                    prefix=`echo $f | cut -d "/" -f 1|sed s/_/-/g`;
                    if [ $prefix == "Dockerfile" ];
                    then echo "---> 2... $prefix <---"
                    docker build --build-arg ENV=$ENV -f $file -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID-$prefix .;
                    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID-$prefix;
                    else echo "---> 3... $prefix <---"
                    docker build --build-arg ENV=$ENV -f $file -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID-$prefix .;
                    docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID-$prefix;
                    fi;
                done;
            done;
        fi;
    else
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
                docker build -f $image -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID .
                docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG
                docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID
            else
                docker build -f $image -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG .
                docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG
            fi
        done
    fi
else
    if [[ $GITHUB_REF_NAME == 'master' ]] || [[ $GITHUB_REF_NAME == 'main' ]];
        then 
        docker build -f $DOCKERFILE_LOCATION -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID .
        docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG
        docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$RUN_ID
    else
        docker build -f $DOCKERFILE_LOCATION -t $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG .
        docker push $AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$TAG
    fi
fi