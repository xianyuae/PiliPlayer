import QtQuick 1.1

Item {
	id: root;
	objectName: "idPPSHEmptyState";
	property string sText: qsTr("No content");
	property string sSubText: "";
	signal refresh;

	Column {
		anchors.centerIn: parent;
		width: parent.width;
		spacing: constants._iSpacingMedium;
		Text {
			anchors.horizontalCenter: parent.horizontalCenter;
			width: parent.width - constants._iSpacingSuper * 2;
			horizontalAlignment: Text.AlignHCenter;
			verticalAlignment: Text.AlignVCenter;
			font.bold: true;
			font.pixelSize: constants._iFontXXL;
			color: constants._cTextSecondary;
			elide: Text.ElideRight;
			text: root.sText;
		}
		Text {
			anchors.horizontalCenter: parent.horizontalCenter;
			width: parent.width - constants._iSpacingSuper * 2;
			horizontalAlignment: Text.AlignHCenter;
			verticalAlignment: Text.AlignVCenter;
			font.pixelSize: constants._iFontLarge;
			color: constants._cTextHint;
			elide: Text.ElideRight;
			visible: root.sSubText !== "";
			text: root.sSubText;
		}
	}

	MouseArea {
		anchors.fill: parent;
		onClicked: root.refresh();
	}
}
