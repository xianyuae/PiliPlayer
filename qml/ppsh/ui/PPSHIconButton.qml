import QtQuick 1.1
import "../../js/util.js" as Util

Item {
	id: root;
	objectName: "idPPSHIconButton";
	property string iconId: "";
	property string iconSource: "";
	property url source: "";
	property bool enabled: true;
	property bool bHighlight: false;
	property int iSize: constants._iSizeLarge;
	signal clicked;

	width: root.iSize;
	height: width;

	Rectangle {
		id: bg;
		anchors.fill: parent;
		radius: width / 2;
		color: root.bHighlight ? constants._cThemeColor : (constants._bInverted ? "#33000000" : "#ccffffff");
		border.width: root.bHighlight ? 0 : 1;
		border.color: constants._cDividerColor;
		opacity: root.enabled ? 1 : 0.45;
	}

	Image {
		id: icon;
		anchors.centerIn: parent;
		width: Math.round(parent.width * 0.58);
		height: width;
		source: root.source != "" ? root.source : (root.iconSource != "" ? root.iconSource : Qt.resolvedUrl("../images/icons/" + Util.HandleIconFile(root.iconId, root.bHighlight || constants._bInverted)));
		smooth: true;
	}

	MouseArea {
		anchors.fill: parent;
		enabled: root.enabled;
		onClicked: root.clicked();
	}
}
