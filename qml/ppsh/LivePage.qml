import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;
	objectName: "idLivePage";
	sTitle: obj.mode === "rooms" && obj.categoryName !== "" ? obj.categoryName : "直播";

	property int iSortIndex: 0;
	property variant aAccentColors: ["#fb7299", "#2196f3", "#8bc34a", "#ff9800", "#9c27b0"];

	Header{
		id: header;
		sText: root.sTitle;
		iTextMargin: back.width + refresh.width;
		onClicked: {
			if(obj.mode === "rooms") obj._SetMode("channels");
			else obj._GetChannels();
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
		property string mode: "channels";
		property string categoryName: "";
		property string pid: "";
		property string aid: "";
		property int pageNo: 1;
		property int pageSize: 20;
		property int pageCount: 0;
		property int totalCount: 0;
		property string order: "online";

		function _GetChannels()
		{
			root.bBusy = true;
			mode = "channels";

			var tmp = [];
			var d = {
				model: tmp,
			};

			var s = function(){
				if(tmp.length > 0 && app.bLogin)
					tmp.unshift({
						name: "关注开播",
						rid: "follow",
						pid: "",
						children: [],
					});
				channelsview.model = tmp;
				root.bBusy = false;
			};
			var f = function(err){
				root.bBusy = false;
				controller._ShowMessage(err);
			};

			Script.GetLiveChannels(d, s, f);
		}

		function _OpenChannel(name, value, pvalue)
		{
			if(value === "follow")
				_GetFollowing();
			else
				_GetCategory(name, value, pvalue);
		}

		function _SetMode(m)
		{
			if(m === "rooms" && aid === "")
			{
				var first = Util.ModelGet(channelsview.model, 0);
				var child = null;
				if(first && first.children)
				{
					if(first.children.length > 0) child = first.children[0];
					else if(first.children.count > 0) child = first.children.get(0);
				}
				if(!child) child = first;
				if(child && child.rid)
				{
					if(child.rid === "follow")
						_GetFollowing();
					else
						_GetCategory(child.name, child.rid, child.pid);
					return;
				}
				mode = "channels";
				return;
			}
			mode = m;
		}

		function _GetFollowing(p)
		{
			aid = "follow";
			mode = "rooms";
			categoryName = "关注开播";
			root.bBusy = true;

			var pn = 1;
			if(typeof(p) === "number") pn = p;
			else if(p === constants._sNextPage) pn = pageNo + 1;
			else if(p === constants._sPrevPage) pn = pageNo - 1;
			else if(p === constants._sThisPage) pn = pageNo;

			var d = {
				model: livemodel,
				pageNo: pn,
				pageSize: pageSize,
			};

			if(p === undefined)
			{
				pageNo = 1;
				pageSize = 20;
				pageCount = 0;
				totalCount = 0;
			}
			Util.ModelClear(livemodel);

			var s = function(data){
				if(data)
				{
					obj.pageNo = data.pageNo;
					obj.pageSize = data.pageSize;
					obj.pageCount = data.pageCount;
					obj.totalCount = data.totalCount;
				}
				root.bBusy = false;
			};
			var f = function(err){
				root.bBusy = false;
				controller._ShowMessage(err);
			};

			Script.GetLiveFollowing(d, s, f);
		}

		function _GetCategory(name, id, p_id, p)
		{
			if(id !== undefined && aid !== id)
			{
				aid = id;
				root.iSortIndex = 0;
				order = "online";
			}
			if(p_id !== undefined && pid !== p_id)
			{
				pid = p_id;
				root.iSortIndex = 0;
				order = "online";
			}
			if(aid === "") return;
			if(name !== undefined) categoryName = name;
			mode = "rooms";
			if(aid === "follow")
			{
				_GetFollowing(p);
				return;
			}

			root.bBusy = true;

			var pn = 1;
			if(typeof(p) === "number") pn = p;
			else if(p === constants._sNextPage) pn = pageNo + 1;
			else if(p === constants._sPrevPage) pn = pageNo - 1;
			else if(p === constants._sThisPage) pn = pageNo;

			var d = {
				model: livemodel,
				pageNo: pn,
				pageSize: pageSize,
				aid: aid,
				pid: pid,
				order: order,
			};

			if(p === undefined)
			{
				pageNo = 1;
				pageSize = 20;
				pageCount = 0;
				totalCount = 0;
			}
			Util.ModelClear(livemodel);

			var s = function(data){
				if(data)
				{
					obj.pageNo = data.pageNo;
					obj.pageSize = data.pageSize;
					obj.pageCount = data.pageCount;
					obj.totalCount = data.totalCount;
				}
				root.bBusy = false;
			};
			var f = function(err){
				root.bBusy = false;
				controller._ShowMessage(err);
			};

			Script.GetLive(d, s, f);
		}

		function _Refresh()
		{
			if(mode === "rooms")
				_GetCategory(undefined, undefined, undefined, constants._sThisPage);
			else
				_GetChannels();
		}
	}

	Component{
		id: livedelegate;
		Item{
			id: lroot;
			width: GridView.view.cellWidth;
			height: GridView.view.cellHeight;

			Rectangle{
				anchors.fill: parent;
				anchors.margins: constants._iSpacingMedium;
				radius: constants._iRadiusMedium;
				color: constants._cCardColor;
				border.width: 1;
				border.color: constants._cDividerColor;
				clip: true;
			}

			Column{
				anchors.fill: parent;
				anchors.margins: constants._iSpacingLarge;
				spacing: constants._iSpacingTiny;

				Item{
					id: previewbox;
					width: parent.width;
					height: Util.GetSize(width, 0, "16/9");
					Image{
						id: lpreview;
						anchors.fill: parent;
						source: model.preview;
						fillMode: Image.PreserveAspectCrop;
						clip: true;
						cache: true;
						sourceSize.width: width;
					}
					Rectangle{
						anchors.left: parent.left;
						anchors.top: parent.top;
						anchors.leftMargin: constants._iSpacingSmall;
						anchors.topMargin: constants._iSpacingSmall;
						width: constants._iSizeSmall + constants._iSpacingXXXL;
						height: constants._iSizeSmall;
						radius: height / 2;
						color: "#e53935";
						Text{
							anchors.centerIn: parent;
							text: "直播";
							font.pixelSize: constants._iFontSmall;
							font.bold: true;
							color: "#ffffff";
						}
					}
					Rectangle{
						anchors.left: parent.left;
						anchors.right: parent.right;
						anchors.bottom: parent.bottom;
						height: constants._iSizeMedium;
						gradient: Gradient{
							GradientStop{ position: 0.0; color: "#00000000"; }
							GradientStop{ position: 1.0; color: "#cc000000"; }
						}
						Row{
							anchors.fill: parent;
							anchors.leftMargin: constants._iSpacingMedium;
							anchors.rightMargin: constants._iSpacingMedium;
							spacing: constants._iSpacingSmall;
							Image{
								anchors.verticalCenter: parent.verticalCenter;
								width: constants._iSizeSmall;
								height: width;
								source: Qt.resolvedUrl("images/icons/" + Util.HandleIconFile("toolbar-online", true));
								smooth: true;
							}
							Text{
								width: parent.width - constants._iSizeSmall - parent.spacing;
								height: parent.height;
								verticalAlignment: Text.AlignVCenter;
								text: model.uname + "  " + (model.online ? Util.FormatCount(model.online) : "-");
								font.pixelSize: constants._iFontSmall;
								elide: Text.ElideRight;
								color: "#ffffff";
							}
						}
					}
				}

				Text{
					width: parent.width;
					height: Math.max(0, parent.height - previewbox.height - infotext.height - parent.spacing * 2);
					text: model.title;
					font.pixelSize: constants._iFontMedium + 2;
					elide: Text.ElideRight;
					wrapMode: Text.WrapAnywhere;
					maximumLineCount: 2;
					color: constants._cTextPrimary;
					clip: true;
				}

				Text{
					id: infotext;
					width: parent.width;
					height: constants._iSizeSmall;
					text: (model.area ? model.area + "  " : "") + "在线人数" + " " + (model.online ? Util.FormatCount(model.online) : "-");
					font.pixelSize: constants._iFontSmall;
					elide: Text.ElideRight;
					color: constants._cTextSecondary;
					verticalAlignment: Text.AlignVCenter;
				}
			}

			MouseArea{
				anchors.fill: parent;
				onClicked: {
					controller._OpenLiveDetailPage(model.rid);
				}
				onPressAndHold: {
					controller._CopyToClipboard(model.rid, "房间号");
				}
			}
		}
	}

	Row{
		id: moderow;
		anchors.top: header.bottom;
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
					name: "频道",
					value: "channels",
					icon: "toolbar-category",
				},
				{
					name: "直播",
					value: "rooms",
					icon: "toolbar-live-tv",
				},
			]
			delegate: Component{
				Rectangle{
					width: (moderow.width - moderow.spacing) / 2;
					height: moderow.height - constants._iSpacingMedium;
					radius: constants._iRadiusMedium;
					color: obj.mode === modelData.value ? constants._cGlobalColor : constants._cCardColor;
					border.width: obj.mode === modelData.value ? 0 : 1;
					border.color: constants._cDividerColor;
					Row{
						anchors.centerIn: parent;
						spacing: constants._iSpacingMedium;
						Image{
							anchors.verticalCenter: parent.verticalCenter;
							width: constants._iSizeSmall;
							height: width;
							source: Qt.resolvedUrl("images/icons/" + Util.HandleIconFile(modelData.icon, obj.mode === modelData.value || constants._bInverted));
							smooth: true;
						}
						Text{
							anchors.verticalCenter: parent.verticalCenter;
							text: modelData.name;
							font.pixelSize: constants._iFontLarge;
							font.bold: obj.mode === modelData.value;
							color: obj.mode === modelData.value ? "#ffffff" : constants._cTextPrimary;
						}
					}
					MouseArea{
						anchors.fill: parent;
						onClicked: {
							obj._SetMode(modelData.value);
						}
					}
				}
			}
		}
	}

	Item{
		id: channelspanel;
		anchors.top: moderow.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		visible: obj.mode === "channels";
		clip: true;

		ChannelsFlowWidget{
			id: channelsview;
			anchors.fill: parent;
			onRefresh: {
				obj._GetChannels();
			}
			onClicked: {
				obj._OpenChannel(name, value, pvalue);
			}
			onHeaderClicked: {
				obj._OpenChannel(name, value, pvalue);
			}
		}
	}

	Item{
		id: roomspanel;
		anchors.top: moderow.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		visible: obj.mode === "rooms";
		clip: true;

		Row{
			id: sortrow;
			anchors.top: parent.top;
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
					name: "在线人数",
					value: "online",
					icon: "toolbar-online",
				},
				{
					name: "直播时间",
					value: "live_time",
					icon: "toolbar-schedule",
				},
				]
				delegate: Component{
					Rectangle{
						width: (sortrow.width - sortrow.spacing) / 2;
						height: sortrow.height - constants._iSpacingMedium;
						radius: constants._iRadiusMedium;
						color: root.iSortIndex === index ? constants._cGlobalColor : constants._cCardColor;
						border.width: root.iSortIndex === index ? 0 : 1;
						border.color: constants._cDividerColor;
						Row{
							anchors.centerIn: parent;
							spacing: constants._iSpacingMedium;
							Image{
								anchors.verticalCenter: parent.verticalCenter;
								width: constants._iSizeSmall;
								height: width;
								source: Qt.resolvedUrl("images/icons/" + Util.HandleIconFile(modelData.icon, root.iSortIndex === index || constants._bInverted));
								smooth: true;
							}
							Text{
								anchors.verticalCenter: parent.verticalCenter;
								text: modelData.name;
								font.pixelSize: constants._iFontLarge;
								font.bold: root.iSortIndex === index;
								color: root.iSortIndex === index ? "#ffffff" : constants._cTextPrimary;
							}
						}
						MouseArea{
							anchors.fill: parent;
							onClicked: {
								root.iSortIndex = index;
								obj.order = modelData.value;
								obj._GetCategory();
							}
						}
					}
				}
			}
		}

		Text{
			anchors.fill: parent;
			anchors.topMargin: sortrow.height + constants._iSpacingMedium;
			horizontalAlignment: Text.AlignHCenter;
			verticalAlignment: Text.AlignVCenter;
			font.pixelSize: constants._iFontLarge;
			color: constants._cLightColor;
			text: "无内容";
			visible: livemodel.count === 0;
			MouseArea{
				anchors.fill: parent;
				onClicked: {
					obj._GetCategory(undefined, undefined, undefined, constants._sThisPage);
				}
			}
		}

		GridView{
			id: livegrid;
			anchors.top: sortrow.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: pager.top;
			anchors.topMargin: constants._iSpacingMedium;
			clip: true;
			visible: livemodel.count > 0;
			cacheBuffer: 320;
			cellWidth: Math.floor(width / (width < height ? 2 : 3));
			cellHeight: Math.floor(cellWidth * 0.5625 + constants._iSizeXXL);
			model: ListModel{
				id: livemodel;
			}
			header: Component{
				RefreshWidget{
					onRefresh: obj._GetCategory(undefined, undefined, undefined, constants._sThisPage);
				}
			}
			delegate: livedelegate;
		}

		ScrollDecorator{
			flickableItem: livegrid;
		}

		Item{
			id: pager;
			anchors.bottom: parent.bottom;
			anchors.horizontalCenter: parent.horizontalCenter;
			height: obj.pageCount > 1 ? constants._iSizeLarge : 0;
			width: constants._iSizeBig + constants._iSpacingXXXL * 2;
			Rectangle{
				anchors.fill: parent;
				radius: height / 2;
				color: constants._bInverted ? "#cc26272d" : "#ccffffff";
				border.width: 1;
				border.color: constants._cDividerColor;
				visible: obj.pageCount > 1;
			}
			Row{
				anchors.fill: parent;
				visible: obj.pageCount > 1;
				LocalToolIcon{
					anchors.verticalCenter: parent.verticalCenter;
					width: constants._iSizeLarge;
					height: width;
					iconId: "toolbar-previous";
					inverted: constants._bInverted;
					enabled: obj.pageNo > 1;
					onClicked: {
						obj._GetCategory(undefined, undefined, undefined, constants._sPrevPage);
					}
				}
				Text{
					width: parent.width - constants._iSizeLarge * 2;
					height: parent.height;
					horizontalAlignment: Text.AlignHCenter;
					verticalAlignment: Text.AlignVCenter;
					text: obj.pageNo + " / " + obj.pageCount;
					font.pixelSize: constants._iFontLarge;
					font.bold: true;
					color: constants._cTextPrimary;
				}
				LocalToolIcon{
					anchors.verticalCenter: parent.verticalCenter;
					width: constants._iSizeLarge;
					height: width;
					iconId: "toolbar-next";
					inverted: constants._bInverted;
					enabled: obj.pageNo < obj.pageCount;
					onClicked: {
						obj._GetCategory(undefined, undefined, undefined, constants._sNextPage);
					}
				}
			}
		}
	}
}
