import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util
import "../ui"

Item{
	id: root;
	property alias model: view.model;
	property alias count: view.count;
	signal clicked(string name, string value, string pvalue);
	signal headerClicked(string name, string value, string pvalue);
	signal refresh;
	objectName: "idChannelsGridWidget";

	PPSHEmptyState{
		anchors.fill: parent;
		visible: view.count === 0;
		onRefresh: root.refresh();
	}

	ListView{
		id: view;
		anchors.fill: parent;
		clip: true;
		z: 1;
		visible: count > 0;
		cacheBuffer: 320;
		model: [];
		header: Component{
			RefreshWidget{
				onRefresh: root.refresh();
			}
		}
		delegate: Component{
			Item{
				id: viewdelegateroot;
				width: ListView.view.width;
				height: childrenRect.height;

				Column{
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;
					anchors.leftMargin: constants._iSpacingLarge;
					anchors.rightMargin: constants._iSpacingLarge;
					spacing: constants._iSpacingMedium;
					Item{
						width: parent.width;
						height: childrenRect.height;
						SectionWidget{
							id: cname;
							anchors.top: parent.top;
							anchors.left: parent.left;
							anchors.right: parent.right;
							sText: modelData.name;
							onClicked: root.headerClicked(modelData.name, modelData.rid, modelData.pid);
						}
						Flow{
							id: sublayout;
							anchors.top: cname.bottom;
							anchors.left: parent.left;
							anchors.right: parent.right;
							anchors.topMargin: constants._iSpacingSmall;
							spacing: constants._iSpacingLarge;
							Repeater{
								model: modelData.children;
								delegate: Component{
									Item{
										width: childbg.width;
										height: childbg.height;
										clip: true;
										Rectangle{
											id: childbg;
											width: childtext.paintedWidth + constants._iSpacingSuper * 2;
											height: constants._iSizeMedium + constants._iSpacingSmall;
											radius: height / 2;
											color: constants._cCardColor;
											border.width: 1;
											border.color: constants._cDividerColor;
											Text{
												id: childtext;
												anchors.centerIn: parent;
												text: modelData.name;
												font.pixelSize: constants._iFontLarge;
												elide: Text.ElideRight;
												color: constants._cTextPrimary;
											}
										}
										MouseArea{
											anchors.fill: parent;
											onClicked: {
												root.clicked(modelData.name, modelData.rid, modelData.pid);
											}
										}
									}
								}
							}
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
