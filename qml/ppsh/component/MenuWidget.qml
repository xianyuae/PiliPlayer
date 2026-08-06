import QtQuick 1.1
import com.nokia.meego 1.1
import "../component"
import "../../js/util.js" as Util

Item{
	id: root;
	objectName: "idMenuWidget";
	property alias model: view.model;
	property bool bLogin: false;
	property string sUname: "";
	property string sFace: "";
	property string sMid: "";
	property int iLevel: 0;
	property real fCoins: 0;
	property int iFollowing: 0;
	property int iFollower: 0;
	property int iMenuListWidth: width - constants._iSizeXXXL;
	property int iAnimInterval: 320;
	property alias tools: toolbarlayout.children;
	signal loginRequested();
	signal profileRequested();
	signal logoutRequested();

	z: constants._iMenuZ;
	clip: true;
	visible: menu.state === constants._sShowState;

	RectWidget{
		id: mask;
		anchors.fill: parent;
		visible: opacity !== 0 && menu.state === constants._sShowState;
		color: "#000000";
		state: menu.state;
		iStart: 0;
		iTarget: 0.62;
		sProperty: "opacity";
		iDuration: root.iAnimInterval;
		MouseArea{
			anchors.fill: parent;
			onClicked: {
				root._Toggle(false);
			}
		}
	}

	RectWidget{
		id: menu;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		width: root.iMenuListWidth;
		z: 1;
		color: constants._cLightestColor;
		border.width: 1;
		border.color: constants._cDividerColor;
		state: constants._sHideState;
		iStart: -root.iMenuListWidth;
		iTarget: 0;
		sProperty: "x";
		iDuration: root.iAnimInterval;

		Rectangle{
			id: profileheader;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			height: root.bLogin ? constants._iSizeBig + constants._iSpacingBig : constants._iSizeXXXL + constants._iSpacingBig;
			color: constants._cGlobalColor;
			clip: true;
			z: 1;

			Rectangle{
				anchors.fill: parent;
				gradient: Gradient{
					GradientStop{ position: 0.0; color: "#33ffffff"; }
					GradientStop{ position: 0.55; color: "#0affffff"; }
					GradientStop{ position: 1.0; color: "#00000000"; }
				}
			}

			Rectangle{
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.bottom: parent.bottom;
				height: 1;
				color: "#000000";
				opacity: 0.22;
			}

			MouseArea{
				anchors.fill: parent;
				onClicked: {
					if(root.bLogin) root.profileRequested();
					else root.loginRequested();
				}
			}

			Rectangle{
				id: avatarrect;
				anchors.left: parent.left;
				anchors.top: parent.top;
				anchors.leftMargin: constants._iSpacingXXL;
				anchors.topMargin: constants._iSpacingXXL;
				width: constants._iSizeXL;
				height: width;
				radius: root.bLogin ? width / 2 : 0;
				color: root.bLogin ? "#22000000" : constants._cTransparent;
				border.width: root.bLogin ? 2 : 0;
				border.color: "#ccffffff";
				clip: true;
				Image{
					id: face;
					anchors.fill: parent;
					cache: true;
					fillMode: Image.PreserveAspectCrop;
					visible: root.bLogin ? root.sFace !== "" : true;
					source: root.bLogin ? root.sFace : "../../../res/Transparent_Akkarin.png";
				}
				Text{
					id: faceplaceholder;
					anchors.centerIn: parent;
					visible: !face.visible;
					text: root.bLogin ? "UP" : "B";
					color: "#ffffff";
					font.pixelSize: root.bLogin ? constants._iFontXXL : constants._iFontSmall;
					font.bold: true;
				}
			}

			LocalToolIcon{
				id: logoutbtn;
				z: 2;
				anchors.top: parent.top;
				anchors.right: parent.right;
				anchors.topMargin: constants._iSpacingMedium;
				anchors.rightMargin: constants._iSpacingMedium;
				width: constants._iSizeLarge;
				height: width;
				iconId: "toolbar-logout";
				visible: root.bLogin;
				onClicked: root.logoutRequested();
			}

			Row{
				id: namerow;
				visible: root.bLogin;
				anchors.left: avatarrect.right;
				anchors.right: logoutbtn.left;
				anchors.top: parent.top;
				anchors.topMargin: constants._iSpacingXXL;
				anchors.leftMargin: constants._iSpacingXXL;
				anchors.rightMargin: constants._iSpacingMedium;
				spacing: constants._iSpacingSmall;
				clip: true;
				Text{
					id: uname;
					anchors.verticalCenter: parent.verticalCenter;
					width: parent.width - levelbadge.width - parent.spacing;
					height: constants._iSizeMedium;
					verticalAlignment: Text.AlignVCenter;
					elide: Text.ElideRight;
					clip: true;
					font.pixelSize: constants._iFontXL;
					font.bold: true;
					color: "#ffffff";
					text: root.sUname;
				}
				Rectangle{
					id: levelbadge;
					anchors.verticalCenter: parent.verticalCenter;
					width: constants._iSizeMedium + constants._iSpacingLarge;
					height: constants._iSizeSmall;
					radius: height / 2;
					color: constants._GetLevelColor(root.iLevel);
					Text{
						anchors.centerIn: parent;
						text: "Lv." + root.iLevel;
						color: "#ffffff";
						font.pixelSize: constants._iFontTiny;
						font.bold: true;
					}
				}
			}

			Text{
				id: uidtext;
				visible: root.bLogin;
				anchors.left: avatarrect.right;
				anchors.top: namerow.bottom;
				anchors.topMargin: constants._iSpacingMedium;
				anchors.leftMargin: constants._iSpacingXXL;
				anchors.right: logoutbtn.left;
				anchors.rightMargin: constants._iSpacingMedium;
				height: constants._iSizeSmall;
				verticalAlignment: Text.AlignVCenter;
				elide: Text.ElideRight;
				clip: true;
				text: "UID: " + root.sMid;
				color: "#ccffffff";
				font.pixelSize: constants._iFontSmall;
			}

			Column{
				id: logininfo;
				visible: !root.bLogin;
				anchors.left: avatarrect.right;
				anchors.right: loginbtn.left;
				anchors.verticalCenter: avatarrect.verticalCenter;
				anchors.leftMargin: constants._iSpacingXXL;
				anchors.rightMargin: constants._iSpacingXXL;
				spacing: constants._iSpacingSmall;
				Text{
					width: parent.width;
					text: "登录";
					elide: Text.ElideRight;
					color: "#ffffff";
					font.pixelSize: constants._iFontXXL;
					font.bold: true;
				}
				Text{
					width: parent.width;
					text: "哔哩哔哩账号";
					elide: Text.ElideRight;
					color: "#ccffffff";
					font.pixelSize: constants._iFontSmall;
				}
			}

			Rectangle{
				id: loginbtn;
				visible: !root.bLogin;
				anchors.right: parent.right;
				anchors.verticalCenter: avatarrect.verticalCenter;
				anchors.rightMargin: constants._iSpacingXXL;
				width: constants._iSizeXL;
				height: constants._iSizeMedium;
				radius: height / 2;
				color: "#ffffff";
				Text{
					anchors.centerIn: parent;
					text: "登录";
					color: constants._cGlobalColor;
					font.pixelSize: constants._iFontSmall;
					font.bold: true;
				}
			}

			Rectangle{
				id: statline;
				visible: root.bLogin;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.bottom: stats.top;
				height: constants._iSpacingMicro;
				color: "#55ffffff";
			}

			Row{
				id: stats;
				visible: root.bLogin;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.bottom: parent.bottom;
				height: constants._iSizeXL;
				Repeater{
					model: [
						{ value: root.fCoins, name: "硬币" },
						{ value: root.iFollowing, name: "关注" },
						{ value: root.iFollower, name: "粉丝" }
					]
					delegate: Component{
						Item{
							width: stats.width / 3;
							height: stats.height;
							Column{
								anchors.fill: parent;
								spacing: constants._iSpacingTiny;
								Text{
									anchors.horizontalCenter: parent.horizontalCenter;
									text: root.__CountText(modelData.value);
									color: "#ffffff";
									font.pixelSize: constants._iFontXL;
									font.bold: true;
								}
								Text{
									anchors.horizontalCenter: parent.horizontalCenter;
									text: modelData.name;
									color: "#ccffffff";
									font.pixelSize: constants._iFontSmall;
								}
							}
							Rectangle{
								anchors.right: parent.right;
								anchors.top: parent.top;
								anchors.bottom: parent.bottom;
								width: 1;
								color: "#33ffffff";
								visible: index < 2;
							}
						}
					}
				}
			}
		}
		Rectangle{
			id: listheader;
			anchors.top: profileheader.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			height: constants._iSizeMedium;
			color: constants._cLighterColor;
			Rectangle{
				anchors.bottom: parent.bottom;
				anchors.left: parent.left;
				anchors.right: parent.right;
				height: 1;
				color: constants._cDividerColor;
				opacity: 0.6;
			}
			Text{
				anchors.left: parent.left;
				anchors.leftMargin: constants._iSpacingXXL;
				anchors.verticalCenter: parent.verticalCenter;
				text: "导航";
				font.pixelSize: constants._iFontSmall;
				font.bold: true;
				color: constants._cTextSecondary;
			}
		}
		ListView{
			id: view;
			anchors.top: listheader.bottom;
			anchors.bottom: tb.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.topMargin: constants._iSpacingSmall;
			anchors.bottomMargin: constants._iSpacingMedium;
			clip: true;
			model: ListModel{}
			delegate: Component{
				Rectangle{
					id: viewdelegateroot;
					property bool pressed: false;
					width: ListView.view.width;
					height: constants._iSizeXXL - constants._iSpacingSmall;
					color: controller._IsCurrentPage(model.name) ? (constants._bInverted ? "#33343c" : "#f4f5f8") : (pressed ? (constants._bInverted ? "#2e3037" : "#eceef2") : constants._cTransparent);
					MouseArea{
						anchors.fill: parent;
						onPressed: viewdelegateroot.pressed = true;
						onReleased: viewdelegateroot.pressed = false;
						onCanceled: viewdelegateroot.pressed = false;
						onClicked: {
							root._Toggle(false);
							eval(model.func);
						}
					}

					Row{
						anchors.fill: parent;
						anchors.margins: constants._iSpacingLarge;
						spacing: constants._iSpacingXL;
						Rectangle{
							id: iconbg;
							anchors.verticalCenter: parent.verticalCenter;
							width: constants._iSizeLarge;
							height: width;
							radius: width / 2;
							color: controller._IsCurrentPage(model.name) ? constants._cGlobalColor : (constants._bInverted ? "#34363d" : "#f0f1f4");
							Image{
								id: icon;
								anchors.centerIn: parent;
								width: parent.width * 0.58;
								height: width;
								source: Qt.resolvedUrl("../images/icons/" + Util.HandleIconFile("toolbar-" + model.icon, controller._IsCurrentPage(model.name) || constants._bInverted));
								smooth: true;
							}
						}
						Text{
							anchors.verticalCenter: parent.verticalCenter;
							width: parent.width - iconbg.width - chevron.width - parent.spacing * 2;
							height: parent.height;
							text: model.label;
							verticalAlignment: Text.AlignVCenter;
							font.pixelSize: constants._iFontXL;
							elide: Text.ElideRight;
							color: controller._IsCurrentPage(model.name) ? constants._cThemeColor : constants._cDarkerColor;
							clip: true;
						}
						Image{
							id: chevron;
							anchors.verticalCenter: parent.verticalCenter;
							width: constants._iSizeSmall;
							height: width;
							source: Qt.resolvedUrl("../images/icons/" + Util.HandleIconFile("toolbar-next", constants._bInverted));
							opacity: controller._IsCurrentPage(model.name) ? 0.75 : 0.35;
							smooth: true;
						}
					}

					Rectangle{
						id: currentbar;
						anchors.left: parent.left;
						anchors.top: parent.top;
						anchors.bottom: parent.bottom;
						width: 3;
						color: constants._cGlobalColor;
						visible: controller._IsCurrentPage(model.name);
					}

					Rectangle{
						anchors.bottom: parent.bottom;
						anchors.left: parent.left;
						anchors.right: parent.right;
						anchors.leftMargin: constants._iSizeLarge + constants._iSpacingXXL + constants._iSpacingLarge;
						anchors.rightMargin: constants._iSpacingXXL;
						height: constants._iSpacingMicro;
						color: constants._cDividerColor;
						opacity: 0.55;
					}
				}
			}
		}

		Item{
			id: tb;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			height: toolbarlayout.children.length > 0 ? constants._iSizeXL : 0;
			clip: true;
			Rectangle{
				anchors.fill: parent;
				color: constants._cLighterColor;
			}
			ToolBarLayout{
				id: toolbarlayout;
				anchors.fill: parent;
			}
			Rectangle{
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.leftMargin: constants._iSpacingLarge;
				anchors.rightMargin: constants._iSpacingLarge;
				height: constants._iSpacingMicro;
				color: constants._cDividerColor;
				z: 1;
			}
		}

		ScrollDecorator{
			flickableItem: view;
		}
	}

	function _Toggle(on)
	{
		if(on === undefined)
		{
			if(menu.state === constants._sHideState) menu.state = constants._sShowState;
			else if(menu.state === constants._sShowState) menu.state = constants._sHideState;
		}
		else
		{
			menu.state = on ? constants._sShowState : constants._sHideState;
		}
	}

	function __CountText(v)
	{
		var n = Number(v);
		if(n % 1 !== 0) return n.toFixed(1);
		return Util.FormatCount(n);
	}
}
