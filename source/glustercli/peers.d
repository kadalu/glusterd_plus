module glusterd_plus.glustercli.peers;

struct Peer
{
    string address;
    string id;
    string state;
}

Peer[] parsePeersFromPoolList(string[] lines)
{
    Peer[] peers;
    return peers;
}

mixin template peersFunctions()
{
    void addPeer(string address)
    {
        auto cmd = ["peer", "probe", address];
        executeGlusterCmd(cmd);
    }

    Peer[] listPeers()
    {
        auto cmd = ["pool", "list"];
        auto outlines = executeGlusterCmdXml(cmd);

        return parsePeersFromPoolList(outlines);
    }

    void deletePeer(string address)
    {
        auto cmd = ["peer", "detach", address];
        executeGlusterCmd(cmd);
    }
}
