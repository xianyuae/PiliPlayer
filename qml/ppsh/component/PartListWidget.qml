import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	objectName: "idPartListWidget";
	property alias model: view.model;
	property alias count: view.count;
	signal refresh;
	signal clicked(int index, string cid);

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

	ListView{
		id: view;
		anchors.fill: parent;
		clip: true;
		z: 1;
		visible: count > 0;
		cacheBuffer: 320;
		model: ListModel{}
		header: Component{
			RefreshWidget{
				onRefresh: root.refresh();
			}
		}
		delegate: Component{
			Item{
				id: viewdelegateroot;
				width: ListView.view.width;
				height: constants._iSizeXXL;
				MouseArea{
					anchors.fill: parent;
					onClicked: {
						view.currentIndex = index;
						root.clicked(index, model.cid);
					}
					onPressAndHold: {
						controller._CopyToClipboard(model.cid, "cid");
					}
				}
				Rectangle{
					anchors.fill: parent;
					anchors.margins: constants._iSpacingSmall;
					color: parent.ListView.isCurrentItem ? (constants._bInverted ? "#3a3540" : "#fdeff3") : constants._cCardColor;
					radius: constants._iRadiusMedium;
					smooth: true;
					border.width: parent.ListView.isCurrentItem ? 2 : 1;
					border.color: parent.ListView.isCurrentItem ? constants._cThemeColor : constants._cDividerColor;

					Row{
						anchors.fill: parent;
						anchors.margins: constants._iSpacingLarge;
						clip: true;
						Item{
							id: pages;
							width: constants._iSizeMedium;
							height: parent.height;
							clip: true;
							Rectangle{
								anchors.centerIn: parent;
								width: constants._iSizeMedium;
								height: width;
								radius: width / 2;
								color: viewdelegateroot.ListView.isCurrentItem ? constants._cThemeColor : constants._cLighterColor;
							}
							Text{
								anchors.centerIn: parent;
								horizontalAlignment: Text.AlignHCenter;
								verticalAlignment: Text.AlignVCenter;
								font.pixelSize: constants._iFontXL;
								font.bold: true;
								color: viewdelegateroot.ListView.isCurrentItem ? "#ffffff" : constants._cTextSecondary;
								text: model.page;
							}
						}
						Text{
							width: parent.width - pages.width;
							height: parent.height;
							//horizontalAlignment: Text.AlignHCenter;
							verticalAlignment: Text.AlignVCenter;
							text: model.name;
							font.pixelSize: constants._iFontLarge;
							elide: Text.ElideRight;
							color: constants._cTextPrimary;
							wrapMode: Text.WrapAnywhere;
							maximumLineCount: 2;
						}
					}

					Row{
						anchors.left: parent.left;
						anchors.right: parent.right;
						anchors.bottom: parent.bottom;
						anchors.leftMargin: constants._iSpacingLarge;
						anchors.rightMargin: constants._iSpacingLarge;
						width: parent.width;
						height: constants._iSizeTiny;
						layoutDirection: Qt.RightToLeft;
						z: 1;
						spacing: constants._iSpacingBig;
						clip: true;
						Text{
							height: parent.height;
							verticalAlignment: Text.AlignVCenter;
							text: model.cid;
							font.pixelSize: constants._iFontSmall;
							color: constants._cTextHint;
						}
						Text{
							height: parent.height;
							verticalAlignment: Text.AlignVCenter;
							text: qsTr("Duration") + ": " + Util.FormatDuration(model.duration);
							font.pixelSize: constants._iFontSmall;
							color: constants._cTextSecondary;
						}
					}
				}
			}
		}
	}

	ScrollDecorator{
		flickableItem: view;
	}
}
