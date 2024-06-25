module handlers.peers;

import serverino;
import vibe.data.json;

import handlers.helpers;
import glustercli.helpers;

struct PeerRequest
{
    string address;
}

@endpoint @route!((r) => r.pathMatch("Post", "/api/v1/peers"))
void addPeer(Request req, Output res)
{
    if (req.body.contentType != "application/json")
    {
        sendErrorJsonResponse(res, "Invalid Content-type header. Use \"application/json\"");
        return;
    }

    string peerAddress;
    PeerRequest data;

    // Validation
    try
    {
        data = deserializeJson!PeerRequest(req.body.data);
    }
    catch (JSONException)
    {
        sendErrorJsonResponse(res, "Invalid JSON data");
        return;
    }

    try
    {
        _cli.addPeer(data.address);
        res.status = 201;

        // TODO: Think about getting one peer info
        // instead of fetching peers list
        auto peers = _cli.listPeers();

        foreach (peer; peers)
        {
            if (peer.address == data.address)
                res.writeJsonBody(peer);
        }
    }
    catch (GlusterCommandException err)
    {
        sendErrorJsonResponse(res, err.msg, 500);
    }
}

@endpoint @route!((r) => r.pathMatch("Get", "/api/v1/peers"))
void listPeers(Request req, Output res)
{
    auto peers = _cli.listPeers;
    res.writeJsonBody(peers);
}

@endpoint @route!((r) => r.pathMatch("Delete", "/api/v1/peers/:address"))
void deletePeer(Request req, Output res)
{
    auto params = req.pathParams("/api/v1/peers/:address");
    try
    {
        _cli.deletePeer(params["address"]);
        res.status = 204;
    }
    catch (GlusterCommandException err)
    {
        sendErrorJsonResponse(res, err.msg, 500);
    }
}
