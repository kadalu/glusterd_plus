module glusterd_plus.glustercli.peers;

struct Peer
{
    string address;
    string id;
    string state;
}

mixin template peersFunctions()
{
    void addPeer(string address)
    {
        
    }

    Peer[] listPeers()
    {
        Peer[] peers;
        return peers;
    }

    void deletePeer(string address)
    {
        
    }
}
