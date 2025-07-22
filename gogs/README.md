###### Self-hosted Gogs

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

**Create admin user**
```
docker exec -it -u git gogs bash -c \
    "./gogs admin create-user \
    --name={user_name}} \
    --password={user-password} \
    --email={user_email} \
    --admin=true"
```

**View compose logs**
```
http://server_ip/dozzle
```
