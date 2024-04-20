import vibe.vibe;

import glusterd_plus.handlers.peers;
import glusterd_plus.handlers.volumes;

void setJsonHeader(HTTPServerRequest req, HTTPServerResponse res)
{
    res.contentType = "application/json; charset=utf-8";
}

void main()
{
	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
    auto router = new URLRouter;

    router.any("/api/v1/*", &setJsonHeader);

    // peer routes
    router.post("/api/v1/peers", &addPeer);
    router.get("/api/v1/peers", &listPeers);
    router.delete_("/api/v1/peers/:address", &deletePeer);

    // Volume routes
    router.post("/api/v1/volumes", &createVolume);
    router.get("/api/v1/volumes", &listVolumes);
    router.get("/api/v1/volumes/:name", &getVolume);
    router.delete_("/api/v1/volumes/:name", &deleteVolume);
    router.post("/api/v1/volumes/:name/start", &startVolume);
    router.post("/api/v1/volumes/:name/stop", &stopVolume);

	auto listener = listenHTTP(settings, router);
	scope (exit)
	{
		listener.stopListening();
	}

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
	runApplication();
}
