import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/util.js" as Util

Item{
	id: root;
	property bool editMode: false;
	property string sCoverRatio: "4/3";
	signal clicked(string aid, variant data);
	signal imageClicked(string aid, variant data);
	signal longPressed(int index, variant data);
	objectName: "idMixedListDelegate";

	MouseArea{
		anchors.fill: parent;
		onClicked: {
			root.clicked(model.aid, model);
		}
		onPressAndHold: {
			root.longPressed(index, model);
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
			width: model.type == constants._eBangumiType ? Util.GetSize(height, 0, "4/3") : (model.type == constants._eUserType ? height : Util.GetSize(0, height, root.sCoverRatio));
			fillMode: Image.PreserveAspectCrop;
			clip: true;
			source: model.preview;
			cache: true;
			sourceSize: Qt.size(width, height);
			MouseArea{
				anchors.fill: parent;
				onClicked: {
					root.imageClicked(model.aid, model);
				}
			}
		}

		Column{
			id: col;
			anchors.left: preview.right;
			anchors.leftMargin: constants._iSpacingMedium;
			anchors.right: parent.right;
			anchors.rightMargin: constants._iSpacingLarge;
			anchors.verticalCenter: parent.verticalCenter;
			height: preview.height;
			spacing: constants._iSpacingTiny;
			Text{
				width: parent.width;
				height: parent.height * 0.62;
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
				text: model.up;
				font.pixelSize: constants._iFontMedium;
				elide: Text.ElideRight;
				color: constants._cTextSecondary;
			}
			Text{
				width: parent.width;
				height: parent.height * 0.18;
				clip: true;
				verticalAlignment: Text.AlignVCenter;
				text: Util.FormatTimestamp(model.ts / 1000);
				font.pixelSize: constants._iFontSmall;
				elide: Text.ElideRight;
				color: constants._cTextHint;
			}
		}

		LocalToolIcon{
			anchors.top: parent.top;
			anchors.right: parent.right;
			z: 1;
			enabled: root.editMode;
			visible: enabled;
			iconId: "toolbar-close";
			inverted: constants._bInverted;
			onClicked: {
				root.longPressed(index, model);
			}
		}
	}
}
