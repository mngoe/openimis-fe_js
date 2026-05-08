FROM node:20 AS dev-stage

RUN apt-get update && apt-get install -y --no-install-recommends \
    nano openssl software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/privkey.pem \
    -out /etc/ssl/private/fullchain.pem \
    -subj "/C=DE/ST=_/L=_/O=_/OU=_/CN=localhost"

RUN mkdir -p /home/node/.npm-global \
    && chown node:node /home/node/.npm-global
RUN mkdir -p /usr/local/lib/node_modules \
    && chown node:node /usr/local/lib/node_modules

WORKDIR /workspace/openimis-fe_js
ENV NODE_ENV=development
ENV CHOKIDAR_USEPOLLING=true
ENV WATCHPACK_POLLING=true
USER node
ENTRYPOINT ["/bin/bash", "/workspace/openimis-fe_js/script/entrypoint-dev-all.sh"]

FROM dev-stage AS base
USER node
ENV GENERATE_SOURCEMAP=true
ENV NODE_ENV=production

FROM base AS build-stage
WORKDIR /app
COPY --chown=node:node ./ /app
ARG OPENIMIS_CONF_JSON
ENV OPENIMIS_CONF_JSON=${OPENIMIS_CONF_JSON}
ENV NODE_ENV=production
ENV NODE_OPTIONS=--max-old-space-size=4096
RUN yarn load-config
RUN yarn install --frozen-lockfile || yarn install
RUN yarn build

FROM nginx:latest
COPY --from=build-stage /app/build/ /usr/share/nginx/html
COPY --from=build-stage /etc/ssl/private/ /etc/nginx/ssl/live/host
COPY ./conf /conf
COPY ./script/entrypoint.sh /script/entrypoint.sh
RUN chmod a+x /script/entrypoint.sh
WORKDIR /script
ENV DATA_UPLOAD_MAX_MEMORY_SIZE=12582912
ENV NEW_OPENIMIS_HOST="localhost"
ENV PUBLIC_URL="front"
ENV REACT_APP_API_URL="api"
ENV ROOT_MOBILEAPI="rest"
ENV FORCE_RELOAD=""
ENTRYPOINT ["/bin/bash", "/script/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
