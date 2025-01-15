#!/bin/bash
set -e
if [  ! -f "/etc/letsencrypt/live/${NEW_OPENIMIS_HOST}/fullchain.pem" ]; then
  mkdir -p /etc/letsencrypt/live/${NEW_OPENIMIS_HOST}
  echo "copying certificates to  /etc/letsencrypt/live/${NEW_OPENIMIS_HOST}/"
  cp -a /etc/nginx/ssl/live/host/. /etc/letsencrypt/live/${NEW_OPENIMIS_HOST}/
fi
REF=$(date +'%m%d%Y%p')
[[ ${FORCE_RELOAD} -eq 1 ]] && REDIRECT_TAIL="&${REF}" || REDIRECT_TAIL=''
rm -f /etc/nginx/conf.d/openIMIS.confs
rm -f /etc/nginx/conf.d/default.conf

VARS_TO_REPLACE="$(printenv | grep -Eo "^([A-Z_]*)" | xargs -I % echo \$\{%\}, | xargs)"
echo "replacing ENV vars in openIMIS.conf"
envsubst  "\${REDIRECT_TAIL}, ${VARS_TO_REPLACE::-1}" < /conf/openimis.conf > /etc/nginx/conf.d/openIMIS.conf

# add the parts 
if [ -d '/conf/locations' ]; then
  echo "loading the location specific conf in openIMIS.conf"
  if [ !  -d '/etc/nginx/conf.d/locations' ]; then
      mkdir -p /etc/nginx/conf.d/locations
  else
    rm /etc/nginx/conf.d/locations/*
  fi
  if [ !  -d '/etc/nginx/conf.d/variables' ]; then
      mkdir -p /etc/nginx/conf.d/variables
  fi
  cp /conf/variables/var.conf /etc/nginx/conf.d/variables/var.conf
  multiline_content="#include the configuration use in the loc files\ninclude conf.d/variables/var.conf;\n# include the  loc files\ninclude conf.d/locations/*.loc;"
  echo "cleaning old config"
  
  # Use sed to replace ###PLACEHOLDER### with multiline content
  sed -i "s|###INCLUDE_PLACEHOLDER###|${multiline_content}|g" /etc/nginx/conf.d/openIMIS.conf
  for file in /conf/locations/*
  do
    [ -f "$file" ] || continue
    filename=$(basename "$file")
    echo "${file} saved in /etc/nginx/conf.d/locations/$filename"
    envsubst  "${VARS_TO_REPLACE::-1}" < "$file" > "/etc/nginx/conf.d/locations/$filename"
  done

fi

curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt -y install nodejs git nano 
npm install --global yarn 
cd /conf/openimis-fe_js
yarn  load-config openimis.json
yarn install 
cd /conf/openimis-fe_js
REF=$(date +'%m%d%Y%p')
[[ ${FORCE_RELOAD} -eq 1 ]] && REDIRECT_TAIL="&${REF}" || REDIRECT_TAIL=''
rm -f /etc/nginx/conf.d/openIMIS.confs
rm -f /etc/nginx/conf.d/default.conf
cp  /conf/openimis-comores.conf /etc/nginx/conf.d/openIMIS.conf
VARS_TO_REPLACE="$(printenv | grep -Eo "^([A-Z_]*)" | xargs -I % echo \$\{%\}, | xargs)"
envsubst  "\${REDIRECT_TAIL}, ${VARS_TO_REPLACE::-1}" < /conf/openimis-comores.conf > /etc/nginx/conf.d/openIMIS.conf
echo "Hosting on https://""$NEW_OPENIMIS_HOST"
echo "root uri $PUBLIC_URL"
echo "root api $REACT_APP_API_URL"
echo "root restapi $ROOT_MOBILEAPI"
cp /conf/frontend-comores.loc /etc/nginx/conf.d/locations/frontend.loc
cd /conf/openimis-fe_js
yarn start

ln -s -f  /usr/share/nginx/html /usr/share/nginx/html/${PUBLIC_URL}
echo "Hosting on https://""$NEW_OPENIMIS_HOST"
echo "root uri $PUBLIC_URL"
echo "root api $REACT_APP_API_URL"
echo "root restapi $ROOT_MOBILEAPI"

exec "$@"