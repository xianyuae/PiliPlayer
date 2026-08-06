import QtQuick 1.1
import "../../js/util.js" as Util

Item {
	id: root;
	objectName: "idBottomNavWidget";
	property int iCurrentIndex: 0;
	signal clicked(string name);

	height: 64;

	function _IconSource(iconId)
	{
		return Qt.resolvedUrl("../images/icons/" + Util.HandleIconFile(iconId, constants._bInverted));
	}

	Rectangle {
		anchors.fill: parent;
		color: constants._cLightestColor;
		border.width: 1;
		border.color: constants._cLightColor;
	}

	Row {
		anchors.fill: parent;

		Item {
			width: parent.width / 5;
			height: parent.height;
			Column {
				anchors.centerIn: parent;
				spacing: constants._iSpacingTiny;
				Image {
					anchors.horizontalCenter: parent.horizontalCenter;
					width: constants._iSizeSmall + 2;
					height: width;
					source: _IconSource("toolbar-home");
					opacity: root.iCurrentIndex === 0 ? 1 : 0.55;
					smooth: true;
				}
				Text {
					anchors.horizontalCenter: parent.horizontalCenter;
					font.pixelSize: constants._iFontSmall;
					font.bold: root.iCurrentIndex === 0;
					color: root.iCurrentIndex === 0 ? constants._cThemeColor : constants._cDarkColor;
					elide: Text.ElideRight;
					text: "首页";
				}
			}
			Rectangle {
				anchors.top: parent.top;
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width * 0.45;
				height: 3;
				radius: 2;
				color: constants._cThemeColor;
				visible: root.iCurrentIndex === 0;
			}
			MouseArea {
				anchors.fill: parent;
				onClicked: root.clicked("Home");
			}
		}

		Item {
			width: parent.width / 5;
			height: parent.height;
			Column {
				anchors.centerIn: parent;
				spacing: constants._iSpacingTiny;
				Image {
					anchors.horizontalCenter: parent.horizontalCenter;
					width: constants._iSizeSmall + 2;
					height: width;
					source: _IconSource("toolbar-alarm");
					opacity: root.iCurrentIndex === 1 ? 1 : 0.55;
					smooth: true;
				}
				Text {
					anchors.horizontalCenter: parent.horizontalCenter;
					font.pixelSize: constants._iFontSmall;
					font.bold: root.iCurrentIndex === 1;
					color: root.iCurrentIndex === 1 ? constants._cThemeColor : constants._cDarkColor;
					elide: Text.ElideRight;
					text: "直播";
				}
			}
			Rectangle {
				anchors.top: parent.top;
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width * 0.45;
				height: 3;
				radius: 2;
				color: constants._cThemeColor;
				visible: root.iCurrentIndex === 1;
			}
			MouseArea {
				anchors.fill: parent;
				onClicked: root.clicked("Live");
			}
		}

		Item {
			width: parent.width / 5;
			height: parent.height;
			Column {
				anchors.centerIn: parent;
				spacing: constants._iSpacingTiny;
				Image {
					anchors.horizontalCenter: parent.horizontalCenter;
					width: constants._iSizeSmall + 2;
					height: width;
					source: _IconSource("toolbar-gallery");
					opacity: root.iCurrentIndex === 2 ? 1 : 0.55;
					smooth: true;
				}
				Text {
					anchors.horizontalCenter: parent.horizontalCenter;
					font.pixelSize: constants._iFontSmall;
					font.bold: root.iCurrentIndex === 2;
					color: root.iCurrentIndex === 2 ? constants._cThemeColor : constants._cDarkColor;
					elide: Text.ElideRight;
					text: "番剧";
				}
			}
			Rectangle {
				anchors.top: parent.top;
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width * 0.45;
				height: 3;
				radius: 2;
				color: constants._cThemeColor;
				visible: root.iCurrentIndex === 2;
			}
			MouseArea {
				anchors.fill: parent;
				onClicked: root.clicked("Bangumi");
			}
		}

		Item {
			width: parent.width / 5;
			height: parent.height;
			Column {
				anchors.centerIn: parent;
				spacing: constants._iSpacingTiny;
				Image {
					anchors.horizontalCenter: parent.horizontalCenter;
					width: constants._iSizeSmall + 2;
					height: width;
					source: _IconSource("toolbar-favorite-mark");
					opacity: root.iCurrentIndex === 3 ? 1 : 0.55;
					smooth: true;
				}
				Text {
					anchors.horizontalCenter: parent.horizontalCenter;
					font.pixelSize: constants._iFontSmall;
					font.bold: root.iCurrentIndex === 3;
					color: root.iCurrentIndex === 3 ? constants._cThemeColor : constants._cDarkColor;
					elide: Text.ElideRight;
					text: "排行";
				}
			}
			Rectangle {
				anchors.top: parent.top;
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width * 0.45;
				height: 3;
				radius: 2;
				color: constants._cThemeColor;
				visible: root.iCurrentIndex === 3;
			}
			MouseArea {
				anchors.fill: parent;
				onClicked: root.clicked("Ranking");
			}
		}

		Item {
			width: parent.width / 5;
			height: parent.height;
			Column {
				anchors.centerIn: parent;
				spacing: constants._iSpacingTiny;
				Image {
					anchors.horizontalCenter: parent.horizontalCenter;
					width: constants._iSizeSmall + 2;
					height: width;
					source: _IconSource("toolbar-grid");
					opacity: root.iCurrentIndex === 4 ? 1 : 0.55;
					smooth: true;
				}
				Text {
					anchors.horizontalCenter: parent.horizontalCenter;
					font.pixelSize: constants._iFontSmall;
					font.bold: root.iCurrentIndex === 4;
					color: root.iCurrentIndex === 4 ? constants._cThemeColor : constants._cDarkColor;
					elide: Text.ElideRight;
					text: "分类";
				}
			}
			Rectangle {
				anchors.top: parent.top;
				anchors.horizontalCenter: parent.horizontalCenter;
				width: parent.width * 0.45;
				height: 3;
				radius: 2;
				color: constants._cThemeColor;
				visible: root.iCurrentIndex === 4;
			}
			MouseArea {
				anchors.fill: parent;
				onClicked: root.clicked("Category");
			}
		}
	}
}
