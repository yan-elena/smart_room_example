
/* Plans */

+!start[scheme(Sch)] 
    <-  println("Lamp thing consumer agent started");
        ?formationStatus(ok)[artifact_id(GrArtId)]; // see plan below to ensure we wait until it is well formed.
        +started;
        println("The group is well formed, continue").

// plans to wait until the group is well formed
// makes this intention suspend until the group is believed to be well formed
+?formationStatus(ok)[artifact_id(G)]
   <-   .wait({+formationStatus(ok)[artifact_id(G)]}).

+!sensingState[scheme(Sch)]
    <-  println("Lamp thing - sensing state");
        getCurrentState(S);
        ?formationStatus(ok)[artifact_id(GrArtId)];
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, update_lamp_state(S)).

+!connectArtifact[scheme(Sch)]
    <-  ?artifact_config(ID, H, P);
        makeArtifact(ID, "acme.LampThingProxyArtifact", [H, P], ArtID);
        focus(ArtID);
        println("Lamp thing proxy artifact created, id:", ArtID);
        +artifact_id(ArtID);
        ?formationStatus(ok)[artifact_id(GrArtId)];
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, lamp_thing_state("ok")).

-!connectArtifact[scheme(Sch)]
    <-  !sendFailedStatus(ID, H, P).

+!sendFailedStatus(ID, H, P) : started
    <-  S = "Cannot connect with the lamp device";
        println(S, " on ", H, ":", P);
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, lamp_thing_state(S)).

+!sendFailedStatus(ID, H, P)
    <-  .wait(1000);
        !sendFailedStatus(ID, H, P).

+state(S) : started
    <-  println("new perceived lamp state: ", S);
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, update_lamp_state(S)).

+state(S)
    <-  println("new perceived lamp state: ", S).

+!lamp_on
    <-  ?artifact_id(Id);
        on [artifact_id(Id)].
    
+!lamp_off
    <-  ?artifact_id(Id);
        off [artifact_id(Id)].

// in case of some failure
-!lamp_on 
    <-  F = "Execution of lamp on failed";
        println(F);
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, lamp_thing_state(F)).

-!lamp_off
    <-  F = "Execution of lamp off failed";
        println(F);
        ?play(SMART_ROOM, smart_room_controller, _);
        .send(SMART_ROOM, achieve, lamp_thing_state(F)).
        
{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$moiseJar/asl/org-obedient.asl") }
