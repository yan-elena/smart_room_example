!start.

/* Plans */

+!start
    <-  println("Light thing consumer agent started").

+light_level(L)
    <-  println("new light level perceived: ", L);
        .send(smart_room, achieve, update_light_level(L)).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
