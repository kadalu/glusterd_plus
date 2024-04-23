import std.process;
import std.format;
import std.getopt;

import vibe.vibe;

import glusterd_plus.handlers;
import glusterd_plus.glustercli;

void setJsonHeader(HTTPServerRequest req, HTTPServerResponse res)
{
    res.contentType = "application/json; charset=utf-8";
}

struct Config
{
    ushort port = 3000;
    string glusterCommand = "/usr/sbin/gluster";
    string localhostAddress;
    string accessLogFile;

    string address()
    {
        if (localhostAddress == "")
        {
            auto hostname = execute(["hostname", "-f"]);
            return hostname.output.strip;
        }

        return localhostAddress;
    }
}

int main(string[] args)
{
    auto config = Config();

    auto opts = getopt(
        args,
        std.getopt.config.passThrough,
        "p|port", "Glusterd Plus Port", &config.port,
        "g|gluster-command", "Gluster Command path", &config.glusterCommand,
        "a|address", "Localhost Address", &config.localhostAddress,
        "l|log-file", "Access log file path", &config.accessLogFile,
    );

    if (opts.helpWanted) {
        defaultGetoptPrinter("glusterd-plus [OPTIONS]", opts.options);
        // Vibe.d specific options
        printCommandLineHelp();
        return 1;
    }

    // TODO: Handle above config as command args
    auto cliSettings = GlusterCLISettings();
    cliSettings.glusterCommand = config.glusterCommand;
    cliSettings.localhostAddress = config.address;

    glusterCliSetup(cliSettings);

    auto settings = new HTTPServerSettings;
    settings.port = config.port;
    if (config.accessLogFile != "")
        settings.accessLogFile = config.accessLogFile;
    else
        settings.accessLogToConsole = true;

    settings.bindAddresses = ["::1", "127.0.0.1"];
    auto router = new URLRouter;

    router.any("/api/v1/*", &setJsonHeader);
    router.get("*", serveStaticFiles("public/"));

    // peer routes
    router.post("/api/v1/peers", &addPeer);
    router.get("/api/v1/peers", &listPeers);
    router.delete_("/api/v1/peers/:address", &deletePeer);

    // Volume routes
    router.post("/api/v1/volumes", &createVolume);
    router.get("/api/v1/volumes", &listVolumes);
    router.get("/api/v1/volumes/:name", &getVolume);
    router.delete_("/api/v1/volumes/:name", &deleteVolume);
    router.post("/api/v1/volumes/:name/start", &startVolume);
    router.post("/api/v1/volumes/:name/stop", &stopVolume);

    // UI Routing
    router.get("/", staticTemplate!"index.dt");
    router.get("/login", staticTemplate!"login.dt");
    router.get("/peers", staticTemplate!"peers.dt");
    router.get("/volumes", staticTemplate!"volumes.dt");
    router.get("/dashboard", staticTemplate!"dashboard.dt");

    auto listener = listenHTTP(settings, router);
    scope (exit)
    {
        listener.stopListening();
    }

    logInfo(format("Please open http://127.0.0.1:%d in your browser.", config.port));
    runApplication(&args);
    return 0;
}
