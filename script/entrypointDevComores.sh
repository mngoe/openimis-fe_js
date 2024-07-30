
curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt -y install nodejs git nano 
apt-get install npm
npm install --global yarn 
cd /conf/openimis-fe_js
yarn  load-config openimis.json
yarn install 
cd /conf/openimis-fe-insuree
yarn install
yarn build
yarn link
cd /conf/openimis-fe-policy
yarn install
yarn build
yarn link
apt-get remove nodejs -y
curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt-get install nodejs -y
cd /conf/openimis-fe_js
yarn link "@openimis/fe-insuree"
yarn link "@openimis/fe-policy"
REF=$(date +'%m%d%Y%p')
[ ${FORCE_RELOAD} -eq 1 ] && REDIRECT_TAIL="&${REF}" || REDIRECT_TAIL=''
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
service nginx reload
cd /conf/openimis-fe_js
yarn start 
