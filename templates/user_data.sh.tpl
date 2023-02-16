#!/bin/bash
yum -y update
yum -y install httpd

INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<EOF > /var/www/html/index.html
<html>
<h2>${secret_phrase}</h2><br>
Instance IP address: $INSTANCE_IP<br>
</html>
EOF

service httpd start
chkconfig httpd on
