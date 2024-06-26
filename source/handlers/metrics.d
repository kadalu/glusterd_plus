module handlers.metrics;

import handy_httpd;
import vibe.data.json : ignore;
import prometheus.gauge;
import prometheus.registry;

import handlers.helpers;

struct MetricSample
{
    string[string] labels;
    double value;

    this(double value, string[] labels, string[] labelValues)
    {
        this.value = value;

        import std.range;

        foreach (l; zip(labels, labelValues))
            this.labels[l[0]] = l[1];
    }
}

// From the Prometheus project
static long posixTime()
{
    import core.time : convert;
    import std.datetime : Clock, DateTime, SysTime, UTC;

    enum posixEpochAsStd = SysTime(DateTime(1970, 1, 1, 0, 0, 0), UTC()).stdTime;

    return (Clock.currTime.toUTC.stdTime - posixEpochAsStd).convert!("hnsecs", "msecs");
}

class Metric
{
    @ignore string name;
    string help;
    long timestamp;
    @ignore string[] labels;
    MetricSample[] samples;
    @ignore Gauge gauge;

    this(string name, string help, string[] labels)
    {
        this.name = name;
        this.help = help;
        this.labels = labels;
        gauge = new Gauge(name, help, labels);
    }

    void addSample(double value, string[] labelValues = [])
    {
        timestamp = posixTime;
        gauge.set(value, labelValues);
        samples ~= MetricSample(value, this.labels, labelValues);
    }
}

__gshared Metric[string] _metrics;

void metricsInitialize()
{
    _metrics["peer_count"] = new Metric("peer_count", "Shows the number of peers", [
    ]);
    _metrics["peer_state"] = new Metric("peer_state", "State of Peer", [
        "address"
    ]);

    foreach (_name, metric; _metrics)
        metric.gauge.register;
}

void resetMetrics()
{
    foreach (_name, metric; _metrics)
    {
        Registry.global.unregister(metric.gauge);
        metric.gauge.register;
        metric.samples = [];
    }
}

void collectMetrics()
{
    metricsOfPeers;
}

void metricsOfPeers()
{
    resetMetrics;

    // TODO: Handle error and log failures
    auto peers = _cli.listPeers;

    _metrics["peer_count"].addSample(peers.length);

    foreach (peer; peers)
    {
        auto state = peer.state == "Connected" ? 1 : 0;
        _metrics["peer_state"].addSample(state, [peer.address]);
    }
}

void metricsJsonHandler(ref HttpRequestContext ctx)
{
    collectMetrics;

    ctx.response.writeJsonBody(_metrics);
}

void metricsPrometheusHandler(ref HttpRequestContext ctx)
{
    collectMetrics;

    ubyte[] data = new ubyte[0];
    import prometheus.metric;

    foreach (m; Registry.global.metrics)
    {
        data ~= m.collect().encode(EncodingFormat.text);
        data ~= "\n";
    }

    ctx.response.writeBodyBytes(data, "text/plain");
}
