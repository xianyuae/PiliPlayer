import QtQuick 1.1
import "../../js/util.js" as Util

Item {
	id: root;
	objectName: "idPPSHChip";
	property alias sText: label.text;
	property string sIconId: "";
	property bool bSelected: false;
	property bool enabled: true;
	signal clicked;

	width: content.width + constants._iSpacingSuper * 2;
	height: constants._iSizeMedium;

	Rectangle {
		id: bg;
		anchors.fill: parent;
		radius: height / 2;
		color: root.bSelected ? constants._cThemeColor : (constants._bInverted ? "#2c2d34" : "#ffffff");
		border.width: root.bSelected ? 0 : 1;
		border.color: constants._cLightColor;
		smooth: true;
	}

	Row {
		id: content;
		anchors.centerIn: parent;
		spacing: constants._iSpacingSmall;
		Image {
			anchors.verticalCenter: parent.verticalCenter;
			width: constants._iSizeSmall;
			height: width;
			source: root.sIconId != "" ? Qt.resolvedUrl("../images/icons/" + Util.HandleIconFile(root.sIconId, constants._bInverted)) : "";
			visible: source != "";
		}
		Text {
			id: label;
			anchors.verticalCenter: parent.verticalCenter;
			font.pixelSize: constants._iFontLarge;
			font.bold: root.bSelected;
			color: root.bSelected ? "#ffffff" : constants._cTextPrimary;
			elide: Text.ElideRight;
		}
	}

	MouseArea {
		anchors.fill: parent;
		enabled: root.enabled;
		onClicked: root.clicked();
	}
}
