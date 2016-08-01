server {
  listen 80;
  server_name jenkins.mattinielsen.com;
  return 301 https://$host$request_uri;
}

server {

  listen 80;
  server_name jenkins.mattinielsen.com;

  location / {
    proxy_set_header        Host $host:$server_port;
    proxy_set_header        X-Real-IP $remote_addr;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto $scheme;

    # Fix the "It appears that your reverse proxy set up is broken" error.
    proxy_pass          http://127.0.0.1:8080;
    proxy_read_timeout  90;

    proxy_redirect      http://127.0.0.1:8080 https://jenkins.mattinielsen.com;
  }
}

