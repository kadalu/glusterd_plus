module glusterd_plus.glustercli.volumes;

import std.array;
import std.conv;

import yxml;

import glusterd_plus.glustercli.peers;

struct Brick
{
    Peer peer;
    string path;
    bool arbiter = false;
    int port;
}

struct DistributeGroup
{
    string type;
    Brick[] bricks;
}

struct Volume
{
    string id;
    string name;
    string type;
    string state;
    int snapshots;
    DistributeGroup[] distributeGroups;
}

struct VolumeCreateOptions
{
    int replicaCount;
    int arbiterCount;
    int disperseCount;
    int disperseRedundancyCount;
    int disperseDataCount;
    string transport;
    bool force;
}

DistributeGroup[] fromBricks(Brick[] bricks, int distCount, int replicaCount)
{
    DistributeGroup[] distributeGroups;
    auto distGrpBricksCount = bricks.length / distCount;
    foreach (idx; 0 .. distCount)
    {
        DistributeGroup distGroup;

        foreach (bidx; 0 .. distGrpBricksCount)
        {
            distGroup.bricks ~= bricks[idx + bidx];
        }

        distributeGroups ~= distGroup;
    }

    return distributeGroups;
}

/*
Example output
---
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cliOutput>
  <opRet>0</opRet>
  <opErrno>0</opErrno>
  <opErrstr/>
  <volInfo>
    <volumes>
      <volume>
        <name>vol1</name>
        <id>79c4be45-1085-4b4b-8117-f8f35b478d28</id>
        <status>0</status>
        <statusStr>Created</statusStr>
        <snapshotCount>0</snapshotCount>
        <brickCount>3</brickCount>
        <distCount>1</distCount>
        <replicaCount>3</replicaCount>
        <arbiterCount>0</arbiterCount>
        <disperseCount>0</disperseCount>
        <redundancyCount>0</redundancyCount>
        <type>2</type>
        <typeStr>Replicate</typeStr>
        <transport>0</transport>
        <bricks>
          <brick uuid="1b58cfc0-15ed-40b8-be28-f7c341250777">rampa:/data/gfs/vol1/b1<name>rampa:/data/gfs/vol1/b1</name><hostUuid>1b58cfc0-15ed-40b8-be28-f7c341250777</hostUuid><isArbiter>0</isArbiter></brick>
          <brick uuid="1b58cfc0-15ed-40b8-be28-f7c341250777">rampa:/data/gfs/vol1/b2<name>rampa:/data/gfs/vol1/b2</name><hostUuid>1b58cfc0-15ed-40b8-be28-f7c341250777</hostUuid><isArbiter>0</isArbiter></brick>
          <brick uuid="1b58cfc0-15ed-40b8-be28-f7c341250777">rampa:/data/gfs/vol1/b3<name>rampa:/data/gfs/vol1/b3</name><hostUuid>1b58cfc0-15ed-40b8-be28-f7c341250777</hostUuid><isArbiter>0</isArbiter></brick>
        </bricks>
        <optCount>5</optCount>
        <options>
          <option>
            <name>cluster.granular-entry-heal</name>
            <value>on</value>
          </option>
          <option>
            <name>storage.fips-mode-rchecksum</name>
            <value>on</value>
          </option>
          <option>
            <name>transport.address-family</name>
            <value>inet</value>
          </option>
          <option>
            <name>nfs.disable</name>
            <value>on</value>
          </option>
          <option>
            <name>performance.client-io-threads</name>
            <value>off</value>
          </option>
        </options>
      </volume>
      <count>1</count>
    </volumes>
  </volInfo>
</cliOutput>
---
*/
Volume[] parseVolumeInfo(string[] lines)
{
    Volume[] volumes;
    XmlDocument doc;
    doc.parse(lines.join(""));

    XmlElement root = doc.root;

    XmlElement volInfo = root.firstChildByTagName("volInfo");
    XmlElement vols = volInfo.firstChildByTagName("volumes");

    foreach (XmlElement e; vols.getChildrenByTagName("volume"))
    {
        Volume volume;
        Brick[] bricks;

        volume.name = e.firstChildByTagName("name").textContent.dup;
        volume.id = e.firstChildByTagName("id").textContent.dup;
        volume.state = e.firstChildByTagName("statusStr").textContent.dup;
        volume.type = e.firstChildByTagName("typeStr").textContent.dup;
        volume.snapshots = e.firstChildByTagName("snapshotCount").textContent.to!int;
        auto replicaCount = e.firstChildByTagName("replicaCount").textContent.to!int;
        auto distCount = e.firstChildByTagName("distCount").textContent.to!int;

        auto bricksList = e.firstChildByTagName("bricks");

        foreach (XmlElement brickEle; bricksList.getChildrenByTagName("brick"))
        {
            Brick brick;

            auto parts = brickEle.firstChildByTagName("name").textContent.dup.split(":");
            brick.peer.address = parts[0].to!string;
            brick.path = parts[1].to!string;
            brick.peer.id = brickEle.firstChildByTagName("hostUuid").textContent.dup;
            auto arbiter = brickEle.firstChildByTagName("isArbiter").textContent.dup;
            if (arbiter == "1")
                brick.arbiter = true;

            bricks ~= brick;
        }

        volume.distributeGroups = fromBricks(bricks, distCount, replicaCount);

        volumes ~= volume;
    }

    return volumes;
}

Volume[] parseVolumeStatus(string[] lines)
{
    Volume[] volumes;
    return volumes;
}

mixin template volumesFunctions()
{
    void createVolume(string name, string[] bricks, VolumeCreateOptions opts)
    {
        import std.format;

        auto cmd = ["volume", "create", name];
        if (opts.replicaCount > 0)
            cmd ~= ["replica", format!"%d"(opts.replicaCount)];

        if (opts.arbiterCount > 0)
            cmd ~= ["arbiter", format!"%d"(opts.arbiterCount)];

        if (opts.disperseCount > 0)
            cmd ~= ["disperse", format!"%d"(opts.disperseCount)];

        if (opts.disperseDataCount > 0)
            cmd ~= ["disperse-data", format!"%d"(opts.disperseDataCount)];

        if (opts.disperseRedundancyCount > 0)
            cmd ~= ["redundancy", format!"%d"(opts.disperseRedundancyCount)];

        if (opts.transport != "tcp" && opts.transport != "")
            cmd ~= ["transport", opts.transport];

        cmd ~= bricks;

        if (opts.force)
            cmd ~= ["force"];

        executeGlusterCmd(cmd);
    }

    private void startStopVolume(string name, bool start = true, bool force = false)
    {
        string action = start ? "start" : "stop";
        auto cmd = ["volume", action, name];
        if (force)
            cmd ~= ["force"];

        executeGlusterCmd(cmd);
    }

    void startVolume(string name, bool force = false)
    {
        startStopVolume(name, true, force);
    }

    void stopVolume(string name, bool force = false)
    {
        startStopVolume(name, false, force);
    }

    Volume[] listVolumes(bool status = false)
    {
        auto cmd = ["volume", "info"];

        auto outlines = executeGlusterCmdXml(cmd);
        return parseVolumeInfo(outlines);
    }

    Volume getVolume(string name, bool status = false)
    {
        auto cmd = ["volume", "info", name];

        auto outlines = executeGlusterCmdXml(cmd);
        auto vols = parseVolumeInfo(outlines);
        return vols[0];
    }

    void deleteVolume(string name)
    {
        executeGlusterCmd(["volume", "delete", name]);
    }
}
