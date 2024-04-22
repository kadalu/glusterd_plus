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
    void createVolume(string name, )
    {

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
        startStopVolume(name, start: true, force: force);
    }

    void stopVolume(string name, bool force = false)
    {
        startStopVolume(name, start: false, force: force);
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
