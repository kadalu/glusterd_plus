module handlers.volumes;

import handy_httpd;

import handlers.helpers;
import glustercli.helpers;

struct VolumeRequest
{
    string name;
    string[] bricks;
    int replicaCount;
    bool start;
    bool addPeers;
}

void createVolumeHandler(ref HttpRequestContext ctx)
{
    ctx.request.validateRequestContentTypeJson;

    auto data = ctx.request.deserialize!VolumeRequest;
}

void listVolumesHandler(ref HttpRequestContext ctx)
{
    auto volumes = _cli.listVolumes(ctx.request.boolQueryParam("status"));
    ctx.response.writeJsonBody(volumes);
}

void deleteVolumeHandler(ref HttpRequestContext ctx)
{
    auto name = ctx.request.pathParams["name"];
    _cli.deleteVolume(name);
    ctx.response.setStatus(HttpStatus.NO_CONTENT);
}

void getVolumeHandler(ref HttpRequestContext ctx)
{
    auto name = ctx.request.pathParams["name"];
    try
    {
        auto volume = _cli.getVolume(name, ctx.request.boolQueryParam("status"));
        ctx.response.writeJsonBody(volume);
    }
    catch (GlusterCommandException ex)
    {
        enforceHttpJson(ex.message != "Volume not found", HttpStatus.BAD_REQUEST, "Volume not found");
        throw ex;
    }
}

void startVolumeHandler(ref HttpRequestContext ctx)
{
    auto name = ctx.request.pathParams["name"];
    _cli.startVolume(name, ctx.request.boolQueryParam("force"));
    ctx.response.writeJsonBody(["ok": true]);
}

void stopVolumeHandler(ref HttpRequestContext ctx)
{
    auto name = ctx.request.pathParams["name"];
    _cli.stopVolume(name);
    ctx.response.writeJsonBody(["ok": true]);
}
