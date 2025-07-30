#### Docker images and network
------

<br />

```mermaid
flowchart LR
    A[host:80] --> B[nginx:80:5000]
    B --> C[flask:5000:5000]
    C --> D[mariadb:3306:3306]
```

<br />

$ docker images
```
mariadb:11.8.2
python:3.10-slim
```

Docker network create
```
docker network create app-network
```

<br />

#### Build and run app-mariadb
------

$ cd mariadb

$ cat Dockerfile
```
FROM mariadb:11.8.2

ENV MARIADB_ROOT_PASSWORD=db_root_password
ENV TZ=Europe/Moscow

COPY init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306

VOLUME /var/lib/mysql
```

$ cat init.sql
```
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(80) NOT NULL UNIQUE,
    email VARCHAR(120) NOT NULL UNIQUE
);

INSERT INTO users (username, email) VALUES('username', 'email@example.com');
```

$ docker build -t app-mariadb:11.8.2 .

Environments for mariadb:
```
TZ
MARIADB_ROOT_PASSWORD
MARIADB_USER
MARIADB_PASSWORD
MARIADB_DATABASE
```

$ docker run -d --rm --name=app-mariadb --network app-network -p 3306:3306 app-mariadb:11.8.2

docker exec -it app-mariadb bash -c "mariadb -uflask_app_user -pflask_app_password -e 'SELECT * from flask_app_db.users;'"
```
+----+----------+-------------------+
| id | username | email             |
+----+----------+-------------------+
|  1 | username | email@example.com |
+----+----------+-------------------+
```

<br />

#### Build and run app-flask
------

$ cd flask

$ cat Dockerfile
```
FROM python:3.10-slim

WORKDIR /app

COPY . /app

RUN apt-get update && apt-get install build-essential libmariadb-dev -y
RUN pip install --no-cache-dir -U pip && pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

CMD ["gunicorn", "app:app", "-b 0:8000"]
```

$ docker build -t app-flask:3.10-slim .

$ docker run -d --rm --name=app-flask --network app-network -p 8000:8000 -e APP_DB_HOST=app-mariadb app-flask:3.10-slim

<br />

#### Build and run app-nginx
------

$ cd nginx

$ cat Dockerfile
```
FROM nginx:1.29

ENV APP_HOST=127.0.0.1

COPY nginx.conf /etc/nginx/conf.d/default.conf.template
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
```

$ cat entrypoint.sh
```
#!/bin/bash
set -e

envsubst < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

exec nginx -g "daemon off;"
```

$ cat nginx.conf
```
server {
    
    listen 80;

    location / {
        proxy_pass http://${APP_HOST}:5000/;
    }

}
```

$ docker build -t app-nginx:1.29 .

$ docker run --rm --name=nginx --network app-network -p 8000:8000 -e APP_HOST=flask app-nginx:1.29

$ curl localhost
```
<!DOCTYPE html>
<html>
<head>
    <title>Users</title>
</head>
<body>

    Flask App with Mariadb connection: <br>
    
        username: username <br>
        email: email@example.com
    

</body>
</html>
```