module glusterd_plus.glustercli.helpers;

class GlusterCommandException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}

mixin template commandHelpers()
{

    import vibe.core.concurrency;

    private string[] executeGlusterCmd(string[] inputCmd, bool xml)
    {

        import std.string;
        import std.process;

        auto cmd = [this.settings.glusterCommand, "--mode=script"];
        if (xml)
            cmd ~= ["--xml"];

        cmd ~= inputCmd;

        string[] outlines;
        auto pipes = pipeProcess(cmd, Redirect.stdout | Redirect.stderr);
        auto returnCode = wait(pipes.pid);
        foreach (line; pipes.stdout.byLine)
            outlines ~= line.idup;
        if (returnCode != 0)
        {
            string[] errlines;
            foreach (line; pipes.stderr.byLine)
                errlines ~= line.idup;
            throw new GlusterCommandException(cmd.join(" ") ~ ": " ~ errlines.join("\n"));
        }

        return outlines;
    }

    private string[] executeGlusterCmd(string[] inputCmd)
    {
        return async(&executeGlusterCmd, inputCmd, false).getResult;
    }

    private string[] executeGlusterCmdXml(string[] inputCmd)
    {
        return async(&executeGlusterCmd, inputCmd, true).getResult;
    }
}
