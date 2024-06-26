module handlers.auth;

import handy_httpd;
import handy_httpd.handlers;

class AuthFilter : HttpRequestFilter
{
    void apply(ref HttpRequestContext ctx, FilterChain filterChain)
    {
        // TODO: Handle authentication, for now allow all requests
        filterChain.doFilter(ctx);
    }
}

