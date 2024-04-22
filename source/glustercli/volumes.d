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

mixin template volumesFunctions()
{
    void createVolume(string name, )
    {

    }

    void startVolume(string name)
    {

    }

    void stopVolume(string name)
    {

    }

    Volume[] listVolumes(bool status = false)
    {
        Volume[] volumes;
        return volumes;
    }

    Volume getVolume(string name, bool status = false)
    {
        Volume volume;
        return volume;
    }

    void deleteVolume(string name)
    {

    }
}
