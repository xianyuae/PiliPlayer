import QtQuick 1.1

Rectangle {
	id: root;
	objectName: "idPPSHCard";
	property bool bElevated: false;
	property int iRadius: constants._iRadiusMedium;

	radius: root.iRadius;
	color: constants._cCardColor;
	border.width: 1;
	border.color: constants._cDividerColor;
	clip: true;
	smooth: true;

	Rectangle {
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		height: root.bElevated ? 2 : 0;
		color: constants._cLightColor;
		visible: root.bElevated;
	}
}
