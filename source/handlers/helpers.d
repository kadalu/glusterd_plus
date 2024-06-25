module handlers.helpers;

import std.stdio;
import std.array : appender;
import std.string;
import std.typecons;
import std.conv;

import serverino;
import diet.html;
import vibe.data.json;

import glustercli;

GlusterCLI _cli;

void glusterCliSetup(GlusterCLISettings settings)
{
    _cli = new GlusterCLI(settings);
}

void sendErrorJsonResponse(Output res, string error, ushort code = 400)
{
    res.status = code;
    res.writeJsonBody(["error": error]);
}

Nullable!(string[string]) matchedPathParams(string pattern, string path)
{
    string[string] params;

    // If the pattern and path are matching then
    // no need check part by part.
    if (pattern == path)
        return params.nullable;

    // Split the pattern and path into parts
    auto patternParts = pattern.strip("/").split("/");
    auto pathParts = path.strip("/").split("/");

    // Pattern group should match the given path parts
    if (patternParts.length != pathParts.length)
        return Nullable!(string[string]).init;

    // For each pattern parts, if it starts with `:`
    // then collect it as path param else path part should
    // match the respective part of the pattern.
    foreach(idx, p; patternParts)
    {
        if (p[0] == ':')
            params[p[1..$]] = pathParts[idx];
        else if(p != pathParts[idx])
            return Nullable!(string[string]).init;
    }

    return params.nullable;
}

void writeJsonBody(T)(Output res, T data)
{
    res.addHeader("Content-Type", "application/json");
    res.write(serializeToJsonString(data));
}

bool pathMatch(const(Request) req, string method, string pattern)
{
    return (
        req.method == method.capitalize.to!(Request.Method) &&
        !matchedPathParams(pattern, req.path).isNull
    );
}

string[string] pathParams(Request req, string pattern)
{
    string[string] params;
    auto data = matchedPathParams(pattern, req.path);
    if (!data.isNull)
        params = data.get;

    return params;
}

void renderDiet(Args...)(ref Output res)
{
    auto text = appender!string;
    text.compileHTMLDietFile!(Args);
    res.addHeader("Content-Type", "text/html");
    res.write(text.data);
}
