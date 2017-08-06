tr --delete '\n' <password.txt >.strippedpassword.txt && mv .strippedpassword.txt password.txt
kubectl create -f https://raw.githubusercontent.com/kubernetes/examples/master/mysql-wordpress-pd/local-volumes.yaml
kubectl create secret generic mysql-pass --from-file=password.txt
kubectl create -f https://raw.githubusercontent.com/kubernetes/examples/master/mysql-wordpress-pd/mysql-deployment.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes/examples/master/mysql-wordpress-pd/wordpress-deployment.yaml
