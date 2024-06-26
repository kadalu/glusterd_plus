import std.process;
import std.format;
import std.getopt;
import std.string;
import std.algorithm.searching;

import handy_httpd;
import handy_httpd.handlers;
import vibe.data.json;
import slf4d;

import handlers;
import handlers.peers;
import glustercli;

struct Config
{
    ushort port = 3000;
    string glusterCommand = "/usr/sbin/gluster";
    string localhostAddress;
    string accessLogFile;
    bool showURLRoutes;

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

Config config;

int main(string[] args)
{
    import etc.linux.memoryerror;
    static if (is(typeof(registerMemoryErrorHandler)))
        registerMemoryErrorHandler();

    // dfmt off
    auto opts = getopt(
        args,
        std.getopt.config.passThrough,
        "p|port", "Glusterd Plus Port", &config.port,
        "g|gluster-command", "Gluster Command path", &config.glusterCommand,
        "a|address", "Localhost Address", &config.localhostAddress,
        "l|log-file", "Access log file path", &config.accessLogFile,
        "routes", "Show all URL Routes", &config.showURLRoutes,
    );
    // dfmt on

    if (opts.helpWanted)
    {
        defaultGetoptPrinter("glusterd-plus [OPTIONS]", opts.options);
        return 0;
    }

    // TODO: Handle above config as command args
    auto cliSettings = GlusterCLISettings();
    cliSettings.glusterCommand = config.glusterCommand;
    cliSettings.localhostAddress = config.address;

    glusterCliSetup(cliSettings);
    metricsInitialize;

    infoF!"Static files directory={%s}"(STATIC_FILES_DIR);

    auto fileHandler = new FileResolvingHandler(STATIC_FILES_DIR);

    auto router = new PathHandler;
    router
        .addMapping(Method.POST, "/api/v1/peers", &addPeerHandler)
        .addMapping(Method.GET, "/api/v1/peers", &listPeersHandler)
        .addMapping(Method.DELETE, "/api/v1/peers/:address", &deletePeerHandler)
        .addMapping(Method.GET, "/metrics", &metricsPrometheusHandler)
        .addMapping(Method.GET, "/metrics.json", &metricsJsonHandler)

        .addMapping(Method.POST, "/api/v1/volumes", &createVolumeHandler)
        .addMapping(Method.GET, "/api/v1/volumes", &listVolumesHandler)
        .addMapping(Method.DELETE, "/api/v1/volumes/:name", &deleteVolumeHandler)
        .addMapping(Method.GET, "/api/v1/volumes/:name", &getVolumeHandler)
        .addMapping(Method.POST, "/api/v1/volumes/:name/start", &startVolumeHandler)
        .addMapping(Method.POST, "/api/v1/volumes/:name/stop", &stopVolumeHandler)

        .addMapping(Method.GET, "/", &homeHandler)
        .addMapping(Method.GET, "/dashboard", &dashboardHandler)
        .addMapping(Method.GET, "/login", &loginHandler)
        .addMapping(Method.GET, "/volumes", &volumesHandler)
        .addMapping(Method.GET, "/peers", &peersHandler)
        
        .addMapping(Method.GET, "/images/*", fileHandler)
        .addMapping(Method.GET, "/js/*", fileHandler);

    auto mainHandler = new FilteredRequestHandler(
        router,
        [new AuthFilter]
    );

    ServerConfig cfg;
    cfg.port = config.port;

    auto server = new HttpServer(mainHandler, cfg);
    server.setExceptionHandler(new AppExceptionHandler);
    server.start();

    return 0;
}

