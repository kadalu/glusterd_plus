module handlers.helpers;

import std.stdio;
import std.array : appender;
import std.string;
import std.conv;

import handy_httpd;
import diet.html;
import vibe.data.json;
import slf4d;

import glustercli;

__gshared GlusterCLI _cli;

void glusterCliSetup(GlusterCLISettings settings)
{
    import std.stdio;
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

bool boolQueryParam(HttpRequest req, string key, bool defaultValue = false)
{
    if (req.queryParams.contains(key))
    {
        auto flag = req.queryParams[key];
        return flag == "true" ? true : false;
    }

    return defaultValue;
}

class AppExceptionHandler : BasicServerExceptionHandler
{
    override void handle(ref HttpRequestContext ctx, Exception e)
    {
        if (ctx.response.isFlushed)
        {
            error("Response is already flushed; cannot handle exception.", e);
            return;
        }
        if (auto statusExc = cast(HttpStatusException) e)
        {
            handleHttpStatusException(ctx, statusExc);
        }
        else if (auto cliExc = cast(GlusterCommandException) e)
        {
            handleCliException(ctx, cliExc);
        }
        else
        {
            handleOtherException(ctx, e);
        }
    }

    protected void handleCliException(ref HttpRequestContext ctx, GlusterCommandException e)
    {
        debugF!"Handling GlusterCommandException: %s"(e.message);
        string message = e.message !is null ? "Failed to run the command" : e.message.to!string; 
        ctx.sendErrorJsonResponse(message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
