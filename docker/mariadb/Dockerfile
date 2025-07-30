FROM mariadb:11.8.2

ENV MARIADB_ROOT_PASSWORD=db_root_password
ENV TZ=Europe/Moscow

COPY init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306

VOLUME /var/lib/mysql