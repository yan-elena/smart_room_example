
/* Plans */

+!start
    <-  println("Light thing consumer agent started");
        ?formationStatus(ok)[artifact_id(GrArtId)]; // see plan below to ensure we wait until it is well formed.
        +started;
        println("The group is well formed, continue").

// plans to wait until the group is well formed
// makes this intention suspend until the group is believed to be well formed
+?formationStatus(ok)[artifact_id(G)]
   <- .wait({+formationStatus(ok)[artifact_id(G)]}).

+!sensingState[scheme(Sch)]
    <-  println("Light thing - sensing state");
        getCurrentLightLevel(L);
        ?formationStatus(ok)[artifact_id(GrArtId)];
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, update_light_level(L)).

+!connectArtifact[scheme(Sch)]
    <-  ?artifact_config(ID, H, P);
        makeArtifact(ID, "acme.LightSensorThingProxyArtifact", [H, P], ArtID);
        focus(ArtID);
        println("Light thing proxy artifact created, id:", ArtID);
        ?formationStatus(ok)[artifact_id(GrArtId)];
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, light_thing_state("ok")).

-!connectArtifact[scheme(Sch)]
    <-  !sendFailedStatus(ID, H, P).

+!sendFailedStatus(ID, H, P) : started
    <-  S = "Cannot connect with the light device";
        println(S, " on ", H, ":", P);
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, light_thing_state(S)).

+!sendFailedStatus(ID, H, P)
    <-  .wait(1000);
        !sendFailedStatus(ID, H, P).

+light_level(L) : started
    <-  println("new light level perceived: ", L);
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, update_light_level(L)).

+light_level(L)
    <- println("new light level perceived: ", L).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$moiseJar/asl/org-obedient.asl") }
