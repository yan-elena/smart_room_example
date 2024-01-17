threshold(0.2).

lamp_state("off").
light_level(0.0).
pres_detect(false).

is_light_greater :- threshold(T) & light_level(L) & L > T.

!start.

+!start
    <-  println("Smart room agent started").

+!update_lamp_state(S)
    <-  println("Update lamp state: ", S);
        -+lamp_state(S);
        !check.

+!update_light_level(L)
    <-  println("Update light state: ", L);
        -+light_level(L);
        !check.

+!update_presence_detected(P)
    <-  println("Update presence detected: ", P);
        -+pres_detect(P);
        !check.

+!check: lamp_state("off") & pres_detect(true) & not is_light_greater
    <-  println("TURN ON LAMP");
        .send(lamp_thing, achieve, lamp_on).

+!check: lamp_state("on") & pres_detect(false)
    <-  println("TURN OFF LAMP");
        .send(lamp_thing, achieve, lamp_off).

+!check.

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
