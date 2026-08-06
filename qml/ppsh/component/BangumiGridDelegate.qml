import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	signal clicked(string sid);
	objectName: "iBangumiGridDelegate";

	MouseArea{
		anchors.fill: parent;
		onClicked: {
			root.clicked(model.sid);
		}
		onPressAndHold: {
			controller._CopyToClipboard(model.bangumi_id, "Bangumi Id");
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
			height: Util.GetSize(0, width, "4/3");
			source: model.preview;
			fillMode: Image.PreserveAspectCrop;
			clip: true;
			cache: true;
			sourceSize.width: width;
			LabelWidget{
				anchors.right: parent.right;
				anchors.top: parent.top;
				anchors.topMargin: constants._iSpacingSmall;
				anchors.rightMargin: constants._iSpacingSmall;
				sText: model.badge;
				iPixelSize: constants._iFontMedium;
			}
			Rectangle{
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.bottom: parent.bottom;
				height: constants._iSizeSmall + constants._iSpacingSmall;
				gradient: Gradient{
					GradientStop{ position: 0.0; color: "#00000000"; }
					GradientStop{ position: 1.0; color: "#bb000000"; }
				}
			}
			Text{
				anchors.left: parent.left;
				anchors.bottom: parent.bottom;
				anchors.bottomMargin: constants._iSpacingSmall;
				anchors.leftMargin: constants._iSpacingSmall;
				width: parent.width;
				text: model.follow;
				font.pixelSize: constants._iFontMedium;
				elide: Text.ElideRight;
				color: "#ffffff";
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
				height: parent.height - indextext.height - parent.spacing;
				text: model.title;
				font.pixelSize: constants._iFontMedium;
				elide: Text.ElideRight;
				color: constants._cTextPrimary;
				wrapMode: Text.WrapAnywhere;
				maximumLineCount: 2;
			}
			Text{
				id: indextext;
				width: parent.width;
				height: constants._iSizeSmall;
				verticalAlignment: Text.AlignBottom;
				text: model.index_show;
				font.pixelSize: constants._iFontSmall;
				elide: Text.ElideRight;
				color: constants._cTextHint;
			}
		}
	}
}
