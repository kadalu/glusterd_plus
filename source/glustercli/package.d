module glusterd_plus.glustercli;

import glusterd_plus.glustercli.peers;
import glusterd_plus.glustercli.volumes;

struct GlusterCLISettings
{
    string commandPath;
    
}

class GlusterCLI
{
    GlusterCLISettings settings;

    this(GlusterCLISettings opts)
    {
        this.settings = opts;
    }

    mixin peersFunctions;
    mixin volumesFunctions;
}
