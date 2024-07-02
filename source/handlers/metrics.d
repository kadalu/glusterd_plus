module handlers.metrics;

import std.conv;

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

const NAMESPACE = "glusterfs_";

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
        gauge = new Gauge(NAMESPACE ~ name, help, labels);
    }

    void addSample(double value, string[] labelValues = [])
    {
        timestamp = posixTime;
        gauge.set(value, labelValues);
        samples ~= MetricSample(value, this.labels, labelValues);
    }
}

__gshared Metric[string] _metrics;


void registerMetric(string name, string description, string[] labels)
{
    _metrics[name] = new Metric(name, description, labels);
}

void metricsInitialize()
{
    registerMetric("peer_count", "Shows the number of peers", []);
    registerMetric("peer_state", "State of Peer", ["address"]);

    registerMetric("volume_count", "Number of Volumes", []);

    auto volumeLabelNames = ["type", "state", "name"];
    registerMetric("volume_distribute_count", "Distribute Count", volumeLabelNames);
    registerMetric("volume_snapshot_count", "Number of Snapshots", volumeLabelNames);
    registerMetric("volume_replica_count", "Replica Count", volumeLabelNames);
    registerMetric("volume_arbiter_count", "Arbiter Count", volumeLabelNames);
    registerMetric("volume_disperse_count", "Disperse Count", volumeLabelNames);
    registerMetric("volume_brick_count", "Number of Bricks", volumeLabelNames);
    registerMetric("volume_health", "Volume Health", volumeLabelNames);
    registerMetric("volume_up_distribute_groups", "Number of Up distribute Groups", volumeLabelNames);
    registerMetric("volume_capacity_used_bytes", "Volume Capacity Used Bytes", volumeLabelNames);
    registerMetric("volume_capacity_free_bytes", "Volume Capacity Free Bytes", volumeLabelNames);
    registerMetric("volume_capacity_bytes", "Volume Capacity Total Bytes", volumeLabelNames);
    registerMetric("volume_inodes_used_count", "Volume Inodes Used Count", volumeLabelNames);
    registerMetric("volume_inodes_free_count", "Volume Inodes Free Count", volumeLabelNames);
    registerMetric("volume_inodes_count", "Volume Inodes Total Count", volumeLabelNames);

    auto groupLabelNames = ["volume_type", "volume_state", "volume_name", "group_index"];
    registerMetric("distribute_group_brick_count", "Number of Bricks", groupLabelNames);
    registerMetric("distribute_group_health", "Distribute Group Health", groupLabelNames);
    registerMetric("distribute_group_up_bricks", "Number of Up Bricks", groupLabelNames);
    registerMetric("distribute_group_capacity_used_bytes", "Distribute Group Capacity Used Bytes", groupLabelNames);
    registerMetric("distribute_group_capacity_free_bytes", "Distribute Group Capacity Free Bytes", groupLabelNames);
    registerMetric("distribute_group_capacity_bytes", "Distribute Group Capacity Total Bytes", groupLabelNames);
    registerMetric("distribute_group_inodes_used_count", "Distribute Group Inodes Used Count", groupLabelNames);
    registerMetric("distribute_group_inodes_free_count", "Distribute Group Inodes Free Count", groupLabelNames);
    registerMetric("distribute_group_inodes_count", "Distribute Group Inodes Total Count", groupLabelNames);

    auto brickLabels = ["volume_type", "volume_state", "volume_name", "group_index", "peer_address", "path"];
    registerMetric("brick_health", "Brick Health", brickLabels);
    registerMetric("brick_capacity_used_bytes", "Brick Capacity Used Bytes", brickLabels);
    registerMetric("brick_capacity_free_bytes", "Brick Capacity Free Bytes", brickLabels);
    registerMetric("brick_capacity_bytes", "Brick Capacity Total Bytes", brickLabels);
    registerMetric("brick_inodes_used_count", "Brick Inodes Used Count", brickLabels);
    registerMetric("brick_inodes_free_count", "Brick Inodes Free Count", brickLabels);
    registerMetric("brick_inodes_count", "Brick Inodes Total Count", brickLabels);

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
    resetMetrics;
    metricsOfPeers;
    metricsOfVolumes;
}

void metricsOfPeers()
{
    // TODO: Handle error and log failures
    auto peers = _cli.listPeers;

    _metrics["peer_count"].addSample(peers.length);

    foreach (peer; peers)
    {
        auto state = peer.state == "Connected" ? 1 : 0;
        _metrics["peer_state"].addSample(state, [peer.address]);
    }
}

enum HealthValue
{
    Unknown,
    Down,
    Degraded,
    Partial,
    Up
}


void metricsOfVolumes()
{
    // TODO: Handle error and log failures
    auto volumes = _cli.listVolumes(true);

    _metrics["volume_count"].addSample(volumes.length);

    foreach (volume; volumes)
    {
        auto volumeLabels = [volume.type, volume.state, volume.name];
        _metrics["volume_distribute_count"].addSample(volume.distributeGroups.length, volumeLabels);
        //_metrics["volume_snapshot_count"].addSample(volume.snapshotCount, volumeLabels);
        _metrics["volume_replica_count"].addSample(volume.replicaCount, volumeLabels);
        _metrics["volume_arbiter_count"].addSample(volume.arbiterCount, volumeLabels);
        _metrics["volume_disperse_count"].addSample(volume.disperseCount, volumeLabels);

        if (volume.state == "Started")
        {
            _metrics["volume_health"].addSample(volume.health.to!HealthValue, volumeLabels);
            _metrics["volume_up_distribute_groups"].addSample(volume.upDistributeGroups, volumeLabels);
            _metrics["volume_capacity_used_bytes"].addSample(volume.sizeUsed, volumeLabels);
            _metrics["volume_capacity_free_bytes"].addSample(volume.sizeFree, volumeLabels);
            _metrics["volume_capacity_bytes"].addSample(volume.sizeTotal, volumeLabels);
            _metrics["volume_inodes_used_count"].addSample(volume.inodesUsed, volumeLabels);
            _metrics["volume_inodes_free_count"].addSample(volume.inodesFree, volumeLabels);
            _metrics["volume_inodes_count"].addSample(volume.inodesTotal, volumeLabels);
        }
        
        int brickCount;
        foreach(gidx, group; volume.distributeGroups)
        {
            brickCount += group.bricks.length;
            auto groupLabels = [volume.type, volume.state, volume.name, gidx.to!string];
            _metrics["distribute_group_brick_count"].addSample(group.bricks.length, groupLabels);
            if (volume.state == "Started")
            {
                _metrics["distribute_group_health"].addSample(group.health.to!HealthValue, groupLabels);
                _metrics["distribute_group_up_bricks"].addSample(group.upBricks, groupLabels);
                _metrics["distribute_group_capacity_used_bytes"].addSample(group.sizeUsed, groupLabels);
                _metrics["distribute_group_capacity_free_bytes"].addSample(group.sizeFree, groupLabels);
                _metrics["distribute_group_capacity_bytes"].addSample(group.sizeTotal, groupLabels);
                _metrics["distribute_group_inodes_used_count"].addSample(group.inodesUsed, groupLabels);
                _metrics["distribute_group_inodes_free_count"].addSample(group.inodesFree, groupLabels);
                _metrics["distribute_group_inodes_count"].addSample(group.inodesTotal, groupLabels);
            }
            foreach(brick; group.bricks)
            {
                auto brickLabels = [volume.type, volume.state, volume.name, gidx.to!string, brick.peer.address, brick.path];
                if (volume.state == "Started")
                {
                    _metrics["brick_health"].addSample(brick.state.to!HealthValue, brickLabels);
                    _metrics["brick_capacity_used_bytes"].addSample(brick.sizeUsed, brickLabels);
                    _metrics["brick_capacity_free_bytes"].addSample(brick.sizeFree, brickLabels);
                    _metrics["brick_capacity_bytes"].addSample(brick.sizeTotal, brickLabels);
                    _metrics["brick_inodes_used_count"].addSample(brick.inodesUsed, brickLabels);
                    _metrics["brick_inodes_free_count"].addSample(brick.inodesFree, brickLabels);
                    _metrics["brick_inodes_count"].addSample(brick.inodesTotal, brickLabels);
                }
            }
                
        }

        _metrics["volume_brick_count"].addSample(brickCount, volumeLabels);
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
