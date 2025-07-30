#### Docker images and network
------

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

#### Build mariadb for app
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
CREATE DATABASE IF NOT EXISTS flask_app_db;
CREATE USER 'flask_app_user'@'%' IDENTIFIED BY 'flask_app_password';

USE flask_app_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(80) NOT NULL UNIQUE,
    email VARCHAR(120) NOT NULL UNIQUE
);

INSERT INTO users (username, email) VALUES('flask-mariadb', 'flask-mariadb@username.com')

GRANT ALL PRIVILEGES ON flask_app_db.* TO 'flask_app_user'@'%';
FLUSH PRIVILEGES;
```

$ docker build -t app-mariadb:11.8.2 .

$ docker run -d --rm --name=app-mariadb -v mariadb:/var/lib/mysql --network app-network -p 3306:3306 app-mariadb:11.8.2

docker exec -it app-mariadb bash -c "mariadb -uflask_app_user -pflask_app_password -e 'SELECT * from flask_app_db.users;'"
```
+----+---------------+----------------------------+
| id | username      | email                      |
+----+---------------+----------------------------+
|  1 | flask-mariadb | flask-mariadb@username.com |
+----+---------------+----------------------------+
```

$ cd flask-app

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

$ curl 127.0.0.1:8000
```
<!DOCTYPE html>
<html>
<head>
    <title>Users</title>
</head>
<body>

    Flask App with Mariadb connection: <br>
        
        username: flask-mariadb <br>
        email: flask-mariadb@username.com

</body>
</html>
```