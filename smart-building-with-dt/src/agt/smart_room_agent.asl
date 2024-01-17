threshold(0.2).

room_state("").
lamp_state("off").
light_level(0.0).
pres_detect(false).
lamp_thing_state("").
light_thing_state("").
pres_detect_thing_state("").

is_light_greater :- threshold(T) & light_level(L) & L > T.

+!start[scheme(Sch)]
    <-  .my_name(Name);
        ?room_state(S);
        ?lamp_state(L);
        ?pres_detect(P);
        registerRoom(Name, S, L, P);
        +roomRegistered;
        println("Smart room agent started").

+lampAction(ID, ACT) : .my_name(Name) & .concat(Name,"", ID)
    <-  ?play(LAMP, lamp, _);
        if (ACT == "on") {
            .send(LAMP, achieve, lamp_on);
        }
        if (ACT == "off") {
            .send(LAMP, achieve, lamp_off);
        }.

+!update_room_state(S2)
    <-  ?room_state(S1);
        .my_name(Name);
        if (S2 \== S1) {
            if (roomRegistered) {
                .my_name(Name);
                setRoomState(Name, S2);
                -+room_state(S2);
            } else {
                .wait(1000);
                !update_room_state(S2);
            }
        }.


+!update_lamp_state(S)
    <-  println("Update lamp state: ", S);
        -+lamp_state(S);
        if (roomRegistered) {
            .my_name(Name);
            setLampState(Name, S);
        }.

+!update_light_level(L)
    <-  println("Update light state: ", L);
        -+light_level(L);
        !check.

+!update_presence_detected(P)
    <-  println("Update presence detected: ", P);
        -+pres_detect(P);
        if (roomRegistered) {
            .my_name(Name);
            setPresDetState(Name, P);
        }
        !check.

+!check: lamp_state("off") & pres_detect(true) & not is_light_greater
    <-  ?play(LAMP, lamp, _);
        -+turn_lamp("on");
        .send(LAMP, achieve, lamp_on).

+!check: lamp_state("on") & pres_detect(false)
    <-  ?play(LAMP, lamp, _);
        -+turn_lamp("off");
        .send(LAMP, achieve, lamp_off).

+!check.

// check that all devices in the room are working

+!lamp_thing_state(S)
    <-  -+lamp_thing_state(S);
        !update_state(S).
        
+!light_thing_state(S)
    <-  -+light_thing_state(S);
        !update_state(S).

+!pres_detect_thing_state(S)
    <-  -+pres_detect_thing_state(S);
        !update_state(S).

+!update_state(S)
    <-  if (S == "ok") {
            !check_room_state;
        } else {
            !update_room_state(S);
        }.

+!check_room_state : lamp_thing_state(S) & pres_detect_thing_state(S) & light_thing_state(S) & S == "ok"
    <-  !update_room_state("Everything is ok").

+!check_room_state.

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }
{ include("$jacamoJar/templates/org-obedient.asl") }