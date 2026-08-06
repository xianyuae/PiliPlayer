import QtQuick 1.1
import "../../js/util.js" as Util

Item {
	id: root;
	objectName: "idLocalToolIcon";
	property string iconId: "";
	property bool enabled: true;
	property bool inverted: true;
	signal clicked;

	width: constants._iSizeLarge;
	// Fixed defaults avoid a binding loop when callers set width: height.
	height: constants._iSizeLarge;

	Image {
		id: icon;
		anchors.centerIn: parent;
		width: Math.min(parent.width, parent.height, constants._iSizeLarge) * 0.6;
		height: width;
		source: root.iconId !== "" ? Qt.resolvedUrl("../images/icons/" + Util.HandleIconFile(root.iconId, root.inverted)) : "";
		opacity: root.enabled ? 1 : 0.4;
		smooth: true;
	}

	MouseArea {
		anchors.fill: parent;
		enabled: root.enabled;
		onClicked: root.clicked();
	}
}
