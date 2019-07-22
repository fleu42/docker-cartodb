acl purge {
    "localhost";
    "127.0.0.1";
}

backend sqlapi {
    .host = "127.0.0.1";
    .port = "8080";
}

backend windshaft {
    .host = "127.0.0.1";
    .port = "8181";
}

sub vcl_recv {
    # Allowing PURGE from localhost
    if (req.request == "PURGE") {
        if (!client.ip ~ purge) {
            error 405 "Not allowed.";
        }
        return (lookup);
    }

    # Routing request to backend based on X-Carto-Service header from nginx
    if (req.http.X-Carto-Service == "sqlapi") {
        set req.backend = sqlapi;
        remove req.http.X-Carto-Service;
    }
    if (req.http.X-Carto-Service == "windshaft") {
        set req.backend = windshaft;
        remove req.http.X-Carto-Service;
    }
}

sub vcl_hit {
    if (req.request == "PURGE") {
        purge;
        error 200 "Purged.";
    }
}

sub vcl_miss {
    if (req.request == "PURGE") {
        purge;
        error 200 "Purged.";
    }
}
