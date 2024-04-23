module glusterd_plus.handlers.volumes;

import vibe.http.server;

import glusterd_plus.handlers.helpers;
import glusterd_plus.glustercli.helpers;

void createVolume(HTTPServerRequest req, HTTPServerResponse res)
{

}

void listVolumes(HTTPServerRequest req, HTTPServerResponse res)
{
    auto volumes = _cli.listVolumes;
    res.writeJsonBody(volumes);
}

void deleteVolume(HTTPServerRequest req, HTTPServerResponse res)
{

}

void getVolume(HTTPServerRequest req, HTTPServerResponse res)
{

}

void startVolume(HTTPServerRequest req, HTTPServerResponse res)
{

}

void stopVolume(HTTPServerRequest req, HTTPServerResponse res)
{

}
