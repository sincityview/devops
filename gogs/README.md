#### Self-hosted Gogs
------

**Go to service directory**
```
cd gogs
```

**Startup docker containers**
```
docker compose up -d
```

**Install Gogs service**
```
http://server_ip/
```

**Create Gogs admin user**
```
docker exec -it -u git gogs bash -c \
    "./gogs admin create-user \
    --name={user_name}} \
    --password={user-password} \
    --email={user_email} \
    --admin=true"
```

**View docker stack logs**
```
http://server_ip/dozzle
```

**Output**
```
$ docker compose ps
 
 Name                Command                  State                          Ports                   
-----------------------------------------------------------------------------------------------------
dozzle    /dozzle                          Up             10.1.1.1:8002->8080/tcp                    
gogs      /app/gogs/docker/start.sh  ...   Up (healthy)   0.0.0.0:22->22/tcp, 10.1.1.1:8001->3000/tcp
mariadb   docker-entrypoint.sh mariadbd    Up             10.1.1.1:3306->3306/tcp  
```
