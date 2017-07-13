# intern-project
This repository contains a Terraform module that will install Jenkins and Helm on a Kubernetes cluster on AWS. The module also automatically sets up Jenkins to build a GitHub repository. The module executes these scripts from `terraform-modules/aws/jenkins-helm/files/` in order:


##### `install_helm.sh`
1. Wait for the Kubernetes master node to start up.
1. Install Helm.

##### `install_jenkins.sh`
1. Wait for Helm's Tiller pod to become available.
1. Install Jenkins with values from `jenkins-values.yaml`.
1. Set environment variables for Jenkins URL, username, and password.

##### `configure_jenkins.sh`
1. Install the Java 8 runtime.
1. Wait for Jenkins to become available.
1. Download the Jenkins CLI.
1. Set up security for Jenkins with `setup_jk_security.groovy`.

##### `jenkins_creds.sh`
1. Fill in secrets and other variables in Jenkins XML configuraiton files (in `terraform-modules/aws/jenkins-helm/jenkins_imports/`).
1. Add the credentials and build job to Jenkins.
1. Tell Jenkins to scan the newly added repository.

##### `github_hook.sh`
1. Add a webhook to the GitHub repo pointing it to Jenkins.
