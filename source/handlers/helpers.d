module glusterd_plus.handlers.helpers;

import glusterd_plus.glustercli;

GlusterCLI _cli;

void glusterCliSetup(GlusterCLISettings settings)
{
    _cli = new GlusterCLI(settings);
}
