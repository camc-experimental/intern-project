#!/bin/bash
counter=0
timeout=30  # how many times to wait for tiller to be ready - (timeout * 10) sec
runningstate=Running
while [ "$counter" -le "$timeout" ]
    do
        status=$(kubectl get pod --namespace=kube-system -l name=tiller -o jsonpath={..phase})
        if [ "$status" != "$runningstate" ]
          then
                ((++counter))
                echo "Tiller pod is still $status, waiting to install Jenkins... ($counter/$timeout)"
                sleep 10
        else
                echo "Tiller pod is $status, ready to install Jenkins"
                sleep 10 # need to wait additional cycle to ensure pod is truly ready
                # Install Jenkins using helm
                helm install --name auto-svc --set Master.ServicePort="$1",Master.AdminUser="$2",Master.AdminPassword="$3" -f /home/admin/scripts/jenkins-values.yaml stable/jenkins
                sleep 10
                # Get Service IP
                SERVICE_IP=$(kubectl get svc auto-svc-jenkins --namespace default --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
                # Store Jenkins-specific environment variables
                echo "export JENKINS_URL=http://$SERVICE_IP:$1/" | sudo tee -a /home/admin/.bashrc /etc/profile
                echo "export JENKINS_PASSWORD=$3" | sudo tee -a /home/admin/.bashrc /etc/profile
                echo "export JENKINS_USERNAME=$2" | sudo tee -a /home/admin/.bashrc /etc/profile
                break
        fi
done
# Display message, depending on success
[[ -z "${1}${2}${3}${SERVICE_IP}" ]] && echo "FAILED to deploy Jenkins" || echo "SUCCESS! Deployed Jenkins"
