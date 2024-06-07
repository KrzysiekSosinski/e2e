FROM nikolaik/python-nodejs:latest AS builder


WORKDIR /ngfp-host

RUN #apk update && apk upgrade openssl busybox libxml2 dav1d libxpm zlib

COPY package*.json ./

RUN npm install

COPY . .

RUN npx nx run ngfp-host:build:production

COPY module-federation.manifest.json ./dist/apps/ngfp-host/assets/

#Download NGINX Image
FROM nginx:stable-alpine AS runtime

RUN apk update && apk add --no-cache su-exec openssl busybox libxml2 dav1d libxpm zlib

RUN rm -rf /usr/share/nginx/html/*

# Copy built angular files to NGINX HTML folder
COPY --from=builder /ngfp-host/dist/apps/ngfp-host/ /usr/share/nginx/html
COPY --from=builder /ngfp-host/dist/apps/ngfp-flights-list/ /usr/share/nginx/html/flights-list

COPY nginx-prod.conf /etc/nginx/nginx-prod.conf
COPY nginx-test.conf /etc/nginx/nginx-test.conf

RUN mkdir -p /etc/nginx/logs /var/cache/nginx/client_temp /run/nginx /var/log/nginx \
    && chown -R nginx:nginx /var/cache/nginx /etc/nginx/logs /run/nginx /var/log/nginx /etc/nginx

RUN chmod u+s /sbin/su-exec

COPY nginx-test-config-script.sh /usr/local/bin/nginx-test-config-script.sh
RUN chmod u+x /usr/local/bin/nginx-test-config-script.sh
RUN chown nginx:nginx /usr/local/bin/nginx-test-config-script.sh

USER nginx

EXPOSE 8081

ARG NGINX_CONFIG

ENTRYPOINT ["/usr/local/bin/nginx-test-config-script.sh"]
