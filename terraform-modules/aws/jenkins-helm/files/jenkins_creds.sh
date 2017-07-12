#!/bin/bash
###################################################
# Dockerhub credentials order                     #
# $1 = dockerhub user, $2 = dockerhub password    #
###################################################
# Watson credentials                              #
# $3 = watson_api_key                             #
###################################################
# Github Token credentials                        #
# $4 = git username, $5 = git token               #
###################################################
# Jenkins job specs for app                       #
# $6 = git repo owner, $7 = repo name,            #
# $8 = git API endpoint                           #
###################################################


config_dir=/home/admin/jenkins_imports

# Replace $1 with $2 in file $3
replace(){
  echo "Replace $1 with $2 in file $3"
  sed -i -e "s#$1#$2#g" "$config_dir/$3"
}

# replace Dockerhub placeholders
 replace 'docker-user-placeholder' "$1" 'creds_dockerhub.xml'
 replace '<secret-redacted\/>' "$2" 'creds_dockerhub.xml'

# replace watson api key placeholder
replace '<secret-redacted\/>' "$3" 'creds_watson-api-key.xml'

# replace git token placeholders
replace 'git-user-placeholder' "$4" 'creds_github-token.xml'
replace '<secret-redacted\/>' "$5" 'creds_github-token.xml'

# replace jenkins-job info
replace 'git-repo-owner-placeholder' "$6" 'job.xml'
replace 'git-repo-name-placeholder' "$7" 'job.xml'
replace 'git-api-endpoint-placeholder' "$8" 'job.xml'


echo "Adding credentials to Jenkins"
cat $config_dir/creds_dockerhub.xml | jenkins create-credentials-by-xml "SystemCredentialsProvider::SystemContextResolver::jenkins" "(global)"
cat $config_dir/creds_github-token.xml | jenkins create-credentials-by-xml "SystemCredentialsProvider::SystemContextResolver::jenkins" "(global)"
cat $config_dir/creds_watson-api-key.xml | jenkins create-credentials-by-xml "SystemCredentialsProvider::SystemContextResolver::jenkins" "(global)"

echo "Adding job to Jenkins"
cat $config_dir/job.xml | jenkins create-job "$7"

curl -X POST -u $JENKINS_USERNAME:$JENKINS_API_TOKEN "$JENKINS_URL"job/$7/build?delay=0
