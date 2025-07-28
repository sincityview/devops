docker run -d --rm --name=app-registry-srv -v data-registry:/var/lib/registry -e REGISTRY_HTTP_ADDR=127.0.0.1:5123 -p 5123:5123 registry:3



server {

    server_name registry.8two.ru;

    merge_slashes off;
    rewrite (.*)//+(.*) $1/$2 permanent;

    location / {
        proxy_pass http://127.0.0.1:5123;
        proxy_buffering off;
        proxy_set_header X-Real-IP $remote_addr;
    }

    access_log /var/log/nginx/8two/registry-access.log;
    error_log /var/log/nginx/8two/registry-error.log;

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/registry.8two.ru/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/registry.8two.ru/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

nslookup registry.8two.ru

venv/bin/certbot --nginx


docker tag nginx:1.29 registry.8two.ru/nginx
docker push registry.8two.ru/nginx


https://registry.8two.ru/v2/_catalog
https://registry.8two.ru/v2/memos/tags/list

/v2/ — корневая точка входа
/v2/_catalog — получение списка всех репозиториев
/v2/{name}/tags/list — список тегов для репозитория
/v2/{name}/manifests/{tag} — получение манифеста образа
/v2/{name}/blobs/{digest} — работа со слоями образа


<!-- 
registry:
  restart: always
  image: registry:3
  ports:
    - 5000:5000
  environment:
    REGISTRY_HTTP_TLS_CERTIFICATE: /certs/domain.crt
    REGISTRY_HTTP_TLS_KEY: /certs/domain.key
    REGISTRY_AUTH: htpasswd
    REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
    REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
  volumes:
    - /path/data:/var/lib/registry
    - /path/certs:/certs
    - /path/auth:/auth 
-->