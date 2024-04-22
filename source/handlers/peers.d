module glusterd_plus.handlers.peers;

import vibe.vibe;

import glusterd_plus.handlers.helpers;

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

}

