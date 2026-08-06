import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	signal clicked(string aid, variant data);
	signal imageClicked(string aid, variant data);
	objectName: "idVideoListDelegate";

	MouseArea{
		anchors.fill: parent;
		onClicked: {
			root.clicked(model.aid, model);
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
			width: Util.GetSize(0, height, "16/9");
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

			Rectangle{
				anchors.right: parent.right;
				anchors.bottom: parent.bottom;
				anchors.rightMargin: constants._iSpacingSmall;
				anchors.bottomMargin: constants._iSpacingSmall;
				width: durationtext.paintedWidth + constants._iSpacingLarge * 2;
				height: constants._iSizeSmall;
				radius: height / 2;
				color: constants._cBadgeBg;
				clip: true;
				visible: model.duration ? true : false;
				Text{
					id: durationtext;
					anchors.centerIn: parent;
					text: model.duration || "";
					verticalAlignment: Text.AlignVCenter;
					horizontalAlignment: Text.AlignHCenter;
					font.pixelSize: constants._iFontSmall;
					elide: Text.ElideRight;
					color: "#ffffff";
				}
			}
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
				height: parent.height * 0.56;
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
				height: parent.height * 0.16;
				clip: true;
				verticalAlignment: Text.AlignVCenter;
				text: model.up;
				font.pixelSize: constants._iFontMedium;
				elide: Text.ElideRight;
				color: constants._cTextSecondary;
			}
			Row{
				width: parent.width;
				height: parent.height * 0.28;
				clip: true;
				spacing: constants._iSpacingLarge;
				Text{
					height: parent.height;
					verticalAlignment: Text.AlignVCenter;
					visible: model.view_count !== undefined;
					text: qsTr("Play") + " " + (model.view_count ? Util.FormatCount(model.view_count) : "-");
					font.pixelSize: constants._iFontSmall;
					color: constants._cTextSecondary;
				}
				Text{
					height: parent.height;
					verticalAlignment: Text.AlignVCenter;
					visible: model.danmu_count !== undefined;
					text: qsTr("Danmaku") + " " + (model.danmu_count ? Util.FormatCount(model.danmu_count) : "-");
					font.pixelSize: constants._iFontSmall;
					color: constants._cTextSecondary;
				}
			}
		}
	}
}
