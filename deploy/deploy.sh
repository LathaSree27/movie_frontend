#!/bin/bash
set -e

export CLUSTER_NAME="team$TEAM_ID"
export CLUSTER_CONFIG_NAME="team$TEAM_ID-config"
export CLUSTER_PROFILE_NAME="team$TEAM_ID-profile"

export IMAGE=$REACT_IMAGE_NAME:$CI_COMMIT_SHORT_SHA-$CI_ENVIRONMENT_SLUG
echo  "Iamge URL: $IMAGE"

aws configure set aws_access_key_id "$AWS_ACCESS_KEY"
aws configure set aws_secret_access_key "$AWS_SECRET_KEY"
aws configure set default.region ap-south-1 --profile gitlabci

echo "Generating task definitions and service definitions"
node ecs.js serviceTemplate
node ecs.js taskDefinitionTemplate

echo "Registering task definition"
aws ecs register-task-definition --cli-input-json file://task-definition.json

aws ecs list-services --cluster "team$TEAM_ID"
if [ $? != 0 ]; then
  echo "Registering service definition"
  aws ecs create-service --cli-input-json file://service.json
else
  echo "Service already exists. Skippinig service creation"
fi

echo "running clean up"
rm -rf service.json
rm -rf task-definition.json