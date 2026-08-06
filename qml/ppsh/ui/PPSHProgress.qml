import QtQuick 1.1

Item {
	id: root;
	objectName: "idPPSHProgress";
	property real value: 0;
	property real minimumValue: 0;
	property real maximumValue: 100;
	property bool pressed: false;
	property bool enabled: true;
	signal seekClicked(real ratio);
	signal seekMove(real ratio);
	signal seekReleased(real ratio);

	height: constants._iSizeSmall;

	Rectangle {
		id: track;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.verticalCenter: parent.verticalCenter;
		height: Math.max(3, parent.height * 0.28);
		radius: height / 2;
		color: constants._bInverted ? "#4a4c54" : "#e3e5e9";
	}

	Rectangle {
		id: fill;
		anchors.left: parent.left;
		anchors.verticalCenter: parent.verticalCenter;
		width: root.maximumValue > root.minimumValue ? track.width * Math.max(0, Math.min(1, (root.value - root.minimumValue) / (root.maximumValue - root.minimumValue))) : 0;
		height: track.height;
		radius: height / 2;
		color: constants._cThemeColor;
	}

	Rectangle {
		id: knob;
		anchors.verticalCenter: parent.verticalCenter;
		x: Math.max(0, Math.min(parent.width - width, fill.width - width / 2));
		width: root.pressed ? constants._iSizeSmall : constants._iSizeTiny;
		height: width;
		radius: width / 2;
		color: constants._cThemeColor;
		border.width: 2;
		border.color: "#ffffff";
		smooth: true;
	}

	MouseArea {
		id: seekarea;
		anchors.fill: parent;
		enabled: root.enabled;
		onPressedChanged: root.pressed = pressed;
		onPositionChanged: {
			if(pressed) root.seekMove(Math.max(0, Math.min(1, mouse.x / width)));
		}
		onClicked: root.seekClicked(Math.max(0, Math.min(1, mouse.x / width)));
		onReleased: root.seekReleased(Math.max(0, Math.min(1, mouse.x / width)));
	}
}
