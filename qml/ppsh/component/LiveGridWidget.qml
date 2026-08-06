import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	property alias model: view.model;
	property alias count: view.count;
	signal refresh;
	objectName: "idLiveGridWidget";

	Text{
		anchors.fill: parent;
		horizontalAlignment: Text.AlignHCenter;
		verticalAlignment: Text.AlignVCenter;
		font.bold: true;
		font.pixelSize: constants._iFontSuper;
		elide: Text.ElideRight;
		clip: true;
		color: constants._cLightColor;
		text: qsTr("No content");
		visible: view.count === 0;
		MouseArea{
			anchors.centerIn: parent;
			width: parent.paintedWidth;
			height: parent.paintedHeight;
			onClicked: root.refresh();
		}
	}

	GridView{
		id: view;
		anchors.fill: parent;
		clip: true;
		z: 1;
		visible: count > 0;
		cacheBuffer: 320;
		cellWidth: Math.floor(width / (width < height ? 2 : 3));
		cellHeight: Math.floor(cellWidth * 0.5625 + constants._iSizeXXL);
		model: ListModel{}
		header: Component{
			RefreshWidget{
				onRefresh: root.refresh();
			}
		}
		delegate: Component{
			LiveGridDelegate{
				width: GridView.view.cellWidth;
				height: GridView.view.cellHeight;
				onClicked: {
					controller._OpenLiveDetailPage(rid);
				}
			}
		}
	}

	ScrollDecorator{
		flickableItem: view;
	}
}
