import QtQuick 1.1
import com.nokia.meego 1.1

Item{
	id: root
	property int pageNo: 0;
	property int pageSize: 20;
	property int pageCount: 0;
	property int totalCount: 0;

	signal prev;
	signal next;
//	signal jump(int page);

	height: constants._iSizeXL;
	width: constants._iSizeBig;
	objectName: "idPagedWidget";
	opacity: 0.95;
	z: 1;
	//clip: true; // for icon moving everywhere

	Rectangle{
		anchors.fill: parent;
		radius: height / 2;
		color: constants._bInverted ? "#cc26272d" : "#ccffffff";
		border.width: 1;
		border.color: constants._cDividerColor;
	}

	ToolBarLayout{
		anchors.fill: parent;
		visible: root.pageCount > 1;
		IconWidget{
			iconId: "toolbar-previous";
			inverted: true;
			enabled: root.pageNo > 1;
			onClicked: {
				root.prev();
			}
		}
		IconWidget{
			iconId: "toolbar-next";
			inverted: true;
			enabled: root.pageNo < root.pageCount;
			onClicked: {
				root.next();
			}
		}
	}
}
