import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;

	sTitle: _UT.Get("NAME");
	objectName: "idMainPage";

	Header{
		id: header;
		//sText: root.sTitle;
		bMouseEnabled: false;
		/*
		onClicked: {
			obj._GetRecommend();
		}
		*/
	 height: constants._iSizeXXL;
		Row{
			anchors.fill: parent;
			clip: true;
			spacing: constants._iSpacingSmall;
			LocalToolIcon{
				id: menuicon;
				anchors.verticalCenter: parent.verticalCenter;
				width: height;
				iconId: "toolbar-view-menu";
				onClicked: {
					menu._Toggle(true);
				}
			}
			Item{
				id: searchentry;
				anchors.verticalCenter: parent.verticalCenter;
                width: parent.width * 0.8;
				height: constants._iSizeLarge;
				clip: true;
				Rectangle{
					anchors.fill: parent;
					radius: height / 2;
					color: constants._bInverted ? "#26272d" : "#ffffff";
					border.width: 1;
					border.color: constants._bInverted ? "#373940" : "#e6e8ec";
				}
				Row{
					anchors.fill: parent;
					anchors.leftMargin: constants._iSpacingLarge;
					anchors.rightMargin: constants._iSpacingLarge;
					spacing: constants._iSpacingMedium;
					Image{
						anchors.verticalCenter: parent.verticalCenter;
						width: constants._iSizeSmall;
						height: width;
						source: Qt.resolvedUrl("images/icons/" + Util.HandleIconFile("toolbar-search", constants._bInverted));
						smooth: true;
					}
					Text{
						anchors.verticalCenter: parent.verticalCenter;
						width: parent.width - constants._iSizeSmall - parent.spacing;
						text: qsTr("Search videos / UPs / av / BV");
						font.pixelSize: constants._iFontLarge;
						elide: Text.ElideRight;
						clip: true;
						color: constants._bInverted ? "#9096a1" : "#878c96";
					}
				}
				MouseArea{
					anchors.fill: parent;
					onClicked: {
						controller._OpenSearchPage(true);
					}
				}
			}
		}
	}

	function _Init()
	{
		obj._GetRecommend();
	}

	QtObject{
		id: obj;

		function _GetRecommend()
		{
			root.bBusy = true;
			Util.ModelClear(view.model);

			var d = {
				model: view.model,
				limit: 20,
				ps: 20,
				freshIdx: 0,
			};

			var s = function(){
				root.bBusy = false;
			};
			var f = function(err){
				root.bBusy = false;
				controller._ShowMessage(err);
			};

			Script.GetRecommendFeed(d, s, f);
		}
	}

	VideoGridWidget{
		id: view;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: header.bottom;
		anchors.bottom: bottomnav.top;
		onRefresh: {
			obj._GetRecommend();
		}
	}

	Loader{
		id: bottomnav;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		height: 64;
		source: "component/BottomNavWidget.qml";
		onStatusChanged: {
			if(status === Loader.Ready && bottomnav.item)
			{
				bottomnav.item.clicked.connect(function(name){
                    if(name === "Live") controller._OpenLivePage();
                    else if(name === "Bangumi") controller._OpenBangumiPage();
                    else if(name === "Ranking") controller._OpenRankingPage();
                    else if(name === "Category") controller._OpenCategoryPage();
				});
			}
		}
	}

	Component.onCompleted: {
		_Init();
	}
}
