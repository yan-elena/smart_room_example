// !start.

/* Plans */

+!start
    <-  println("Presence detected thing consumer started");
        ?formationStatus(ok)[artifact_id(GrArtId)]; // see plan below to ensure we wait until it is well formed.
        +started;
        println("The group is well formed, continue").

// plans to wait until the group is well formed
// makes this intention suspend until the group is believed to be well formed
+?formationStatus(ok)[artifact_id(G)]
   <- .wait({+formationStatus(ok)[artifact_id(G)]}).

+!sensingState[scheme(Sch)]
    <-  println("Pres detect thing - sensing state");
        getCurrentPresenceDetected(P);
        ?formationStatus(ok)[artifact_id(GrArtId)];
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, update_presence_detected(P)).

+!connectArtifact[scheme(Sch)]
    <-  ?artifact_config(ID, H, P);
        makeArtifact(ID, "acme.PresDetectThingProxyArtifact", [H, P], ArtID);
        focus(ArtID);
        println("Pres detect thing proxy artifact created, id:", ArtID);
        ?formationStatus(ok)[artifact_id(GrArtId)];
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, pres_detect_thing_state("ok")).

-!connectArtifact[scheme(Sch)]
    <-  !sendFailedStatus(ID, H, P).

+!sendFailedStatus(ID, H, P) : started
    <-  S = "Cannot connect with the pres detect device";
        println(S, " on ", H, ":", P);
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, pres_detect_thing_state(S)).

+!sendFailedStatus(ID, H, P)
    <-  .wait(1000);
        !sendFailedStatus(ID, H, P).

+presence_detected(P) : started
    <-  println("new presence detected perceived: ", P);
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, update_presence_detected(P)).

+presence_detected(P) : started
    <-  println("new presence detected perceived: ", P).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$moiseJar/asl/org-obedient.asl") }
