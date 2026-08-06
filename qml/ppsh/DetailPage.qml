import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;

	sTitle: qsTr("Detail");
	objectName: "idDetailPage";

	Header{
		id: header;
		sText: obj.title !== "" ? obj.title : root.sTitle;
		iTextMargin: back.width;
		onClicked: {
			obj._GetAll();
		}
		ToolBarLayout{
			anchors.fill: parent;
			LocalToolIcon{
				id: back;
				anchors.verticalCenter: parent.verticalCenter;
				/*
				height: parent.height;
				width: height;
				*/
				iconId: "toolbar-back";
				onClicked: {
					loader._DeInit();
					pageStack.pop();
				}
			}
		}
	}

	function _Init(id)
	{
		if(!id)
		return;
		obj.aid = id;
		obj._GetAll();
	}

	QtObject{
		id: obj;
		property string aid;
		property string order: typerow.vCurrentValue;
		property int pageNo: 1;
		property int pageSize: 20;
		property int pageCount: 0;
		property int totalCount: 0;
		property string uname;
		property string preview;
		property string title;
		property string uid;
		property string bvid: "";
		property int likeCount: 0;
		property int coinCount: 0;
		property int favCount: 0;
		property int dislikeCount: 0;
		property int shareCount: 0;
		property bool bLike: false;
		property bool bCoin: false;
		property bool bFav: false;
		property bool bDislike: false;
		property bool bActionBusy: false;
		property variant favFolders: [];

		function _PlayOnPage()
		{
			if(aid === "") return;

			loader._DeInit();
			Script.AddViewHistory(aid, title, preview, uname, constants._eVideoType);
			controller._OpenPlayerPage(aid);
		}

		function _Play(index, cid)
		{
			if(aid === "" || Util.ModelSize(partview.model) === 0) return;

			root.bBusy = true;
			if(loader.item === null) controller._ShowMessage(qsTr("Loading video player..."));
			var r = loader._Load(aid, partview.model, cid);
			if(r < 0) controller._ShowMessage(qsTr("Load video player fail"));
			else if(r === 0)
			{
				controller._ShowMessage(qsTr("Hold player to switch fullscreen or normal"));
				Script.AddViewHistory(aid, title, preview, uname, constants._eVideoType);
			}
			root.bBusy = false;
		}

		function _GetAll()
		{
			pageNo = 1;
			pageSize = 20;
			pageCount = 0;
			totalCount = 0;

			Util.ModelClear(recommendview.model);
			Util.ModelClear(commentview.model);
			tabgroup.currentTab = descview;

			typerow.iCurrentIndex = 0;
			order = typerow.aOptions[0].value;

			_GetDetail();
			//_GetComment();
			//_GetRecommend();
		}

		function _GetDetail()
		{
			if(aid == "") return;

			root.bBusy = true;

			preview = "";
			title = "";
			uname = "";
			uid = "";
			bvid = "";
			likeCount = 0;
			coinCount = 0;
			favCount = 0;
			dislikeCount = 0;
			shareCount = 0;
			bLike = false;
			bCoin = false;
			bFav = false;
			bDislike = false;
			bActionBusy = false;
			favFolders = [];

			parttab.num = 0;
			commenttab.num = 0;
			avatar.source = "";
			desc.text = "";
			infolist.model = [];

			var d = {
				model: partview.model,
				aid: aid,
			};

			Util.ModelClear(partview.model);

			var s = function(data){
				obj.aid = data.aid || obj.aid;
				obj.preview = data.preview;
				obj.uname = data.up;
				obj.title = data.title;
				obj.uid = data.uid;
				obj.bvid = data.bvid || "";
				obj.likeCount = Number(data.like) || 0;
				obj.coinCount = Number(data.coin) || 0;
				obj.favCount = Number(data.favorite) || 0;
				obj.dislikeCount = Number(data.dislike) || 0;
				obj.shareCount = Number(data.share) || 0;

				avatar.source = data.avatar;
				desc.text = data.desc;
				parttab.num = data.videos;
				commenttab.num = data.reply;
				infolist.model = [
					{ name: qsTr("Play"), value: Util.FormatCount(data.view_count), icon: "toolbar-mediacontrol-play", },
					{ name: qsTr("Danmaku"), value: Util.FormatCount(data.danmu_count), icon: "toolbar-chat", },
					{ name: "", value: Util.FormatTimestamp(data.create_time), icon: "toolbar-schedule", },
					{ name: "", value: "AV" + data.aid, icon: "toolbar-video", },
				];

				obj._GetActionStates();
				root.bBusy = false;
			};
			var f = function(err){
				root.bBusy = false;
				controller._ShowMessage(err);
			};

			Script.GetVideoDetail(d, s, f);
		}

		function _GetComment(p)
		{
			if(aid == "") return;

			root.bBusy = true;

			var pn;
			if(typeof(p) === "number") d.pn = p;
			else if(p === constants._sNextPage) pn = pageNo + 1;
			else if(p === constants._sPrevPage) pn = pageNo - 1;
			else if(p === constants._sThisPage) pn = pageNo;
			else pn = 1;
			var d = {
				aid: aid,
				model: commentview.model,
				pageNo: pn,
				order: order,
			};

			if(pn === 1) Util.ModelClear(commentview.model);

			var s = function(data){
				obj.pageNo = data.pageNo;
				obj.pageSize = data.pageSize;
				obj.pageCount = data.pageCount;
				obj.totalCount = data.totalCount;
				root.bBusy = false;
			};
			var f = function(err){
				root.bBusy = false;
				controller._ShowMessage(err);
			};

			Script.GetComment(d, s, f);
		}

		function _GetRecommend()
		{
			if(aid == "") return;

			root.bBusy = true;

			var d = {
				model: recommendview.model,
				aid: aid,
			};

			Util.ModelClear(recommendview.model);

			var s = function(){
				root.bBusy = false;
			};
			var f = function(err){
				root.bBusy = false;
				controller._ShowMessage(err);
			};

			Script.GetRecommend(d, s, f);
		}

		function _GetParts()
		{
			if(aid == "") return;

			root.bBusy = true;

			var d = {
				model: partview.model,
				aid: aid,
			};

			Util.ModelClear(partview.model);

			var s = function(data){
				root.bBusy = false;
			};
			var f = function(err){
				root.bBusy = false;
				controller._ShowMessage(err);
			};

			Script.GetVideoDetail(d, s, f);
		}

		function _RequireLogin()
		{
			if(!app.bLogin)
			{
				controller._ShowMessage(qsTr("Please login first"));
				controller._OpenLoginPage();
				return false;
			}
			return true;
		}

		function _ResetActionStates()
		{
			bLike = false;
			bCoin = false;
			bFav = false;
			bDislike = false;
			bActionBusy = false;
			favFolders = [];
		}

		function _GetActionStates()
		{
			if(aid === "") return;
			if(!app.bLogin)
			{
				_ResetActionStates();
				return;
			}
			Script.GetVideoLikeState({bvid: bvid, aid: aid}, function(data){
				obj.bLike = data == 1;
			}, function(){});
			Script.GetVideoCoinState({bvid: bvid, aid: aid}, function(data){
				obj.bCoin = data && data.multiply > 0;
			}, function(){});
			obj._RefreshFavState();
		}

		function _Like()
		{
			if(!_RequireLogin() || bActionBusy) return;
			bActionBusy = true;
			var type = !bLike;
			Script.SetVideoLike({bvid: bvid, aid: aid, like: type ? 1 : 2}, function(){
				obj.bLike = type;
				obj.likeCount = Math.max(0, obj.likeCount + (type ? 1 : -1));
				obj.bActionBusy = false;
				controller._ShowMessage(type ? qsTr("Like successful") : qsTr("Unlike successful"));
			}, function(err){
				obj.bActionBusy = false;
				controller._ShowMessage(err);
			});
		}

		function _Coin()
		{
			if(!_RequireLogin() || bActionBusy) return;
			if(bCoin)
			{
				controller._ShowMessage(qsTr("Already coined"));
				return;
			}
			controller._Select(qsTr("Coin"), [qsTr("1 coin"), qsTr("2 coins")], function(index){
				obj._DoCoin(index + 1);
			});
		}

		function _DoCoin(multiply)
		{
			if(!multiply || bActionBusy) return;
			bActionBusy = true;
			Script.SetVideoCoin({bvid: bvid, aid: aid, multiply: multiply}, function(){
				obj.bCoin = true;
				obj.coinCount += multiply;
				obj.bActionBusy = false;
				app.fCoins = Math.max(0, Number(app.fCoins) - multiply);
				_UT.SetSetting("account/coins", app.fCoins);
				controller._ShowMessage(qsTr("Coin successful"));
			}, function(err){
				obj.bActionBusy = false;
				controller._ShowMessage(err);
			});
		}

		function _Fav()
		{
			if(!_RequireLogin() || bActionBusy) return;
			if(Util.ModelSize(favFolders) > 0)
			{
				obj._OpenFavSelect(favFolders);
				return;
			}
			bActionBusy = true;
			Script.GetVideoFavFolders({uid: app.sMid, aid: aid}, function(list){
				obj.bActionBusy = false;
				obj.favFolders = list || [];
				obj._OpenFavSelect(obj.favFolders);
			}, function(err){
				obj.bActionBusy = false;
				controller._ShowMessage(err);
			});
		}

		function _OpenFavSelect(list)
		{
			if(!list || list.length === 0)
			{
				controller._ShowMessage(qsTr("No favorite folder"));
				return;
			}
			var folders = [];
			var names = [];
			var hadFav = obj.bFav;
			if(hadFav)
				names.push(qsTr("Cancel favorite"));
			for(var i in list)
			{
				var e = list[i];
				if(!e.id) continue;
				folders.push(e);
				if(Number(e.fav_state) === 1)
					names.push(qsTr("Remove from %1").arg(e.title));
				else
					names.push(qsTr("Favorite to %1").arg(e.title));
			}
			if(folders.length === 0)
			{
				controller._ShowMessage(qsTr("No favorite folder"));
				return;
			}
			obj.favFolders = folders;
			controller._Select(qsTr("Favorite"), names, function(index){
				if(hadFav && index === 0)
				{
					obj._UnfavoriteAll(folders);
					return;
				}
				var folderIndex = hadFav ? index - 1 : index;
				var folder = folders[folderIndex];
				if(!folder) return;
				obj._DoFav(folder.id, Number(folder.fav_state) !== 1);
			});
		}

		function _UnfavoriteAll(folders)
		{
			if(bActionBusy) return;
			var list = folders || favFolders;
			var ids = [];
			for(var i in list)
			{
				if(Number(list[i].fav_state) === 1)
					ids.push(list[i].id);
			}
			if(ids.length === 0)
			{
				for(var i in list)
					ids.push(list[i].id);
			}
			if(ids.length === 0)
			{
				controller._ShowMessage(qsTr("No favorite folder"));
				return;
			}
			bActionBusy = true;
			Script.SetVideoFav({aid: aid, addIds: "", delIds: ids.join(",")}, function(){
				for(var i in list)
					list[i].fav_state = 0;
				obj.bFav = false;
				obj.favCount = 0;
				obj.bActionBusy = false;
				controller._ShowMessage(qsTr("Unfavorite successful"));
				favsynctimer.restart();
			}, function(err){
				obj.bActionBusy = false;
				controller._ShowMessage(err);
			});
		}

		function _RefreshFavCount()
		{
			Script.GetVideoDetail({model: [], aid: aid}, function(data){
				obj.favCount = Number(data.favorite) || 0;
			}, function(){});
		}

		function _DoFav(fid, add)
		{
			if(!fid || bActionBusy) return;
			bActionBusy = true;
			var opt = {
				aid: aid,
				addIds: add ? fid : "",
				delIds: add ? "" : fid,
			};
			Script.SetVideoFav(opt, function(){
				var changed = false;
				for(var i in obj.favFolders)
				{
					if(obj.favFolders[i].id === fid)
					{
						var was = Number(obj.favFolders[i].fav_state) === 1;
						obj.favFolders[i].fav_state = add ? 1 : 0;
						changed = was !== add;
						break;
					}
				}
				if(changed)
					obj.favCount = Math.max(0, obj.favCount + (add ? 1 : -1));
				obj.bActionBusy = false;
				controller._ShowMessage(add ? qsTr("Favorite successful") : qsTr("Unfavorite successful"));
				favsynctimer.restart();
			}, function(err){
				obj.bActionBusy = false;
				controller._ShowMessage(err);
			});
		}

		function _RefreshFavState()
		{
			Script.GetVideoFavFolders({uid: app.sMid, aid: aid}, function(list){
				obj.favFolders = list || [];
				obj.bFav = obj.__HasFav();
			}, function(){
				Script.GetVideoFavState({aid: aid}, function(data){
					obj.bFav = data && !!data.favoured;
				}, function(){});
			});
		}

		function __HasFav()
		{
			for(var i in favFolders)
			{
				if(Number(favFolders[i].fav_state) === 1)
					return true;
			}
			return false;
		}

		function _Dislike()
		{
			if(bActionBusy) return;
			bDislike = !bDislike;
			dislikeCount = Math.max(0, dislikeCount + (bDislike ? 1 : -1));
			controller._ShowMessage(bDislike ? qsTr("Dislike successful") : qsTr("Cancel dislike"));
		}

		function _Share()
		{
			if(aid === "") return;
			var url = "https://www.bilibili.com/video/" + (bvid !== "" ? bvid : "av" + aid);
			controller._CopyToClipboard(url, qsTr("video link"));
		}

	}

	Image{
		id: previewimage;
		anchors.top: header.bottom;
		anchors.left: parent.left;
		width: app.inPortrait ? parent.width : constants._iMaxWidth;
		height: Util.GetSize(width, 0, "16/9");
		fillMode: Image.PreserveAspectCrop;
		clip: true;
		cache: true;
		sourceSize.width: width;
		source: obj.preview;
		Rectangle{
			anchors.centerIn: parent;
			width: constants._iSizeXXL;
			height: width;
			radius: width / 2;
			color: "#99000000";
			border.width: 2;
			border.color: "#66ffffff";
			visible: obj.aid !== "";
			Image{
				anchors.centerIn: parent;
				width: parent.width * 0.55;
				height: width;
				source: Qt.resolvedUrl("images/icons/" + Util.HandleIconFile("toolbar-mediacontrol-play", true));
				smooth: true;
			}
		}
		MouseArea{
			anchors.fill: parent;
			anchors.margins: constants._iSpacingSuper;
			enabled: obj.aid !== "";
			onClicked: {
				if(obj.aid !== "") obj._PlayOnPage();
				else controller._ShowMessage(qsTr("avId is empty"));
			}
		}
	}

	ButtonRow{
		id: tabrow;
		anchors.top: previewimage.bottom;
		anchors.left: parent.left;
		anchors.right: previewimage.right;
		height: constants._iSizeXL;
		TabButton{
			height: parent.height;
			text: qsTr("Description");
			tab: descview;
		}
		TabButton{
			id: parttab;
			property int num: 0;
			height: parent.height;
			text: qsTr("Videos") + "\n" + num;
			tab: partview;
		}
		TabButton{
			id: recommendtab;
			height: parent.height;
			text: qsTr("Recommend") + (recommendview.count !== 0 ? "\n" + recommendview.count : "");
			tab: recommendview;
			onClicked: {
				if(recommendview.count === 0) obj._GetRecommend();
			}
		}
		TabButton{
			id: commenttab;
			property int num: 0;
			height: parent.height;
			text: qsTr("Comment") + "\n" + num;
			tab: commentitem;
			onClicked: {
				if(commentview.count === 0) obj._GetComment();
			}
		}
	}

	TabGroup{
		id: tabgroup;
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		anchors.left: app.inPortrait ? parent.left : previewimage.right;
		anchors.top: app.inPortrait ? tabrow.bottom : header.bottom;
		currentTab: descview;

		Item{
			id: descview;
			anchors.fill: parent;
			clip: true;
			Row{
				id: up;
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.leftMargin: constants._iSpacingXXL;
				anchors.rightMargin: constants._iSpacingXXL;
				height: constants._iSizeXXL;
				z: 1;
				spacing: constants._iSpacingXXL;
				Image{
					id: avatar;
					anchors.verticalCenter: parent.verticalCenter;
					width: constants._iSizeXL;
					height: width;
					cache: true;
					sourceSize.width: width;
				}
				Column{
					anchors.verticalCenter: parent.verticalCenter;
					width: parent.width - avatar.width - parent.spacing;
					height: avatar.height;
					Text{
						id: unametext;
						width: parent.width;
						height: parent.height / 2;
						verticalAlignment: Text.AlignVCenter;
						font.pixelSize: constants._iFontLarge;
						elide: Text.ElideRight;
						clip: true;
						color: constants._cDarkestColor;
						text: obj.uname;
					}
					Text{
						id: uidtext;
						width: parent.width;
						height: parent.height / 2;
						verticalAlignment: Text.AlignVCenter;
						font.pixelSize: constants._iFontMedium;
						elide: Text.ElideRight;
						clip: true;
						color: constants._cDarkColor;
						text: obj.uid !== "" ? "UID: " + obj.uid : "";
					}
				}
			}
			MouseArea{
				anchors.fill: up;
				enabled: obj.uid !== "";
				onClicked: {
					if(obj.uid !== "") controller._OpenUserPage(obj.uid);
				}
			}

			Flickable{
				id: flick;
				anchors.top: up.bottom;
				anchors.topMargin: constants._iSpacingXXL;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.bottom: parent.bottom;
				contentWidth: width;
				contentHeight: desclayout.height;
				clip: true;
				Column{
					id: desclayout;
					anchors.horizontalCenter: parent.horizontalCenter;
					width: parent.width;
					spacing: constants._iSpacingSmall;
					Text{
						id: titletext;
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width - constants._iSpacingXXL * 2;
						font.pixelSize: constants._iFontXL;
						//elide: Text.ElideRight;
						wrapMode: Text.WrapAnywhere;
						clip: true;
						color: constants._cDarkestColor;
						text: obj.title;
					}
					Row{
						id: infolayout
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width - constants._iSpacingXXL * 2;
						height: constants._iSizeLarge;
						spacing: constants._iSpacingLarge;
						clip: true;
						Repeater{
							id: infolist;
							delegate: Component{
								Row{
									height: infolayout.height;
									spacing: constants._iSpacingSmall;
									clip: true;
									Image{
										anchors.verticalCenter: parent.verticalCenter;
										width: modelData.icon !== undefined && modelData.icon !== "" ? constants._iSizeSmall : 0;
										height: width;
										source: modelData.icon !== undefined && modelData.icon !== "" ? Qt.resolvedUrl("images/icons/" + Util.HandleIconFile(modelData.icon, constants._bInverted)) : "";
										visible: modelData.icon !== undefined && modelData.icon !== "";
										smooth: true;
									}
									Text{
										height: parent.height;
										verticalAlignment: Text.AlignVCenter;
										font.pixelSize: constants._iFontLarge;
										elide: Text.ElideRight;
										font.bold: true;
										color: constants._cDarkerColor;
										text: modelData.name;
									}
									Text{
										height: parent.height;
										verticalAlignment: Text.AlignVCenter;
										font.pixelSize: constants._iFontMedium;
										elide: Text.ElideRight;
										color: constants._cDarkColor;
										text: modelData.value;
									}
								}
							}
						}
					}
					Text{
						id: desc;
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width - constants._iSpacingXXL * 2;
						verticalAlignment: Text.AlignVCenter;
						font.pixelSize: constants._iFontLarge;
						//elide: Text.ElideRight;
						wrapMode: Text.WrapAnywhere;
						clip: true;
						color: constants._cDarkColor;
					}
					Row{
						id: actionlayout;
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width - constants._iSpacingXXL * 2;
						height: constants._iSizeXXL;
						spacing: constants._iSpacingMedium;
						clip: true;
						VideoActionButton{
							id: likeaction;
							width: (parent.width - parent.spacing * 4) / 5;
							sLabel: qsTr("Like");
							sCount: Util.FormatCount(obj.likeCount);
							sIcon: "toolbar-thumb-up";
							bActive: obj.bLike;
							bEnabled: !obj.bActionBusy;
							onClicked: obj._Like();
						}
						VideoActionButton{
							id: dislikeaction;
							width: (parent.width - parent.spacing * 4) / 5;
							sLabel: qsTr("Dislike");
							sCount: Util.FormatCount(obj.dislikeCount);
							sIcon: "toolbar-thumb-down";
							bActive: obj.bDislike;
							bEnabled: !obj.bActionBusy;
							onClicked: obj._Dislike();
						}
						VideoActionButton{
							id: coinaction;
							width: (parent.width - parent.spacing * 4) / 5;
							sLabel: qsTr("Coin");
							sCount: Util.FormatCount(obj.coinCount);
							sIcon: "toolbar-coin";
							bActive: obj.bCoin;
							bEnabled: !obj.bActionBusy;
							onClicked: obj._Coin();
						}
						VideoActionButton{
							id: favaction;
							width: (parent.width - parent.spacing * 4) / 5;
							sLabel: qsTr("Favorite");
							sCount: Util.FormatCount(obj.favCount);
							sIcon: "toolbar-favorite-star";
							bActive: obj.bFav;
							bEnabled: !obj.bActionBusy;
							onClicked: obj._Fav();
						}
						VideoActionButton{
							id: shareaction;
							width: (parent.width - parent.spacing * 4) / 5;
							sLabel: qsTr("Share");
							sCount: Util.FormatCount(obj.shareCount);
							sIcon: "toolbar-share";
							bActive: false;
							bEnabled: obj.aid !== "";
							onClicked: obj._Share();
						}
					}
				}
			}
			ScrollDecorator{
				flickableItem: flick;
			}
		}

		PartListWidget{
			id: partview;
			anchors.fill: parent;
			onRefresh: {
				obj._GetParts();
			}
			onClicked: {
				obj._Play(index, cid);
			}
		}

		VideoListWidget{
			id: recommendview;
			anchors.fill: parent;
			onRefresh: {
				obj._GetRecommend();
			}
		}

		Item{
			id: commentitem;
			anchors.fill: parent;
			TypeRowWidget{
				id: typerow;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.top: parent.top;
				sText: "sort";
				aOptions: [
					{
						name: qsTr("New"),
						value: "0",
					},
					{
						name: qsTr("Hot"),
						value: "2",
					},
				]
				vCurrentValue: "";
				onSelected: {
					obj.order = value;
					obj._GetComment();
				}
			}
			CommentListWidget{
				id: commentview;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.top: typerow.bottom;
				anchors.bottom: parent.bottom;
				bHasMore: obj.pageNo < obj.pageCount;
				aid: obj.aid;
				onRefresh: {
					obj._GetComment();
				}
				onMore: {
					obj._GetComment(constants._sNextPage);
				}
			}
		}
	}

	PlayerLoader{
		id: loader;
		property int __duration: 250;
		state: constants._sHideState;
		transform: [
			Rotation {
				id: rot;
				origin: Qt.vector3d(app.width / 2, app.height / 2, 0);
				axis: Qt.vector3d(0, 0, 1);
				angle: 0;
			}
		]
		states: [
			State{
				name: constants._sHideState;
				PropertyChanges{
					target: root;
					bFull: false;
					bLock: false;
				}
				PropertyChanges{
					target: loader;
					width: previewimage.width;
					height: previewimage.height;
					z: 10;
				}
				AnchorChanges{
					target: loader;
					anchors.verticalCenter: previewimage.verticalCenter;
					anchors.horizontalCenter: previewimage.horizontalCenter;
				}
				PropertyChanges{
					target: rot;
					angle: 0;
				}
			},
			State{
				name: constants._sShowState;
				PropertyChanges{
					target: root;
					bFull: true;
					bLock: true;
				}
				PropertyChanges{
					target: loader;
					width: app.width;
					height: app.height;
					z: header.z + 100;
				}
				AnchorChanges{
					target: loader;
					anchors.verticalCenter: root.verticalCenter;
					anchors.horizontalCenter: root.horizontalCenter;
				}
				PropertyChanges{
					target: rot;
					angle: app.inPortrait ? 90 : 0;
				}
			}
		]

		transitions: [
			Transition{
				ParallelAnimation{
					NumberAnimation{
						target: loader;
						properties: "width,height,z";
						duration: loader.__duration;
					}
					AnchorAnimation{
						duration: loader.__duration;
					}
					RotationAnimation{
						duration: loader.__duration;
					}
				}
			}
		]
		onExit: {
			__Toggle(false);
		}
		onMenu: {
			__Toggle();
		}
		function __Toggle(on)
		{
			if(on === undefined)
			{
				state = state === constants._sShowState ? constants._sHideState : constants._sShowState;
			}
			else
			{
				if(on) state = constants._sShowState;
				else state = constants._sHideState;
			}
		}
	}
	Connections{
		target: app;
		onBLoginChanged: {
			if(!app.bLogin) obj._ResetActionStates();
			else if(obj.aid !== "") obj._GetActionStates();
		}
	}
	Timer{
		id: favsynctimer;
		interval: 1500;
		repeat: false;
		running: false;
		onTriggered: {
			if(obj.aid !== "")
			{
				obj._RefreshFavState();
				obj._RefreshFavCount();
			}
		}
	}
	onStatusChanged: {
		if(status === PageStatus.Deactivating)
		{
			loader._DeInit();
		}
		else if(status === PageStatus.Active)
		{
			if(obj.aid !== "") obj._GetActionStates();
		}
	}

	Component.onDestruction: {
		loader._DeInit();
	}
}
