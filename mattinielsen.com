server {
  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;

  root /var/www/mattinielsen.com/html;
  index index.html index.htm;

  server_name mattinielsen.com;

  location / {
    try_files $uri $uri/ =404;
  }
}

server {
  listen 80;
  server_name caribia.mattinielsen.com;

  #access_log   /var/log/nginx/caribia.mattinielsen.com.access.log;
  #error_log    /var/log/nginx/caribia.mattinielsen.com.error.log;

  root /var/www/caribia.mattinielsen.com/html/caribia;
  index index.php; 

  port_in_redirect off;

  location / {
    try_files $uri $uri/ /index.php?$args;
  }

# Cache static files for as long as possible
  location ~*.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|css|rss|atom|js|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf|cur)$ {
    expires max;
    log_not_found off;
    access_log off;
  }

# Deny public access to wp-config.php
  location ~* wp-config.php {
    deny all;
  }

  location ~ \.php$ {
    try_files $uri =404;
    include fastcgi_params;
    fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    fastcgi_split_path_info ^(.+\.php)(.*)$;
    fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
  }      
}
