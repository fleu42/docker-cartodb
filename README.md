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
docker build -t=sverhoeven/cartodb docker-cartodb/
```

How to run the container:
-------------------------

```
docker run -d -p 80:80 -h cartodb.localhost sverhoeven/cartodb
```

The CartoDB instance has been configured with the hostname `cartodb.localhost`, this means the web browser and web server need to be able to resolve `cartodb.localhost` to an IP adress of the machine where the web server is running.
This can be done by adding cartodb.localhost alias to your hosts file. For example
```
sudo sh -c 'echo 127.0.1.1 cartodb.localhost >> /etc/hosts'
```
(For Windows it will be `C:\Windows\System32\drivers\etc\hosts`)

How to use a different hostname:
--------------------------------

For example to use `cartodb.example.com` as a hostname start with:
```
docker run -d -p 80:80 -h cartodb.example.com sverhoeven/cartodb
```

The chosen hostname should also resolve to an IP adress of the machine where the web server is running.
