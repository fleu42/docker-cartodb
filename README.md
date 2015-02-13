docker-cartodb
==============

That container provides a fully working cartodb development solution
without the installation hassle.

Just run and connect to http://dev.cartodb.localhost:3000/login into you browser.

The default login is dev/pass. You may want to change it when you'll run
it for the outside.

How to build the container:
--------------

```
git clone https://github.com/fleu42/docker-cartodb.git
docker build -t="fleu42/docker-cartodb" docker-cartodb/
```

How to run the container:
--------------

```
docker run -t -i -p 3000:3000 -p 8080:8080 -p 8181:8181 fleu42/docker-cartodb 
```

You might need to add cartodb.localhost and dev.cartodb.localhost to your hosts file.

