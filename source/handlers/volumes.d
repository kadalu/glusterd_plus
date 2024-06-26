module handlers.volumes;

import handy_httpd;

import handlers.helpers;
import glustercli.helpers;

void createVolumeHandler(ref HttpRequestContext ctx)
{

}

void listVolumesHandler(ref HttpRequestContext ctx)
{
    auto volumes = _cli.listVolumes;
    ctx.response.writeJsonBody(volumes);
}

void deleteVolumeHandler(ref HttpRequestContext ctx)
{
    auto name = ctx.request.pathParams["name"];
    _cli.deleteVolume(name);
}

void getVolumeHandler(ref HttpRequestContext ctx)
{

}

void startVolumeHandler(ref HttpRequestContext ctx)
{
    auto name = ctx.request.pathParams["name"];
    _cli.startVolume(name, ctx.request.boolQueryParam("force"));
}

void stopVolumeHandler(ref HttpRequestContext ctx)
{
    auto name = ctx.request.pathParams["name"];
    _cli.stopVolume(name);
}
