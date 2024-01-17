!start.

/* Plans */

+!start
    <- println("Presence detected thing consumer started").

+presence_detected(P)
    <-  println("new presence detected perceived: ", P);
        .send(smart_room, achieve, update_presence_detected(P)).


{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
