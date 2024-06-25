module handlers.volumes;

import serverino;

import handlers.helpers;
import glustercli.helpers;

@endpoint @route!((r) => r.pathMatch("Post", "/api/v1/volumes"))
void createVolume(Request req, Output res)
{

}

@endpoint @route!((r) => r.pathMatch("Get", "/api/v1/volumes"))
void listVolumes(Request req, Output res)
{
    auto volumes = _cli.listVolumes;
    res.writeJsonBody(volumes);
}

@endpoint @route!((r) => r.pathMatch("Delete", "/api/v1/volumes/:name"))
void deleteVolume(Request req, Output res)
{

}

@endpoint @route!((r) => r.pathMatch("Get", "/api/v1/volumes/:name"))
void getVolume(Request req, Output res)
{

}

@endpoint @route!((r) => r.pathMatch("Post", "/api/v1/volumes/:name/start"))
void startVolume(Request req, Output res)
{

}

@endpoint @route!((r) => r.pathMatch("Post", "/api/v1/volumes/:name/stop"))
void stopVolume(Request req, Output res)
{

}
