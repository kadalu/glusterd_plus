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

}

void getVolumeHandler(ref HttpRequestContext ctx)
{

}

void startVolumeHandler(ref HttpRequestContext ctx)
{

}

void stopVolumeHandler(ref HttpRequestContext ctx)
{

}
