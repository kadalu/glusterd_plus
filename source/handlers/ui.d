module handlers.ui;

import std.algorithm;

import handy_httpd;

import handlers.helpers;

version (Release)
    const STATIC_FILES_DIR = "/var/lib/glusterdplus/public";
else
    const STATIC_FILES_DIR = "public";

void homeHandler(ref HttpRequestContext ctx)
{
    ctx.response.render!"index.dt";
}

void dashboardHandler(ref HttpRequestContext ctx)
{
    ctx.response.render!"dashboard.dt";
}

void loginHandler(ref HttpRequestContext ctx)
{
    ctx.response.render!"login.dt";
}

void peersHandler(ref HttpRequestContext ctx)
{
    ctx.response.render!"peers.dt";
}

void volumesHandler(ref HttpRequestContext ctx)
{
    ctx.response.render!"volumes.dt";
}
