module glusterd_plus.glustercli.volumes;

struct Brick
{
    string host;
    string path;
    int port;
}

struct DistributeGroup
{
    string type;
    Brick[] bricks;
}

struct Volume
{
    string id;
    string name;
    string type;
    DistributeGroup[] distributeGroups;
}

struct VolumeCreateOptions
{
    int replicaCount;
    int arbiterCount;
    int disperseCount;
    int disperseRedundancyCount;
    int disperseDataCount;
    string transport;
    bool force;
}

Volume[] parseVolumeInfo(string[] lines)
{
    Volume[] volumes;
    return volumes;
}

Volume[] parseVolumeStatus(string[] lines)
{
    Volume[] volumes;
    return volumes;
}

mixin template volumesFunctions()
{
    void createVolume(string name, string[] bricks, VolumeCreateOptions opts)
    {
        import std.format;

        auto cmd = ["volume", "create", name];
        if (opts.replicaCount > 0)
            cmd ~= ["replica", format!"%d"(opts.replicaCount)];

        if (opts.arbiterCount > 0)
            cmd ~= ["arbiter", format!"%d"(opts.arbiterCount)];

        if (opts.disperseCount > 0)
            cmd ~= ["disperse", format!"%d"(opts.disperseCount)];

        if (opts.disperseDataCount > 0)
            cmd ~= ["disperse-data", format!"%d"(opts.disperseDataCount)];

        if (opts.disperseRedundancyCount > 0)
            cmd ~= ["redundancy", format!"%d"(opts.disperseRedundancyCount)];

        if (opts.transport != "tcp" && opts.transport != "")
            cmd ~= ["transport", opts.transport];

        cmd ~= bricks;

        if (opts.force)
            cmd ~= ["force"];

        executeGlusterCmd(cmd);
    }

    private void startStopVolume(string name, bool start = true, bool force = false)
    {
        string action = start ? "start" : "stop";
        auto cmd = ["volume", action, name];
        if (force)
            cmd ~= ["force"];

        executeGlusterCmd(cmd);
    }

    void startVolume(string name, bool force = false)
    {
        // dfmt off
        startStopVolume(name, start: true, force: force);
        // dfmt on
    }

    void stopVolume(string name, bool force = false)
    {
        // dfmt off
        startStopVolume(name, start: false, force: force);
        // dfmt on
    }

    Volume[] listVolumes(bool status = false)
    {
        auto cmd = ["volume", "info"];

        auto outlines = executeGlusterCmdXml(cmd);
        return parseVolumeInfo(outlines);
    }

    Volume getVolume(string name, bool status = false)
    {
        auto cmd = ["volume", "info", name];

        auto outlines = executeGlusterCmdXml(cmd);
        auto vols = parseVolumeInfo(outlines);
        return vols[0];
    }

    void deleteVolume(string name)
    {
        executeGlusterCmd(["volume", "delete", name]);
    }
}
