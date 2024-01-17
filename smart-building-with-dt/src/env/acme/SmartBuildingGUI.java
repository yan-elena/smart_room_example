package acme;

import cartago.*;

import javax.swing.*;
import javax.swing.border.EtchedBorder;
import javax.swing.border.TitledBorder;
import java.awt.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SmartBuildingGUI extends Artifact {

    private SmartBuildingFrame frame;

    public void init(String id) {
        try {
			frame = new SmartBuildingFrame(this, id);
			SwingUtilities.invokeAndWait(() -> frame.setVisible(true));
		} catch (Exception ex){
			ex.printStackTrace();
		}
    }

    void lampAction(String roomId, boolean state) {
        log("Execute action lamp: " + state + " for room " + roomId);
        this.beginExtSession();
        getObsProperty("lampAction").updateValues(roomId, state ? "on" : "off");
        this.endExtSession();
    }

    @OPERATION void setRoomState(String roomId, String roomState) {
        this.frame.setRoomState(roomId, roomState);
    }

    @OPERATION void setLampState(String roomId, String lampState) {
        this.frame.setLampState(roomId, lampState);
    }

    @OPERATION void setPresDetState(String roomId, boolean presenceDetected) {
        this.frame.setPresDetState(roomId, presenceDetected);
    }

    @OPERATION void registerRoom(String roomId, String roomState, String lampState, boolean presDetect) {
        log("Register room: " + roomId);
        defineObsProperty("lampAction", roomId, "");
        try {
            SwingUtilities.invokeAndWait(() -> {
                frame.registerRoom(roomId);
                frame.setRoomState(roomId, roomState);
                frame.setLampState(roomId, lampState);
                frame.setPresDetState(roomId, presDetect);
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /* called by the EDT */
	
	void notifyEvent(String what) {
		this.beginExtSession();
		signal(what);
		this.endExtSession();
	}

    static class SmartBuildingFrame extends JFrame {

        private final Map<String, List<Label>> roomsLabel;
        private final SmartBuildingGUI simulator;

        public SmartBuildingFrame(SmartBuildingGUI simulator, String id) {
            this.roomsLabel = new HashMap<>();
            this.simulator = simulator;
            this.setTitle(id);
            this.setLayout(new GridLayout());
            this.setSize(500, 300);
        }

        public void registerRoom(String roomId) {
            JPanel roomPane = new JPanel();
            roomPane.setLayout(new BoxLayout(roomPane, BoxLayout.PAGE_AXIS));
            roomPane.setBorder(new TitledBorder(new EtchedBorder(), roomId));
            Label roomStatusLabel = new Label("Room status: ");
            Label lampStatusLabel = new Label("Lamp status: ");
            Label presDetectLabel = new Label("Someone is in the room: ");
            roomsLabel.put(roomId, List.of(roomStatusLabel, lampStatusLabel, presDetectLabel));

            JPanel actionsPane = new JPanel();
            JButton onBtn = new JButton("Light on");
            JButton offBtn = new JButton("Light off");

            onBtn.addActionListener(l -> simulator.lampAction(roomId, true));
            offBtn.addActionListener(l -> simulator.lampAction(roomId, false));

            actionsPane.add(onBtn);
            actionsPane.add(offBtn);
            roomPane.add(roomStatusLabel);
            roomPane.add(lampStatusLabel);
            roomPane.add(presDetectLabel);
            roomPane.add(actionsPane);

            this.add(roomPane);
            validate();
            repaint();
        }

        public void setRoomState(String roomId, String state) {
            this.roomsLabel.get(roomId).get(0).setText("Room status: " + state);
        }

        public void setLampState(String roomId, String state) {
            this.roomsLabel.get(roomId).get(1).setText("Lamp status: " + state);
        }

        public void setPresDetState(String roomId, boolean presenceDetected) {
            this.roomsLabel.get(roomId).get(2).setText("Someone is in the room: " + (presenceDetected ? "yes" : "no"));
        }
    }
}