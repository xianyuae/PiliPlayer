import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;
	objectName: "idRankingPage";
	sTitle: obj.categoryName !== "" ? obj.categoryName : "排行";

	property int iModeIndex: 0;
	property variant aRankColors: ["#f6c945", "#c0c4cc", "#cd7f32"];

	Header{
		id: header;
		sText: root.sTitle;
		iTextMargin: back.width + refresh.width;
		onClicked: {
			obj._GetChannels();
		}
		Row{
			anchors.fill: parent;
			LocalToolIcon{
				id: back;
				anchors.verticalCenter: parent.verticalCenter;
				iconId: "toolbar-back";
				onClicked: pageStack.pop();
			}
			Item{
				anchors.verticalCenter: parent.verticalCenter;
				width: parent.width - back.width - refresh.width;
				height: parent.height;
			}
			LocalToolIcon{
				id: refresh;
				anchors.verticalCenter: parent.verticalCenter;
				iconId: "toolbar-refresh";
				onClicked: obj._Refresh();
			}
		}
	}

	function _Init()
	{
		obj._GetChannels();
	}

	QtObject{
		id: obj;
		property string categoryName: "";
		property string rid: "";
		property string order: "RANKING";
		property int limit: 20;

		function _GetChannels()
		{
			root.bBusy = true;
			Util.ModelClear(categorymodel);

			var d = {
				model: categorymodel,
			};

			var s = function(){
				root.bBusy = false;
				Util.ModelForeach(categorymodel, function(e, i){
					categorymodel.setProperty(i, "name", Script.GetChannelNameById(e.value) || e.value);
				});
				if(Util.ModelSize(categorymodel) > 0)
				{
					categoryview.currentIndex = 0;
					var r = Util.ModelGet(categorymodel, 0);
					obj._GetCategory(r.name, r.value);
				}
			};
			var f = function(err){
				root.bBusy = false;
				controller._ShowMessage(err);
			};

			Script.GetChannels(d, s, f);
		}

		function _GetCategory(name, id)
		{
			if(id !== undefined && rid !== id)
			{
				rid = id;
				order = "RANKING";
				root.iModeIndex = 0;
			}
			if(rid === "") return;
			if(name !== undefined) categoryName = name;

			_GetRanking();
		}

		function _GetRanking()
		{
			if(rid === "") return;

			root.bBusy = true;
			Util.ModelClear(rankmodel);

			var d = {
				rid: rid,
				model: rankmodel,
				pageSize: limit,
			};

			var s = function(){
				root.bBusy = false;
			};
			var f = function(err){
				root.bBusy = false;
				controller._ShowMessage(err);
			};

			(order === "NEWLIST" ? Script.GetCategoryNewlist : Script.GetCategoryRanking)(d, s, f);
		}

		function _Refresh()
		{
			if(rid !== "")
				_GetRanking();
			else
				_GetChannels();
		}
	}

	Component{
		id: rankdelegate;
		Item{
			id: ritem;
			width: ListView.view.width;
			height: constants._iSizeXXXL + constants._iSpacingMedium;

			Rectangle{
				anchors.fill: parent;
				anchors.margins: constants._iSpacingMedium;
				radius: constants._iRadiusMedium;
				color: constants._cCardColor;
				border.width: 1;
				border.color: constants._cDividerColor;
				clip: true;
			}

			Row{
				anchors.fill: parent;
				anchors.margins: constants._iSpacingLarge;
				spacing: constants._iSpacingMedium;

				Rectangle{
					id: rankbadge;
					anchors.verticalCenter: parent.verticalCenter;
					width: constants._iSizeLarge;
					height: width;
					radius: constants._iRadiusSmall;
					color: index < 3 ? root.aRankColors[index] : constants._cLighterColor;
					Text{
						anchors.centerIn: parent;
						text: index + 1;
						color: index < 3 ? "#ffffff" : constants._cTextSecondary;
						font.pixelSize: constants._iFontXL;
						font.bold: true;
					}
				}

				Image{
					id: rcover;
					anchors.verticalCenter: parent.verticalCenter;
					width: Util.GetSize(0, parent.height - constants._iSpacingMedium * 2, "16/9");
					height: parent.height - constants._iSpacingMedium * 2;
					source: model.preview;
					fillMode: Image.PreserveAspectCrop;
					clip: true;
					cache: true;
					sourceSize.width: width;
					Rectangle{
						anchors.right: parent.right;
						anchors.bottom: parent.bottom;
						anchors.rightMargin: constants._iSpacingSmall;
						anchors.bottomMargin: constants._iSpacingSmall;
						width: durationtext.paintedWidth + constants._iSpacingLarge * 2;
						height: constants._iSizeSmall;
						radius: height / 2;
						color: constants._cBadgeBg;
						visible: model.duration !== undefined && model.duration !== "";
						Text{
							id: durationtext;
							anchors.centerIn: parent;
							text: model.duration || "";
							font.pixelSize: constants._iFontSmall;
							color: "#ffffff";
						}
					}
				}

				Column{
					anchors.verticalCenter: parent.verticalCenter;
					width: parent.width - rankbadge.width - rcover.width - parent.spacing * 2;
					height: parent.height;
					spacing: constants._iSpacingTiny;
					Text{
						width: parent.width;
						height: parent.height * 0.52;
						text: model.title;
						font.pixelSize: constants._iFontLarge;
						elide: Text.ElideRight;
						wrapMode: Text.WrapAnywhere;
						maximumLineCount: 2;
						color: constants._cTextPrimary;
						clip: true;
					}
					Text{
						width: parent.width;
						height: parent.height * 0.16;
						text: model.up;
						font.pixelSize: constants._iFontMedium;
						elide: Text.ElideRight;
						color: constants._cTextSecondary;
						verticalAlignment: Text.AlignVCenter;
					}
					Text{
						width: parent.width;
						height: parent.height * 0.24;
						text: "播放 " + Util.FormatCount(model.view_count) + "  " + "弹幕 " + Util.FormatCount(model.danmu_count);
						font.pixelSize: constants._iFontSmall;
						elide: Text.ElideRight;
						color: constants._cTextHint;
						verticalAlignment: Text.AlignVCenter;
					}
				}
			}

			MouseArea{
				anchors.fill: parent;
				onClicked: {
					controller._OpenDetailPage(model.aid);
				}
			}
		}
	}

	ListView{
		id: categoryview;
		anchors.top: header.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		height: constants._iSizeLarge + constants._iSpacingSmall;
		orientation: ListView.Horizontal;
		clip: true;
		model: ListModel{
			id: categorymodel;
		}
		delegate: Component{
			Item{
				width: cattext.paintedWidth + constants._iSpacingSuper * 2;
				height: ListView.view.height;
				property bool selected: categoryview.currentIndex === index;
				Rectangle{
					anchors.fill: parent;
					anchors.margins: constants._iSpacingSmall;
					radius: height / 2;
					color: selected ? constants._cGlobalColor : constants._cTransparent;
					border.width: selected ? 0 : 1;
					border.color: constants._cDividerColor;
				}
				Text{
					id: cattext;
					anchors.centerIn: parent;
					text: model.name;
					font.pixelSize: constants._iFontLarge;
					elide: Text.ElideRight;
					color: selected ? "#ffffff" : constants._cTextSecondary;
				}
				MouseArea{
					anchors.fill: parent;
					onClicked: {
						categoryview.currentIndex = index;
						obj._GetCategory(model.name, model.value);
					}
				}
			}
		}
	}

	Row{
		id: moderow;
		anchors.top: categoryview.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.leftMargin: constants._iSpacingXXL;
		anchors.rightMargin: constants._iSpacingXXL;
		anchors.topMargin: constants._iSpacingMedium;
		height: constants._iSizeMedium + constants._iSpacingMedium;
		spacing: constants._iSpacingMedium;
		Repeater{
			model: [
				{
					name: "排行",
					value: "RANKING",
					icon: "toolbar-rank",
				},
				{
					name: "最新",
					value: "NEWLIST",
					icon: "toolbar-new",
				},
			]
			delegate: Component{
				Rectangle{
					width: (moderow.width - moderow.spacing) / 2;
					height: moderow.height - constants._iSpacingMedium;
					radius: constants._iRadiusMedium;
					color: root.iModeIndex === index ? constants._cGlobalColor : constants._cCardColor;
					border.width: root.iModeIndex === index ? 0 : 1;
					border.color: constants._cDividerColor;
					Row{
						anchors.centerIn: parent;
						spacing: constants._iSpacingMedium;
						Image{
							anchors.verticalCenter: parent.verticalCenter;
							width: constants._iSizeSmall;
							height: width;
							source: Qt.resolvedUrl("images/icons/" + Util.HandleIconFile(modelData.icon, root.iModeIndex === index || constants._bInverted));
							smooth: true;
						}
						Text{
							anchors.verticalCenter: parent.verticalCenter;
							text: modelData.name;
							font.pixelSize: constants._iFontLarge;
							font.bold: root.iModeIndex === index;
							color: root.iModeIndex === index ? "#ffffff" : constants._cTextPrimary;
						}
					}
					MouseArea{
						anchors.fill: parent;
						onClicked: {
							root.iModeIndex = index;
							obj.order = modelData.value;
							obj._GetRanking();
						}
					}
				}
			}
		}
	}

	Item{
		id: content;
		anchors.top: moderow.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		anchors.topMargin: constants._iSpacingMedium;
		clip: true;

		Rectangle{
			id: rankheader;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			height: constants._iSizeLarge;
			color: constants._cLighterColor;
			Row{
				anchors.fill: parent;
				anchors.leftMargin: constants._iSpacingXXL;
				anchors.rightMargin: constants._iSpacingXXL;
				spacing: constants._iSpacingMedium;
				Image{
					anchors.verticalCenter: parent.verticalCenter;
					width: constants._iSizeSmall;
					height: width;
					source: Qt.resolvedUrl("images/icons/" + Util.HandleIconFile("toolbar-rank", constants._bInverted));
					smooth: true;
				}
				Text{
					anchors.verticalCenter: parent.verticalCenter;
					width: parent.width - constants._iSizeSmall - parent.spacing;
					text: "排行[" + rankmodel.count + "]";
					font.pixelSize: constants._iFontLarge;
					font.bold: true;
					elide: Text.ElideRight;
					color: constants._cTextPrimary;
				}
			}
			MouseArea{
				anchors.fill: parent;
				onClicked: {
					obj._GetRanking();
				}
			}
		}

		Text{
			anchors.fill: parent;
			anchors.topMargin: rankheader.height;
			horizontalAlignment: Text.AlignHCenter;
			verticalAlignment: Text.AlignVCenter;
			font.pixelSize: constants._iFontLarge;
			color: constants._cLightColor;
			text: "无内容";
			visible: rankmodel.count === 0;
			MouseArea{
				anchors.fill: parent;
				onClicked: {
					obj._GetRanking();
				}
			}
		}

		ListView{
			id: ranklist;
			anchors.top: rankheader.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			clip: true;
			visible: rankmodel.count > 0;
			cacheBuffer: 320;
			model: ListModel{
				id: rankmodel;
			}
			header: Component{
				RefreshWidget{
					onRefresh: obj._GetRanking();
				}
			}
			delegate: rankdelegate;
		}

		ScrollDecorator{
			flickableItem: ranklist;
		}
	}
}
