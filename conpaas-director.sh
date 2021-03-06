#!/bin/bash
TMPFILE=$(mktemp)
ATTEMPTS=10
while [ ${ATTEMPTS} -gt 0 ]; do
  ATTEMPTS=$((${ATTEMPTS}-1))
  curl -sf http://169.254.169.254/openstack/2012-08-10/user_data\
    > ${TMPFILE} 2>/dev/null
  if [ $? -eq 0 ]; then
    break
  fi
  sleep 1
done
if [ -e "${TMPFILE}" ]; then
    . ${TMPFILE}
fi
rm -f ${TMPFILE}

: ${USERNAME:="test"}
: ${PASSWORD:="password"}
: ${EMAIL:="test@email"}
: ${IMAGE_ID:=""}
: ${IP_ADDRESS:="$(ip addr show | perl -ne 'print "$1\n" if /inet ([\d.]+).*scope global/' | grep "$IP_PREFIX" | head -1)"}
: ${DIRECTOR_URL:="https://${IP_ADDRESS}:5555"}
: ${CRS_URL:="http://${IP_ADDRESS}:56789"}

sed -i "/^logfile\s*=/s%=.*$%= /var/log/apache2/cpsfrontend-error.log%" /etc/cpsdirector/main.ini
sed -i "/^const DIRECTOR_URL =/s%=.*$%= '${DIRECTOR_URL}';%" /var/www/config.php
sed -i "/^DIRECTOR_URL =/s%=.*$%= ${DIRECTOR_URL}%" /etc/cpsdirector/director.cfg
sed -i -e'/^\[iaas\]/,/^\[.*\]/{/^DRIVER\s*=.*/d}' -e'/^\[iaas\]/aDRIVER = harness' /etc/cpsdirector/director.cfg
sed -i -e"/^\[iaas\]/,/^\[.*\]/{/^HOST\s*=.*/d}" -e"/^\[iaas\]/aHOST = ${CRS_URL}" /etc/cpsdirector/director.cfg
sed -i -e"/^\[iaas\]/,/^\[.*\]/{/^IMAGE_ID\s*=.*/d}" -e"/^\[iaas\]/aIMAGE_ID = ${IMAGE_ID}" /etc/cpsdirector/director.cfg

echo ServerName ${IP_ADDRESS} > /etc/apache2/conf.d/ip-servername.conf
echo ${IP_ADDRESS} | cpsconf.py

service apache2 start

cpsadduser.py ${EMAIL} ${USERNAME} ${PASSWORD}
cpsclient.py credentials ${DIRECTOR_URL} ${USERNAME} ${PASSWORD}
