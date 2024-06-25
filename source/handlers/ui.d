module handlers.ui;

import std.algorithm;

import serverino;

import handlers.helpers;

version (Release)
    const STATIC_FILES_DIR = "/var/lib/glusterdplus/public";
else
    const STATIC_FILES_DIR = "public";

@endpoint @route!((r) => r.pathMatch("Get", "/"))
void home(Request req, Output res)
{
    res.renderDiet!"index.dt";
}

@endpoint @route!((r) => r.pathMatch("Get", "/dashboard"))
void dashboard(Request req, Output res)
{
    res.renderDiet!"dashboard.dt";
}

@endpoint @route!((r) => r.pathMatch("Get", "/login"))
void login(Request req, Output res)
{
    res.renderDiet!"login.dt";
}

@endpoint @route!((r) => r.pathMatch("Get", "/peers"))
void peers(Request req, Output res)
{
    res.renderDiet!"peers.dt";
}

@endpoint @route!((r) => r.pathMatch("Get", "/volumes"))
void volumes(Request req, Output res)
{
    res.renderDiet!"volumes.dt";
}

@endpoint
@route!((r) => r.path.startsWith("/images/"))
@route!((r) => r.path.startsWith("/js/"))
void staticFiles(Request req, Output res)
{
    // TODO: Check if any validations needed for the req.path
    res.serveFile(STATIC_FILES_DIR ~ req.path);
}
