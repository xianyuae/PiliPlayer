import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item {
	id: root

	objectName: "idListRefreshWidget";
	property string sIconId: "toolbar-refresh";

	property Flickable myView: null;

	property int visualY: 0
	property bool reloadTriggered: false
	property bool __connected: false;

	property int indicatorStart: 25
	property int refreshStart: 120

	property string pullDownMessage: isHeader ? qsTr("Pull down to activate") : qsTr("Pull up to activate");
	property string releaseRefreshMessage: qsTr("Release to activate");
	property string disabledMessage: qsTr("Now loading");
	property double lastUpdateTime: 0;

	property bool platformInverted: false;
	property bool isHeader: true;

	signal refresh;

	width: parent ? parent.width : 0;
	height: 0;

	function __update()
	{
		if (!myView) return;

		if (isHeader) {
			if (!myView.atYBeginning) return;
			var y = root.mapToItem(myView, 0, 0).y;
			if (y < refreshStart + 20)
				visualY = y;
		} else {
			if (!myView.atYEnd) return;
			var y = root.mapToItem(myView, 0, 0).y;
			var d = myView.height - y;
			if (d < refreshStart + 20)
				visualY = d;
		}

		if (visualY > refreshStart && myView.moving && !myView.flicking)
			reloadTriggered = true;
	}

	function __trigger()
	{
		if (!reloadTriggered) return;
		reloadTriggered = false;
		if (root.enabled)
			root.refresh();
	}

	function __connect()
	{
		if (__connected) return;

		if (!myView)
			myView = __findView();
		if (!myView) return;
		if (__connected) return;

		__connected = true;

		myView.flickableDirection = Flickable.VerticalFlick;
		myView.boundsBehavior = Flickable.DragAndOvershootBounds;

		myView.contentYChanged.connect(__update);
		myView.movementEnded.connect(__trigger);
		myView.flickEnded.connect(__trigger);
		__update();
	}

	function __findView()
	{
		var p = root.parent;
		while (p)
		{
			if (typeof(p.contentY) === "number" && typeof(p.moving) === "boolean")
				return p;
			p = p.parent;
		}
		return null;
	}

	onMyViewChanged: __connect();

	Timer {
		id: connectTimer
		interval: 100
		repeat: true
		running: true
		triggeredOnStart: true
		onTriggered: {
			if (!__connected) __connect();
			if (__connected) running = false;
		}
	}
	Row {
		anchors {
			bottom: isHeader ? parent.top : undefined; top: isHeader ? undefined : parent.bottom
			horizontalCenter: parent.horizontalCenter
			bottomMargin: isHeader ? constants._iSpacingSuper : 0
			topMargin: isHeader ? 0 : constants._iSpacingSuper
		}
		spacing: constants._iSpacingSuper;
		Image {
			source: root.sIconId != "" ? Qt.resolvedUrl("../images/icons/" + Util.HandleIconFile(root.sIconId, constants._bInverted)) : "";
			width: constants._iSizeMedium;
			height: width;
			opacity: visualY < indicatorStart ? 0.3 : 1;
			Behavior on opacity { NumberAnimation { duration: 100 } }
			rotation: {
				if (root.reloadTriggered)
					return isHeader ? -180 : 0;
				var newAngle = visualY > refreshStart ? 180 : visualY;
				return isHeader ? -newAngle : newAngle - 180;
			}
			Behavior on rotation { NumberAnimation { duration: 150 } }
		}
		Column {
			Label {
				color: constants._cDarkColor;
				font.pixelSize: constants._iFontLarge;
				text: root.enabled ? reloadTriggered ? releaseRefreshMessage : pullDownMessage : disabledMessage;
			}
			Label {
				color: constants._cLightColor;
				font.pixelSize: constants._iFontSmall;
				visible: root.enabled && root.lastUpdateTime != 0;
			}
		}
	}
}
