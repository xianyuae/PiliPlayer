import QtQuick 1.1
import com.nokia.meego 1.1
import "../ui"

Item{
	id: root;

	width: parent.width;
	height: mainlayout.height;
	clip: true;
	objectName: "idProgressWidget";
	property alias sText: title.sText;
	property alias value: progress.value;
	property alias minimumValue: progress.minimumValue;
	property alias maximumValue: progress.maximumValue;
	property alias bPressed: progress.pressed;
	property alias bEnabled: progress.enabled;
	property alias sCurText: curlabel.text;
	property alias sTotalText: totallabel.text;
	property int iMargins: 0;
	property int iPrecision: 0;
	property bool bAutoLabel: false;

	signal clicked(real value);
	signal move(real value);
	signal released(real value);

	Column{
		id: mainlayout;

		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.leftMargin: root.iMargins;
		anchors.rightMargin: root.iMargins;
		spacing: constants._iSpacingXL;

		SectionWidget{
			id: title;
			width: parent.width;
			anchors.horizontalCenter: parent.horizontalCenter;
			sText: root.sText + ": " + (root.bAutoLabel ? progress.value.toFixed(root.iPrecision) : curlabel.text);
			onClicked: root.clicked();
		}

		Column{
			width: parent.width;
			spacing: constants._iSpacingTiny;
			Row{
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width - constants._iSpacingLarge * 2;
				height: constants._iSizeTiny;
				Text{
					id: curlabel;
					width: parent.width / 2;
					height: parent.height;
					horizontalAlignment: Text.AlignLeft;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize: constants._iFontSmall;
					color: constants._cTextPrimary;
					elide: Text.ElideRight;
					text: (progress.value * 100).toFixed(2) + "%";
				}
				Text{
					id: totallabel;
					width: parent.width / 2;
					height: parent.height;
					horizontalAlignment: Text.AlignRight;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize: constants._iFontSmall;
					color: constants._cTextPrimary;
					elide: Text.ElideRight;
					text: "100%";
				}
			}
			Item{
				width: parent.width;
				height: progress.height * 4;
				anchors.horizontalCenter: parent.horizontalCenter;
				clip: true;
				PPSHProgress{
					id: progress;
					width: parent.width;
					anchors.centerIn: parent;
					minimumValue: 0;
					maximumValue: 100;
					onSeekClicked: root.clicked(ratio);
					onSeekMove: root.move(ratio);
					onSeekReleased: root.released(ratio);
				}
			}
		}
	}
}
