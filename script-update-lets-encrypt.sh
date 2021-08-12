WORKSPACE="/var/lib/jenkins/workspace/update-letsencrypt-route53-techroute.com.br"
ARCHIVE="/var/lib/jenkins/workspace/update-letsencrypt-route53-techroute.com.br/config/archive"
LIVE="/var/lib/jenkins/workspace/update-letsencrypt-route53-techroute.com.br/config/live"

mkdir -p $WORKSPACE $ARCHIVE $LIVE
sudo chown -R jenkins:jenkins $WORKSPACE $ARCHIVE $LIVE
cd $LIVE
sudo rm -rf $DOMINIO_DO_CLIENTE*
cd $ARCHIVE
sudo rm -rf $DOMINIO_DO_CLIENTE* $CLIENTE
sudo /usr/bin/certbot certonly --agree-tos --email alanqueiroz@outlook.com --config-dir $WORKSPACE/config --logs-dir $WORKSPACE/logs --work-dir $WORKSPACE/work --dns-route53 -n -d *.${DOMINIO_DO_CLIENTE} --server https://acme-v02.api.letsencrypt.org/directory
cd $DOMINIO_DO_CLIENTE*
sudo mv privkey* $CLIENTE-private.key
sudo mv fullchain* $CLIENTE-fullchain.pem
sudo mv cert* $CLIENTE-cert.pem
cd -
sudo mv $DOMINIO_DO_CLIENTE* $CLIENTE
sudo chown -R jenkins:jenkins $WORKSPACE