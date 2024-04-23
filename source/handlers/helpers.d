module glusterd_plus.handlers.helpers;

import vibe.http.server;

import glusterd_plus.glustercli;

GlusterCLI _cli;

void glusterCliSetup(GlusterCLISettings settings)
{
    _cli = new GlusterCLI(settings);
}

void sendErrorJsonResponse(HTTPServerResponse res, string error, int code = 400)
{
    res.statusCode = code;
    res.writeJsonBody(["error": error]);
}
