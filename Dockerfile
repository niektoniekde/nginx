FROM docker.io/alpine:latest

# install nginx and bash packages
RUN apk --no-cache add nginx bash
# address CVE-2022-3996
RUN apk upgrade libssl3 libcrypto3

# prepare local configuration structure
RUN mkdir -p /usr/local/etc/nginx/conf.d
COPY conf/nginx.conf /usr/local/etc/nginx/nginx.conf
RUN chown -R root: /usr/local/etc/nginx
RUN chmod -R u=rwX,go=rX /usr/local/etc/nginx

# prepare data volume mountpoint
RUN mkdir -p /srv/data

# volumes declarations
VOLUME /usr/local/etc/nginx/conf.d
VOLUME /srv/data

# prepare entrypoint
COPY entrypoint.bash /usr/local/bin/entrypoint.bash
RUN chmod u=rwx,go=rx /usr/local/bin/entrypoint.bash

# 'nginx' user is present after
#  installing 'nginx' software via apk
USER nginx
ENTRYPOINT ["/usr/local/bin/entrypoint.bash"]
