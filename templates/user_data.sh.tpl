#!/bin/bash
dnf -y update
dnf -y install httpd

# Instance metadata needs an IMDSv2 session token: the launch template requires it.
TOKEN=$(curl -sS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
INSTANCE_IP=$(curl -sS -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<EOF > /var/www/html/index.html
<html>
<h2>${secret_phrase}</h2><br>
Instance IP address: $INSTANCE_IP<br>
</html>
EOF

systemctl enable --now httpd
