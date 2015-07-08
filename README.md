docker-cartodb
==============

That container provides a fully working cartodb development solution
without the installation hassle.

Just run and connect to http://cartodb.localhost into you browser.

The default login is dev/pass1234. You may want to change it when you'll run
it for the outside.

It also creates an 'example' organization with owner login admin4example/pass1234.
Organization members can be created on http://cartodb.localhost/user/admin4example/organization

How to build the container:
---------------------------

```
git clone https://github.com/fleu42/docker-cartodb.git
docker build -t="fleu42/docker-cartodb" docker-cartodb/
```

How to run the container:
-------------------------

```
docker run -d -p 3000:3000 -p 8080:8080 -p 8181:8181 fleu42/docker-cartodb
```

You need to add `config/cartodb.nginx.proxy.conf` to /etc/nginx/conf.d/.
This will setup a reverse proxy for the CartoDB/imports (3000), SQL Api (8080) and Map api (8181).

You also need to add cartodb.localhost alias to your hosts file. For example
```
sudo sh -c 'echo 127.0.1.1 cartodb.localhost >> /etc/hosts'
```
