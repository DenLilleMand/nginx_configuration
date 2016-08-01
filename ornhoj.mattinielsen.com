server {
  listen 80;

  server_name ornhoj.mattinielsen.com;

  access_log   /var/log/nginx/ornhoj.mattinielsen.com.access.log;
  error_log    /var/log/nginx/ornhoj.mattinielsen.com.error.log;

  root /var/www/ornhoj.mattinielsen.com/html/ornhoj/;
  index index.php index.html index.htm;

  port_in_redirect off;

  location / { 
    try_files $uri $uri/ =404;
  }

  error_page 404 /404.html;
  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
    root /usr/share/nginx/html;
  }

  location ~ \.php$ {
    try_files $uri =404;
    fastcgi_split_path_info ^(.+\.php)(.*)$;
    fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    fastcgi_index index.php;
    fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;
  }
}

