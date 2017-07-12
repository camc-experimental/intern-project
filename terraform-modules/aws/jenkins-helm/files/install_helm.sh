#!/bin/bash
counter=0
timeout=20 # how many times to wait for tiller to be ready - (timeout * 30) sec
error=Error
while [ "$counter" -le "$timeout" ]
  do
        status=$(helm init 2>&1)
        if [[ $status == *"$error"* ]] # Or != Tiller
          then
            ((++counter))
            echo "Master node isn't setup yet, trying again... ($counter/$timeout)"
            sleep 20
          else
            echo $status
            break
        fi
done
# Additional config
kubectl create clusterrolebinding serviceaccounts-cluster-admin  --clusterrole=cluster-admin  --group=system:serviceaccounts
