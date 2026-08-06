import QtQuick 1.1

Rectangle {
	id: root;
	objectName: "idPPSHBadge";
	property alias sText: label.text;
	property alias iPixelSize: label.font.pixelSize;
	property color cColor: constants._cThemeColor;

	height: Math.max(constants._iSizeSmall, label.paintedHeight + constants._iSpacingSmall * 2);
	width: Math.max(label.paintedWidth + constants._iSpacingLarge * 2, height);
	radius: height / 2;
	color: root.cColor;
	visible: label.text !== "";
	clip: true;

	Text {
		id: label;
		anchors.centerIn: parent;
		verticalAlignment: Text.AlignVCenter;
		horizontalAlignment: Text.AlignHCenter;
		font.bold: true;
		font.pixelSize: constants._iFontLarge;
		color: "#ffffff";
		elide: Text.ElideRight;
		clip: true;
	}
}
