import QtQuick 1.1

Rectangle{
	id: root;
	objectName: "idLabelWidget";
	property alias sText: title.text;
	property alias iPixelSize: title.font.pixelSize;

	height: constants._iSizeSmall + constants._iSpacingSmall;
	width: title.paintedWidth + constants._iSpacingLarge * 2;
	color: constants._cThemeColor;
	visible: title.text !== "";
	clip: true;
	radius: height / 2;
	smooth: true;
	Text{
		id: title;
		anchors.centerIn: parent;
		height: parent.height;
		verticalAlignment: Text.AlignVCenter;
		font.bold: true;
		font.pixelSize: constants._iFontLarge;
		color: "#ffffff";
		clip: true;
		horizontalAlignment: Text.AlignHCenter;
		elide: Text.ElideRight;
	}
}
