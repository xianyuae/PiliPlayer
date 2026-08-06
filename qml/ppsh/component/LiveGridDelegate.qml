import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	signal clicked(string rid);
	signal imageClicked(string rid);
	objectName: "idLiveGridDelegate";

	MouseArea{
		anchors.fill: parent;
		onClicked: {
			root.clicked(model.rid);
		}
		onPressAndHold: {
			controller._CopyToClipboard(model.rid, qsTr("room Id"));
		}
	}

	Rectangle{
		anchors.fill: parent;
		anchors.margins: constants._iSpacingMedium;
		smooth: true;
		radius: constants._iRadiusMedium;
		color: constants._cCardColor;
		border.width: 1;
		border.color: constants._cDividerColor;
		Image{
			id: preview;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.top: parent.top;
			height: Util.GetSize(width, 0, "16/9");
			source: model.preview;
			fillMode: Image.PreserveAspectCrop;
			clip: true;
			cache: true;
			sourceSize.width: width;
			Rectangle{
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.bottom: parent.bottom;
				height: constants._iSizeMedium;
				gradient: Gradient{
					GradientStop{ position: 0.0; color: "#00000000"; }
					GradientStop{ position: 1.0; color: "#cc000000"; }
				}
			}
			Rectangle{
				anchors.left: parent.left;
				anchors.top: parent.top;
				anchors.leftMargin: constants._iSpacingSmall;
				anchors.topMargin: constants._iSpacingSmall;
				width: constants._iSizeSmall + constants._iSpacingSmall;
				height: constants._iSizeSmall;
				radius: height / 2;
				color: "#e53935";
				Text{
					anchors.centerIn: parent;
					text: qsTr("LIVE");
					font.bold: true;
					font.pixelSize: constants._iFontSmall;
					color: "#ffffff";
				}
			}
			Row{
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.leftMargin: constants._iSpacingLarge;
				anchors.rightMargin: constants._iSpacingLarge;
				anchors.bottom: parent.bottom;
				height: constants._iSizeSmall;
				clip: true;
				Text{
					width: parent.width / 2;
					height: parent.height;
					text: model.uname;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize: constants._iFontMedium;
					font.bold: true;
					elide: Text.ElideRight;
					color: "#ffffff";
				}
				Text{
					width: parent.width / 2;
					height: parent.height;
					verticalAlignment: Text.AlignVCenter;
					horizontalAlignment: Text.AlignRight;
					text: qsTr("Online") + " " + (model.online ? Util.FormatCount(model.online) : "-");
					font.pixelSize: constants._iFontMedium;
					elide: Text.ElideRight;
					color: "#ffffff";
				}
			}
		}

		Column{
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.top: preview.bottom;
			anchors.bottom: parent.bottom;
			anchors.leftMargin: constants._iSpacingLarge;
			anchors.rightMargin: constants._iSpacingLarge;
			anchors.topMargin: constants._iSpacingMedium;
			anchors.bottomMargin: constants._iSpacingMedium;
			spacing: constants._iSpacingTiny;
			Text{
				width: parent.width;
				height: parent.height - areatext.height - parent.spacing;
				text: model.title;
				font.pixelSize: constants._iFontMedium + 2;
				elide: Text.ElideRight;
				color: constants._cTextPrimary;
				wrapMode: Text.WrapAnywhere;
				maximumLineCount: 2;
				clip: true;
			}
			Text{
				id: areatext;
				width: parent.width;
				height: constants._iSizeSmall;
				verticalAlignment: Text.AlignBottom;
				text: model.area;
				font.pixelSize: constants._iFontMedium;
				elide: Text.ElideRight;
				color: constants._cTextSecondary;
			}
		}
	}
}
