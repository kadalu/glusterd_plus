module glusterd_plus.handlers.metrics;

import vibe.http.server;
import prometheus.gauge;
import prometheus.registry;

import glusterd_plus.handlers.helpers;

// List of Metrics
Gauge peerCount;
Gauge peerState;

void metricsInitialize()
{
    peerCount = new Gauge("peer_count", "Shows the number of peers", null);
    peerState = new Gauge("peer_state", "State of Peer", ["address"]);

    peerCount.register;
    peerState.register;
}

void gaugeReset(Gauge[] gauges)
{
    foreach (gauge; gauges)
    {
        Registry.global.unregister(gauge);
        gauge.register;
    }
}

void metricsOfPeers()
{
    gaugeReset([peerCount, peerState]);

    // TODO: Handle error and log failures
    auto peers = _cli.listPeers;

    peerCount.set(peers.length);

    foreach (peer; peers)
    {
        auto state = peer.state == "Connected" ? 1 : 0;
        peerState.set(state, [peer.address]);
    }
}

void metricsHandler(HTTPServerRequest req, HTTPServerResponse res)
{
    metricsOfPeers;

    ubyte[] data = new ubyte[0];

    import prometheus.metric;

    foreach (m; Registry.global.metrics)
    {
        data ~= m.collect().encode(EncodingFormat.text);
        data ~= "\n";
    }

    res.writeBody(data, "text/plain");
}
