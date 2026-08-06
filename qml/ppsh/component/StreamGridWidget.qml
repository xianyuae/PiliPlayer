import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	property alias model: view.model;
	property alias count: view.count;
	property alias currentIndex: view.currentIndex;
	signal clicked(int index, variant data);
	objectName: "idStreamGridWidget";

	Text{
		anchors.fill: parent;
		horizontalAlignment: Text.AlignHCenter;
		verticalAlignment: Text.AlignVCenter;
		font.bold: true;
		font.pixelSize: constants._iFontXL;
		elide: Text.ElideRight;
		clip: true;
		color: constants._cLighterColor;
		text: qsTr("No content");
		visible: view.count === 0;
	}

	GridView{
		id: view;
		anchors.fill: parent;
		clip: true;
		z: 1;
		visible: count > 0;
		cacheBuffer: 320;
		model: [];
		cellWidth: parent.width / 2;
		cellHeight: constants._iSizeXL;
		delegate: Component{
			Item{
				id: viewdelegateroot;
				width: GridView.view.cellWidth;
				height: GridView.view.cellHeight;
				MouseArea{
					anchors.fill: parent;
					onClicked: {
						view.currentIndex = index;
						root.clicked(index, modelData);
					}
				}
				Rectangle{
					anchors.fill: parent;
					anchors.margins: constants._iSpacingSmall;
					color: viewdelegateroot.GridView.isCurrentItem ? (constants._bInverted ? "#3a3540" : "#fdeff3") : constants._cCardColor;
					radius: constants._iRadiusMedium;
					smooth: true;
					border.width: viewdelegateroot.GridView.isCurrentItem ? 2 : 1;
					border.color: viewdelegateroot.GridView.isCurrentItem ? constants._cThemeColor : constants._cDividerColor;
					clip: true;

					Text{
						anchors.fill: parent;
						anchors.margins: constants._iSpacingLarge;
						horizontalAlignment: Text.AlignHCenter;
						verticalAlignment: Text.AlignVCenter;
						text: "" + index + ": " + modelData.name;
						font.pixelSize: constants._iFontLarge;
						elide: Text.ElideLeft;
						color: viewdelegateroot.GridView.isCurrentItem ? constants._cTextPrimary : constants._cTextSecondary;
					}
				}
			}
		}
	}

	ScrollDecorator{
		flickableItem: view;
	}
}
