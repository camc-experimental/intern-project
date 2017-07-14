#!/bin/bash
counter=0
timeout=30  # how many times to wait for tiller to be ready - (timeout * 10) sec
runningstate=Running

# # Install Java 8 runtime
echo "deb http://ftp.debian.org/debian jessie-backports main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt install -y -t jessie-backports openjdk-8-jre-headless ca-certificates-java


# # Wait for Jenkins to become available
while [ "$counter" -le "$timeout" ]
    do
        jenkins_pod_name=$(kubectl describe rs | grep -oh "auto-svc-jenkins-[0-9]*-.*")
        status=$(kubectl get pod "$jenkins_pod_name" -o jsonpath={..phase})
        if [ "$status" != "$runningstate" ]
          then
                ((++counter))
                echo "Jenkins is still not available ($status) - waiting... ($counter/$timeout)"
                sleep 10
        else
                echo "Jenkins is available, configuring..."
                sleep 5  # Wait, just to be on the safe side
                break
        fi
done

# # Get Jenkins CLI executable, move to scripts directory
counter=0
while [ "$counter" -le "$timeout" ]
  do
    wget -c "$JENKINS_URL"jnlpJars/jenkins-cli.jar && break
    sleep 10
    ((++counter))
done
# Set permissions + path
mv jenkins-cli.jar /home/admin/scripts/
sudo chmod +x /home/admin/scripts/jenkins-cli.jar

# Set API-token
# TODO: Get Jenkins API to run script with arguments instead of this ugly hack (and without cd) Requires prior exorcism of script from the Pope
sed -i "1s/^/def username = \"$JENKINS_USERNAME\"\n/" /home/admin/scripts/setup_jk_security.groovy
sed -i "1s/^/def password = \"$JENKINS_PASSWORD\"\n/" /home/admin/scripts/setup_jk_security.groovy
cd /home/admin/scripts/ # Removing this will break the next line, even if you specify the absolute path. Go on, try it I dare you
api_token=$(curl --data-urlencode "script=$(<./setup_jk_security.groovy)" "$JENKINS_URL"scriptText)
# Export API-token
echo "export JENKINS_API_TOKEN=$api_token" | sudo tee -a /home/admin/.bashrc /etc/profile
# Create kubectl secrets
#helm upgrade auto-svc --set Master.UseSecurity=true, Master.AdminUser="$JENKINS_USERNAME", Master.AdminPassword="$JENKINS_PASSWORD" stable/jenkins

# Export Jenkins-CLI Function
cat > jkcmd << EOF
jenkins () {
  java -jar /home/admin/scripts/jenkins-cli.jar -auth $JENKINS_USERNAME:$api_token \$@
}
export -f jenkins
EOF

cat jkcmd | sudo tee -a /home/admin/.bashrc /etc/profile
rm -f jkcmd
