module handlers.peers;

import handy_httpd;
import vibe.data.json;

import handlers.helpers;
import glustercli.helpers;

struct PeerRequest
{
    string address;
}

void addPeerHandler(ref HttpRequestContext ctx)
{
    enforceHttpJson(ctx.request.isJsonContentType, HttpStatus.BAD_REQUEST, "Invalid Content-type header. Use \"application/json\"");

    string peerAddress;
    PeerRequest data;

    // Validation
    try
    {
        data = deserializeJson!PeerRequest(ctx.request.readBodyAsString);
    }
    catch (JSONException)
    {
        ctx.sendErrorJsonResponse("Invalid JSON data");
        return;
    }

    try
    {
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
    catch (GlusterCommandException err)
    {
        ctx.sendErrorJsonResponse(err.msg, HttpStatus.INTERNAL_SERVER_ERROR);
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
    try
    {
        _cli.deletePeer(peerAddress);
        ctx.response.setStatus(HttpStatus.NO_CONTENT);
    }
    catch (GlusterCommandException err)
    {
        ctx.sendErrorJsonResponse(err.msg, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
