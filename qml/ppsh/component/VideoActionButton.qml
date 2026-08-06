import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item {
	id: root;
	objectName: "idVideoActionButton";
	property string sLabel: "";
	property string sCount: "";
	property string sIcon: "";
	property bool bActive: false;
	property bool bEnabled: true;
	signal clicked;

	height: constants._iSizeXXL;

	Rectangle {
		anchors.fill: parent;
		radius: constants._iRadiusMedium;
		color: root.bActive ? constants._cThemeColor : (constants._bInverted ? "#2c2d34" : "#ffffff");
		border.width: root.bActive ? 0 : 1;
		border.color: constants._cDividerColor;
		opacity: root.bEnabled ? 1 : 0.5;
		clip: true;
		smooth: true;
	}

	Column {
		anchors.centerIn: parent;
		width: parent.width - constants._iSpacingLarge * 2;
		spacing: constants._iSpacingTiny;

		Image {
			anchors.horizontalCenter: parent.horizontalCenter;
			width: root.sIcon !== "" ? constants._iSizeSmall : 0;
			height: width;
			source: root.sIcon !== "" ? Qt.resolvedUrl("../images/icons/" + Util.HandleIconFile(root.sIcon, root.bActive || constants._bInverted)) : "";
			visible: root.sIcon !== "";
			smooth: true;
		}

		Text {
			anchors.horizontalCenter: parent.horizontalCenter;
			width: parent.width;
			height: constants._iSizeSmall;
			horizontalAlignment: Text.AlignHCenter;
			verticalAlignment: Text.AlignVCenter;
			font.pixelSize: constants._iFontMedium;
			font.bold: true;
			color: root.bActive ? "#ffffff" : constants._cTextPrimary;
			elide: Text.ElideRight;
			text: root.sLabel;
			clip: true;
		}

		Text {
			anchors.horizontalCenter: parent.horizontalCenter;
			width: parent.width;
			height: constants._iSizeSmall;
			horizontalAlignment: Text.AlignHCenter;
			verticalAlignment: Text.AlignVCenter;
			font.pixelSize: constants._iFontMedium;
			color: root.bActive ? "#eaffff" : constants._cTextSecondary;
			elide: Text.ElideRight;
			text: root.sCount;
			clip: true;
		}
	}

	MouseArea {
		anchors.fill: parent;
		enabled: root.bEnabled;
		onClicked: root.clicked();
	}
}
