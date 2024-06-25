import std.process;
import std.format;
import std.getopt;
import std.string;
import core.runtime;
import core.stdc.stdlib : exit;
import std.algorithm.searching;
import std.logger;

import serverino;
import vibe.data.json;

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

@onWorkerStart void workerStart()
{
    auto cliSettings = deserializeJson!GlusterCLISettings(environment["clisettings"]);
    glusterCliSetup(cliSettings);
}

@onServerInit ServerinoConfig configure()
{
    ServerinoConfig sc = ServerinoConfig.create();
    sc.addListener("0.0.0.0", config.port);
    sc.setWorkerUser("root");
    sc.setWorkerGroup("root");

    return sc;
}

@onDaemonStart void setup()
{
    auto args = Runtime.args;

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
        exit(0);
    }

    // TODO: Handle above config as command args
    auto cliSettings = GlusterCLISettings();
    cliSettings.glusterCommand = config.glusterCommand;
    cliSettings.localhostAddress = config.address;
    environment["clisettings"] = serializeToJsonString(cliSettings);
    environment["config"] = serializeToJsonString(config);

    metricsInitialize;
    auto logger = new FileLogger("app.log");
    logger.info("Static files directory is set to " ~ STATIC_FILES_DIR);
}

mixin ServerinoMain!(handlers.peers, handlers.volumes, handlers.metrics, handlers.ui);
