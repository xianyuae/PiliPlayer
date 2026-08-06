import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	signal clicked(string id, variant data);
	objectName: "idFavFolderDelegate";

	MouseArea{
		anchors.fill: parent;
		onClicked: {
			root.clicked(model.id, model);
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
			width: Util.GetSize(0, height, "16/10");
			fillMode: Image.PreserveAspectCrop;
			clip: true;
			source: model.preview;
			cache: true;
			sourceSize: Qt.size(width, height);
		}

		Column{
			anchors.left: preview.right;
			anchors.leftMargin: constants._iSpacingMedium;
			anchors.right: parent.right;
			anchors.rightMargin: constants._iSpacingLarge;
			anchors.verticalCenter: parent.verticalCenter;
			height: preview.height;
			spacing: constants._iSpacingTiny;
			Text{
				width: parent.width;
				height: parent.height * 0.44;
				text: model.title;
				font.pixelSize: constants._iFontLarge;
				elide: Text.ElideRight;
				color: constants._cTextPrimary;
				wrapMode: Text.WrapAnywhere;
				maximumLineCount: 2;
				clip: true;
			}
			Text{
				width: parent.width;
				height: parent.height * 0.2;
				clip: true;
				verticalAlignment: Text.AlignVCenter;
				text: qsTr("%1 contents").arg(Util.FormatCount(model.count));
				font.pixelSize: constants._iFontMedium;
				elide: Text.ElideRight;
				color: constants._cTextSecondary;
			}
			Row{
				width: parent.width;
				height: parent.height * 0.18;
				clip: true;
				spacing: constants._iSpacingLarge;
				Text{
					height: parent.height;
					verticalAlignment: Text.AlignVCenter;
					text: model.bPrivate ? qsTr("Private") : qsTr("Public");
					font.pixelSize: constants._iFontSmall;
					color: constants._cTextHint;
				}
				Text{
					height: parent.height;
					verticalAlignment: Text.AlignVCenter;
					text: model.up;
					font.pixelSize: constants._iFontSmall;
					elide: Text.ElideRight;
					color: constants._cTextHint;
				}
			}
			Text{
				width: parent.width;
				height: parent.height * 0.18;
				clip: true;
				verticalAlignment: Text.AlignVCenter;
				text: model.intro;
				font.pixelSize: constants._iFontSmall;
				elide: Text.ElideRight;
				color: constants._cTextHint;
			}
		}
	}
}
