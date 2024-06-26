module handlers.helpers;

import std.stdio;
import std.array : appender;
import std.string;
import std.conv;

import handy_httpd;
import diet.html;
import vibe.data.json;

import glustercli;

__gshared GlusterCLI _cli;

void glusterCliSetup(GlusterCLISettings settings)
{
    import std.stdio;
    writeln("initialized");
    _cli = new GlusterCLI(settings);
}

void writeJsonBody(T)(HttpResponse res, T data)
{
    res.writeBodyString(serializeToJsonString(data), "application/json");
}

void render(Args...)(ref HttpResponse res)
{
    auto text = appender!string;
    text.compileHTMLDietFile!(Args);
    res.writeBodyString(text.data, "text/html");
}

void enforceHttp(bool cond, HttpStatus status, string message)
{
    if (!cond)
        throw new HttpStatusException(status, message);
}

void enforceHttpJson(bool cond, HttpStatus status, string message)
{
    enforceHttp(cond, status, serializeToJsonString(["error": message]));
}

string contentType(HttpRequest req)
{
    if (req.headers.contains("Content-Type"))
        return req.headers["Content-Type"];

    return "";
}

bool isJsonContentType(HttpRequest req)
{
    return req.contentType.startsWith("application/json");
}

void sendErrorJsonResponse(ref HttpRequestContext ctx, string error, HttpStatus status = HttpStatus.BAD_REQUEST)
{
    ctx.response.setStatus(status);
    ctx.response.writeJsonBody(["error": error]);
}
