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