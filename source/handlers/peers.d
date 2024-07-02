module handlers.peers;

import handy_httpd;

import handlers.helpers;
import glustercli.helpers;

struct PeerRequest
{
    string address;
}

void addPeerHandler(ref HttpRequestContext ctx)
{
    ctx.request.validateRequestContentTypeJson;

    auto data = ctx.request.deserialize!PeerRequest;

    _cli.addPeer(data.address);
    ctx.response.setStatus(HttpStatus.CREATED);

    // TODO: Think about getting one peer info
    // instead of fetching peers list
    auto peers = _cli.listPeers();

    foreach (peer; peers)
    {
        if (peer.address == data.address)
            ctx.response.writeJsonBody(peer);
    }
}

void listPeersHandler(ref HttpRequestContext ctx)
{
    auto peers = _cli.listPeers;
    ctx.response.writeJsonBody(peers);
}

void deletePeerHandler(ref HttpRequestContext ctx)
{
    auto peerAddress = ctx.request.pathParams["address"];
    _cli.deletePeer(peerAddress);
    ctx.response.setStatus(HttpStatus.NO_CONTENT);
}
