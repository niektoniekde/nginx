# Description
Image based on official Alpine Linux image with ``nginx`` and ``bash`` installed via apk.
Entrypoint is ``entrypoint.bash`` BASH script executing following actions:
* check if there is includable configuration in ``/usr/local/etc/nginx/conf.d`` (exit with error if there is none)
* create ``/srv/data/log`` directory if not already present (``/srv/data`` is volume)
* launch ``nginx`` with custom basic config (``-c``) and without daemon mode (``-g 'daemon off;``)

## Configuration
Custom basic configuration file provided as parameter to ``nginx`` sets only
``worker_processes``, ``pcre_jit``, ``error_log`` directives and then includes
following configuration files as contexts configuration
* ``/usr/local/etc/nginx/conf.d/events``
* ``/usr/local/etc/nginx/conf.d/http``
* ``/usr/local/etc/nginx/conf.d/stream``

This directory is volume and it should be mount in Read-Only mode.

With above in mind it's obvious that all configuration is expected to be provided
by included configuration files. That's why entrypoint script fails with error
when there are none.

Distribution default directory ``/etc/nginx`` and its files are preserved.

## Volumes
There are two volumes by default, one for configuration files and one for persistent data:
* ``/usr/local/etc/nginx/conf.d`` - configuration files
* ``/srv/data`` - persistent data

## Conexts configuration examples
### events
```
events {
  worker_connections 1024;
}
```
### http
```
http { 
  ## use distribution provided mime.types 
  include /etc/nginx/mime.types;
  ## distro defaults
  default_type application/octet-stream;
  server_tokens off;
  
  client_max_body_size 1m;
  sendfile on;
  tcp_nopush on;
  ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:2m;
  ssl_session_timeout 1h;
  ssl_session_tickets off;
  #gzip on;
  gzip_vary on;
  map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
  }
  log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent" "$http_x_forwarded_for"';
  
  ## set access_log in same convention as error_log
  access_log /srv/data/nginx/log/access.log main;
  ## include another http context configuration by wildcard
  include /usr/local/etc/nginx/conf.d/http_*.conf;
}
```

