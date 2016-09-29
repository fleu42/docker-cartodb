docker-cartodb
==============

[![](https://images.microbadger.com/badges/image/sverhoeven/cartodb.svg)](https://microbadger.com/#/images/sverhoeven/cartodb "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/sverhoeven/cartodb.svg)](https://hub.docker.com/r/sverhoeven/cartodb/)

This docker container provides a fully working cartodb development solution
without the installation hassle.

Just run the commands and then connect to http://cartodb.localhost with your you browser.

The default login is dev/pass1234. You may want to change it when you'll run
it for the outside.

It also creates an 'example' organization with owner login admin4example/pass1234.
Organization members can be created on http://cartodb.localhost/user/admin4example/organization

How to build the container:
---------------------------

```
git clone https://github.com/sverhoeven/docker-cartodb.git
docker build -t="sverhoeven/cartodb" docker-cartodb/
```

How to run the container:
-------------------------

```
docker run -d -p 3000:3000 -p 8080:8080 -p 8181:8181 sverhoeven/cartodb
```

The ports the cartodb container publishes must be combined behind a single [NGINX](http://nginx.org/) web server. 
In the GitHub repo there is an [example NGINX config file (config/cartodb.nginx.proxy.conf)](https://github.com/sverhoeven/docker-cartodb/blob/master/config/cartodb.nginx.proxy.conf), which needs to be added to /etc/nginx/conf.d/ directory, after which the web server must be restarted.
This will setup a reverse proxy for the CartoDB/imports (3000), SQL Api (8080) and Map api (8181) to default http port (80).
Alternativly use instructions at https://hub.docker.com/r/spawnthink/cartodb-nginx/ to run NGINX as a docker container with the correct config file already in it.

The CartoDB instance has been configured with the hostname `cartodb.localhost`, this means the web browser and web server need to be able to resolve `cartodb.localhost` to the machine where the web server is running.
This can be done by adding cartodb.localhost alias to your hosts file. For example
```
sudo sh -c 'echo 127.0.1.1 cartodb.localhost >> /etc/hosts'
```
(For Windows it will be `C:\Windows\System32\drivers\etc\hosts`)
