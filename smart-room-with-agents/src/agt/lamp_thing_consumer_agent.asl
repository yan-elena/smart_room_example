!start.

/* Plans */

+!start 
    <- println("Lamp thing consumer agent started").

+state(S)
    <-  println("new perceived lamp state: ", S);
        .send(smart_room, achieve, update_lamp_state(S)).
    
+!lamp_on
    <-  on.

+!lamp_off
    <-  off.

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
