import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	signal clicked(string aid);
	signal imageClicked(string aid);
	objectName: "idVideoGridDelegate";

	MouseArea{
		anchors.fill: parent;
		onClicked: {
			root.clicked(model.aid);
		}
		onPressAndHold: {
			controller._CopyToClipboard(model.aid, "avId");
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
			Row{
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.leftMargin: constants._iSpacingLarge;
				anchors.rightMargin: constants._iSpacingLarge;
				anchors.bottom: parent.bottom;
				height: constants._iSizeSmall;
				clip: true;
				spacing: constants._iSpacingMedium;
				Text{
					id: view_count;
					height: parent.height;
					verticalAlignment: Text.AlignVCenter;
					text: model.view_count ? Util.FormatCount(model.view_count) : "-";
					font.pixelSize: constants._iFontSmall;
					font.bold: true;
					elide: Text.ElideRight;
					color: "#ffffff";
				}
				Text{
					id: danmu_count;
					height: parent.height;
					verticalAlignment: Text.AlignVCenter;
					text: model.danmu_count ? Util.FormatCount(model.danmu_count) : "-";
					font.pixelSize: constants._iFontSmall;
					elide: Text.ElideRight;
					color: "#ffffff";
				}
				Text{
					width: parent.width - view_count.width - danmu_count.width - parent.spacing * 2;
					height: parent.height;
					text: model.duration || "";
					verticalAlignment: Text.AlignVCenter;
					horizontalAlignment: Text.AlignRight;
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
				height: parent.height - uprow.height - parent.spacing;
				text: model.title;
				font.pixelSize: constants._iFontMedium + 2;
				elide: Text.ElideRight;
				color: constants._cTextPrimary;
				wrapMode: Text.WrapAnywhere;
				maximumLineCount: 2;
				clip: true;
			}
			Row{
				id: uprow;
				width: parent.width;
				height: constants._iSizeSmall;
				clip: true;
				spacing: constants._iSpacingMedium;
				Text{
					height: parent.height;
					verticalAlignment: Text.AlignBottom;
					text: qsTr("UP");
					font.pixelSize: constants._iFontMedium;
					elide: Text.ElideRight;
					font.bold: true;
					color: constants._cTextSecondary;
				}
				Text{
					height: parent.height;
					verticalAlignment: Text.AlignBottom;
					text: model.up;
					font.pixelSize: constants._iFontMedium;
					elide: Text.ElideRight;
					color: constants._cTextSecondary;
				}
			}
		}
	}
}
