import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	property alias model: view.model;
	property alias count: view.count;
	property color cLineColor: constants._cDarkColor;
	property color cTextColor: constants._cDarkestColor;
	property bool bInteractive: true;
	property bool bTabMode: false;
	property bool bInvertedMode: !constants._bInverted;
	property bool bFixedWidth: true;
	property int iTopMargin: 0;
	property int iBottomMargin: 0;
	property alias currentIndex: view.currentIndex;
	signal clicked(string name, string value, int index);
	objectName: "idTabListWidget";

	function _LoadModel(jsarr, limit)
	{
		view.model.clear();
		for(var i in jsarr)
		{
			if(limit && i >= limit) break;
			var e = jsarr[i];
			Util.ModelPush(view.model, e);
		}
	}

	ListView{
		id: view;
		anchors.fill: parent;
		anchors.topMargin: root.iTopMargin;
		anchors.bottomMargin: root.iBottomMargin;
		clip: true;
		orientation: ListView.Horizontal;
		interactive: !root.bTabMode;
		model: ListModel{}
		delegate: Component{
				Item{
					id: delegateroot;
				property int iLineWidth: 4;
				width: root.bTabMode ? (ListView.view.count > 0 ? ListView.view.width / ListView.view.count : ListView.view.width) : constants._iSizeXXXL;
				height: ListView.view.height;
				clip: true;
				//color: constants._cLightestColor;
				MouseArea{
					anchors.fill: parent;
					onClicked: {
						if(root.bInteractive)
						{
							view.currentIndex = index;
							root.clicked(model.name, model.value, index);
						}
					}
				}
				Text{
					anchors.fill: parent;
					anchors.margins: iLineWidth;
					horizontalAlignment: Text.AlignHCenter;
					verticalAlignment: Text.AlignVCenter;
					elide: Text.ElideLeft;
					color: root.bInvertedMode ? constants._cThemeColor : (delegateroot.ListView.isCurrentItem ? constants._cTextPrimary : root.cTextColor);
					font.pixelSize: constants._iFontXL;
					font.bold: delegateroot.ListView.isCurrentItem;
					text: model.name;
				}
				Rectangle{
					id: line;
					anchors.bottom: parent.bottom;
					anchors.left: parent.left;
					anchors.right: parent.right;
					height: iLineWidth;
					color: root.bInvertedMode ? constants._cThemeColor : (delegateroot.ListView.isCurrentItem ? constants._cThemeColor : constants._cDividerColor);
					visible: (!root.bInvertedMode && !delegateroot.ListView.isCurrentItem) || (root.bInvertedMode && delegateroot.ListView.isCurrentItem);
				}
			}
		}
	}
}
