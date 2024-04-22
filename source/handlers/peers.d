module glusterd_plus.handlers.peers;

import vibe.vibe;

import glusterd_plus.handlers.helpers;
import glusterd_plus.glustercli.helpers;

void addPeer(HTTPServerRequest req, HTTPServerResponse res)
{

}

void listPeers(HTTPServerRequest req, HTTPServerResponse res)
{
    auto peers = _cli.listPeers;
    res.writeJsonBody(peers);
}

void deletePeer(HTTPServerRequest req, HTTPServerResponse res)
{
    auto peerAddress = req.params.get("address");
    try {
        _cli.deletePeer(peerAddress);
        res.statusCode = 204;
        res.writeJsonBody(null);
    } catch(GlusterCommandException err) {
        res.statusCode = 500;
        res.writeJsonBody(["error": "Failed to delete the Peer", "message": err.msg]);
    }
}

