docker-cartodb
==============

That container provides a fully working cartodb development solution
without the installation hassle.

Just run and connect to locahost:3000 into you browser.

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
docker run -t -i fleu42/docker-cartodb -p 3000:3000 /bin/bash
```

You might need to add dev.localhost to your hosts file.

