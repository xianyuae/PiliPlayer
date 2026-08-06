import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	signal clicked(string sid);
	objectName: "iBangumiListDelegate";

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
		anchors.leftMargin: constants._iSpacingMedium;
		anchors.rightMargin: constants._iSpacingMedium;
		anchors.topMargin: constants._iSpacingSmall;
		anchors.bottomMargin: constants._iSpacingSmall;
		radius: constants._iRadiusMedium;
		color: constants._cCardColor;
		border.width: 1;
		border.color: constants._cDividerColor;
		clip: true;
		smooth: true;

		Image{
			id: preview;
			anchors.left: parent.left;
			anchors.leftMargin: constants._iSpacingMedium;
			anchors.verticalCenter: parent.verticalCenter;
			height: parent.height - constants._iSpacingMedium * 2;
			width: Util.GetSize(height, 0, "4/3");
			fillMode: Image.PreserveAspectCrop;
			clip: true;
			source: model.preview;
			cache: true;
			sourceSize: Qt.size(width, height);

			LabelWidget{
				anchors.right: parent.right;
				anchors.top: parent.top;
				anchors.topMargin: constants._iSpacingSmall;
				anchors.rightMargin: constants._iSpacingSmall;
				sText: model.badge;
				iPixelSize: constants._iFontMedium;
			}
		}

		Column{
			anchors.left: preview.right;
			anchors.leftMargin: constants._iSpacingMedium;
			anchors.right: rating.left;
			anchors.rightMargin: constants._iSpacingMedium;
			anchors.verticalCenter: parent.verticalCenter;
			height: preview.height;
			clip: true;
			spacing: constants._iSpacingSmall;
			Text{
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width;
				height: parent.height * 0.62;
				font.pixelSize: constants._iFontXL;
				elide: Text.ElideRight;
				clip: true;
				color: constants._cTextPrimary;
				maximumLineCount: 2;
				wrapMode: Text.WrapAnywhere;
				text: model.title;
			}
			Text{
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width;
				height: parent.height * 0.38;
				verticalAlignment: Text.AlignVCenter;
				font.pixelSize: constants._iFontLarge;
				elide: Text.ElideRight;
				clip: true;
				color: constants._cTextSecondary;
				text: model.index_show;
			}
		}
		Item{
			id: rating;
			anchors.right: parent.right;
			anchors.rightMargin: constants._iSpacingLarge;
			anchors.verticalCenter: parent.verticalCenter;
			width: Util.GetSize(height, 0, "16/9");
			height: preview.height;
			clip: true;
			Column{
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.top: parent.top;
				spacing: constants._iSpacingSmall;
				Text{
					anchors.horizontalCenter: parent.horizontalCenter;
					width: parent.width;
					horizontalAlignment: Text.AlignRight;
					font.pixelSize: constants._iFontLarge;
					font.bold: true;
					elide: Text.ElideRight;
					clip: true;
					color: constants._cGlobalColor;
					text: model.rating_score + qsTr("score");
				}
				Text{
					id: ratingcount;
					anchors.horizontalCenter: parent.horizontalCenter;
					width: parent.width;
					horizontalAlignment: Text.AlignRight;
					font.pixelSize: constants._iFontSmall;
					elide: Text.ElideRight;
					clip: true;
					color: constants._cTextHint;
					text: Util.FormatCount(model.rating_count);
				}
			}
		}
	}
}
