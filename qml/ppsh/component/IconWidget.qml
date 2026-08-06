// form ToolIcon of QtComponents by Nokia
import QtQuick 1.1
import "../../js/util.js" as Util

Rectangle{
	id: root
	objectName: "idIconWidget";
	property url iconSource;
	property string platformIconId;
	property bool inverted: true;
	property alias iconId: root.platformIconId;
	property bool enabled: true;
	/*
	property int iDragMinimumY;
	property int iDragMaximumY;
	property int iDragMinimumX;
	property int iDragMaximumX;
	*/
	property int eDragAxis: Drag.XandYAxis;
	property bool bDragable: settings.bTouchIconDrag;
	signal clicked;

	radius: Math.min(width, height) / 2;
	color: constants._cGlobalColor;
	width: constants._iSizeXL;
	height: width;
	clip: true;
	border.width: 1;
	border.color: constants._bInverted ? "#00000000" : "#55ffffff";
	smooth: true;

	Image{
		anchors.centerIn: parent;
		width: parent.width * 0.6;
		height: width;
		source: iconSource != "" ? iconSource : Qt.resolvedUrl("../images/icons/" + Util.HandleIconFile(iconId, inverted));
		smooth: true;
	}

	Rectangle{
		id: mask;
		anchors.fill: parent;
		visible: mouseArea.pressed || !root.enabled;
		opacity: root.enabled ? 0.5 : 0.75;
		color: constants._cDarkerColor;
		radius: root.radius;
	}

	MouseArea{
		id: mouseArea;
		anchors.fill: parent;
		drag.target: root.bDragable ? root : undefined;
		drag.axis: root.eDragAxis;
		/*
		drag.minimumY: root.iDragMinimumY;
		drag.maximumY: root.iDragMaximumY;
		drag.minimumX: root.iDragMinimumX;
		drag.maximumX: root.iDragMaximumX;
		*/
	}

	Component.onCompleted: {
		mouseArea.clicked.connect(function(){
			if(root.enabled) root.clicked();
		});
	}
}
