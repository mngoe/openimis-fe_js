#!/bin/bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

nvm install 18.20.5
nvm install 16.20.2
nvm use 18.20.5

#curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
#bash nodesource_setup.sh
#apt -y install nodejs git nano
apt update
apt -y install git nano 
#apt-get install npm
npm install --global yarn 
cd /conf/openimis-fe_js
yarn  load-config openimis.json
yarn install 
cd /conf/openimis-fe-claim_js
yarn install
yarn build
yarn link
cd /conf/openimis-fe-core_js
yarn install
yarn build
yarn link
cd /conf/openimis-fe-insuree_js
yarn install
yarn build
yarn link
cd /conf/openimis-fe-policy_js
yarn install
yarn build
yarn link
cd /conf/openimis-fe-contribution_js
yarn install
yarn build
yarn link
#apt-get remove nodejs -y
#curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
#bash nodesource_setup.sh
#apt-get install nodejs -y
nvm use 16.20.2
npm install --global yarn
cd /conf/openimis-fe_js
yarn link "@openimis/fe-claim"
yarn link "@openimis/fe-core"
yarn link "@openimis/fe-insuree"
yarn link "@openimis/fe-policy"
yarn link "@openimis/fe-contribution"
REF=$(date +'%m%d%Y%p')
[ ${FORCE_RELOAD} -eq 1 ] && REDIRECT_TAIL="&${REF}" || REDIRECT_TAIL=''
rm -f /etc/nginx/conf.d/openIMIS.confs
rm -f /etc/nginx/conf.d/default.conf
cp  /conf/openimis-csu.conf /etc/nginx/conf.d/openIMIS.conf
VARS_TO_REPLACE="$(printenv | grep -Eo "^([A-Z_]*)" | xargs -I % echo \$\{%\}, | xargs)"
envsubst  "\${REDIRECT_TAIL}, ${VARS_TO_REPLACE::-1}" < /conf/openimis-csu.conf > /etc/nginx/conf.d/openIMIS.conf
echo "Hosting on https://""$NEW_OPENIMIS_HOST"
echo "root uri $PUBLIC_URL"
echo "root api $REACT_APP_API_URL"
echo "root restapi $ROOT_MOBILEAPI"
cp /conf/frontend-csu.loc /etc/nginx/conf.d/locations/frontend.loc
service nginx reload
cd /conf/openimis-fe_js
yarn start 