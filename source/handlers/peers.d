module glusterd_plus.handlers.peers;

import std.json;

import vibe.http.server;

import glusterd_plus.handlers.helpers;
import glusterd_plus.glustercli.helpers;

void addPeer(HTTPServerRequest req, HTTPServerResponse res)
{
    if (req.contentType != "application/json")
    {
        sendErrorJsonResponse(res, "Invalid Content-type header. Use \"application/json\"");
        return;
    }

    string peerAddress;

    // Validation
    try
    {
        peerAddress = req.json["address"].to!string;
    }
    catch (JSONException)
    {
        sendErrorJsonResponse(res, "Invalid JSON data");
        return;
    }

    try
    {
        _cli.addPeer(peerAddress);
        res.statusCode = 201;

        // TODO: Think about getting one peer info
        // instead of fetching peers list
        auto peers = _cli.listPeers();

        foreach (peer; peers)
        {
            if (peer.address == peerAddress)
                res.writeJsonBody(peer);
        }
    }
    catch (GlusterCommandException err)
    {
        sendErrorJsonResponse(res, err.msg, 500);
    }
}

void listPeers(HTTPServerRequest req, HTTPServerResponse res)
{
    auto peers = _cli.listPeers;
    res.writeJsonBody(peers);
}

void deletePeer(HTTPServerRequest req, HTTPServerResponse res)
{
    auto peerAddress = req.params.get("address");
    try
    {
        _cli.deletePeer(peerAddress);
        res.statusCode = 204;
        res.writeJsonBody(null);
    }
    catch (GlusterCommandException err)
    {
        sendErrorJsonResponse(res, err.msg, 500);
    }
}
