FROM mariadb:11.8.2

ENV TZ=Europe/Moscow
ENV MARIADB_ROOT_PASSWORD=db_root_password
ENV MARIADB_USER=flask_app_user
ENV MARIADB_PASSWORD=flask_app_password
ENV MARIADB_DATABASE=flask_app_db

COPY init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306

VOLUME /var/lib/mysql