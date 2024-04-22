module glusterd_plus.glustercli;

import glusterd_plus.glustercli.helpers;
import glusterd_plus.glustercli.peers;
import glusterd_plus.glustercli.volumes;

struct GlusterCLISettings
{
    string glusterCommand = "/usr/sbin/gluster";
    string localhostAddress;
}

class GlusterCLI
{
    GlusterCLISettings settings;

    this(GlusterCLISettings opts)
    {
        this.settings = opts;
    }

    mixin commandHelpers;
    mixin peersFunctions;
    mixin volumesFunctions;
}
