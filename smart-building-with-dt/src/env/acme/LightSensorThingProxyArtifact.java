package acme;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.ObsProperty;
import cartago.OpFeedbackParam;
import io.vertx.core.Vertx;
import io.vertx.core.json.JsonObject;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Optional;

public class LightSensorThingProxyArtifact extends Artifact {

    private String host;
    private int port;
    private HttpClient client;
    private String uri;

    private static final String THING_BASE_PATH = "/api";
    private static final String TD_FULL_PATH = THING_BASE_PATH;
    private static final String PROPERTIES_BASE_PATH = THING_BASE_PATH + "/properties";
    private static final String PROPERTY_STATE = "lightLevel";
    private static final String PROPERTY_STATE_FULL_PATH = PROPERTIES_BASE_PATH + "/" + PROPERTY_STATE;
    private static final String EVENTS_FULL_PATH = THING_BASE_PATH + "/events";

    public void init(String host, int port) throws Exception {
        this.host = host;
        this.port = port;
        this.uri = "http://"+ host + ":" + port;
        client = HttpClient.newHttpClient();
        bindToPhysicalThing();
        log("ready.");
    }


    private void bindToPhysicalThing() throws Exception {

        log("connecting to " + uri);

        /* read initial lightLevel */

        JsonObject temp = this.doGetBlocking(uri + PROPERTY_STATE_FULL_PATH);
        defineObsProperty("light_level", temp.getDouble("lightLevel"));

        /* subscribe */

        this.doSubscribe();

    }

    @OPERATION
    void getCurrentLightLevel(OpFeedbackParam<Double> lightLevel) {
        try {
            log("getting the light level.");
            JsonObject obj = this.doGetBlocking(uri + PROPERTY_STATE_FULL_PATH);
            lightLevel.set(obj.getDouble("lightLevel"));
        } catch (Exception ex) {
            failed("");
        }
    }

    // aux actions

    private JsonObject doGetBlocking(String uri) throws Exception {
        try {
            var request = HttpRequest.newBuilder()
                    .uri(URI.create(uri))
                    .build();

            var response = client.send(request,  HttpResponse.BodyHandlers.ofString());
            return new JsonObject(response.body());
        } catch (Exception ex) {
            ex.printStackTrace();
            throw ex;
        }
    }

    private JsonObject doPostBlocking(String uri, Optional<JsonObject> body) throws Exception {
        HttpRequest req = null;
        // log("doing a post at " + "http://" + uri);
        if (!body.isEmpty()) {
            req  = HttpRequest.newBuilder()
                    .uri(URI.create(uri))
                    .POST(HttpRequest.BodyPublishers.ofString(body.get().toString()))
                    .build();

        } else {
            req = HttpRequest.newBuilder()
                    .uri(URI.create(uri))
                    .POST(HttpRequest.BodyPublishers.noBody())
                    .build();
        }

        var response = client.send(req, HttpResponse.BodyHandlers.ofString());
        // log(" >> " + response.statusCode());
        return null; // new JsonObject(response.body());
    }

    private void doSubscribe() {
        Vertx vertx = Vertx.vertx();
        LightSensorThingProxyArtifact art = this;
        log("Subscribing...");
        vertx.createHttpClient().websocket(port, host, EVENTS_FULL_PATH, ws -> {
            /* handling ws msgs */
            log("Connected!");
            ws.handler(msg -> {
                try {
                    JsonObject ev = new JsonObject(msg.toString());
                    String msgType = ev.getString("event");
                    if (msgType.equals("lightLevelChanged")) {
                        JsonObject data = ev.getJsonObject("data");
                        Double newState = data.getDouble("lightLevel");

                        art.beginExtSession();

                        if (newState != null) {
                            ObsProperty sprop = getObsProperty("light_level");
                            sprop.updateValue(newState);
                        }
                        art.endExtSession();
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            });
        });
    }
}
