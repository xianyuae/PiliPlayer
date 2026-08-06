import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;

	sTitle: qsTr("Search Result");
	objectName: "idResultPage";
	property variant aSearchTypes: [
		{
			name: qsTr("Video"),
			value: "video",
			order: [
				{
					name: qsTr("Default"),
					value: "",
				},
				{
					name: qsTr("Most play"),
					value: "click",
				},
				{
					name: qsTr("Newest"),
					value: "pubdate",
				},
				{
					name: qsTr("Most danmaku"),
					value: "dm",
				},
				{
					name: qsTr("Most favorite"),
					value: "stow",
				},
			],
		},
		{
			name: qsTr("Bangumi"),
			value: "media_bangumi",
			order: [
				{
					name: qsTr("Default"),
					value: "",
				},
			],
		},
		{
			name: qsTr("UP"),
			value: "bili_user",
			order: [
				{
					name: qsTr("Default"),
					value: "",
				},
				{
					name: qsTr("Most fans"),
					value: "fans",
				},
				{
					name: qsTr("Level"),
					value: "level",
				},
			],
		},
		{
			name: qsTr("Article"),
			value: "article",
			order: [
				{
					name: qsTr("Default"),
					value: "",
				},
				{
					name: qsTr("Newest"),
					value: "pubdate",
				},
				{
					name: qsTr("Most read"),
					value: "click",
				},
				{
					name: qsTr("Most like"),
					value: "attention",
				},
				{
					name: qsTr("Most reply"),
					value: "scores",
				},
			],
		},
		{
			name: qsTr("Live"),
			value: "live",
			order: [
				{
					name: qsTr("Living"),
					value: "online",
				},
				{
					name: qsTr("Default"),
					value: "",
				},
			],
		},
	];

	Header{
		id: header;
		Row{
			anchors.fill: parent;
			clip: true;
			spacing: constants._iSpacingSmall;
			LocalToolIcon{
				id: back;
				anchors.verticalCenter: parent.verticalCenter;
				iconId: "toolbar-back";
				onClicked: pageStack.pop();
			}
			SearchWidget{
				id: input;
				anchors.verticalCenter: parent.verticalCenter;
				width: parent.width - parent.spacing - back.width;
				bListenTextChanged: false;
				sPlaceholder: qsTr("Search videos / UPs / av / BV");
				sActionKeyLabel: qsTr("Search");
				onSearch: {
					Script.AddKeywordHistory(input.sText.trim());
					obj._SearchResult();
				}
			}
		}
	}

	function _Init(kw)
	{
		if(kw)
			obj._SearchResult(kw);
	}

	QtObject{
		id: obj;
		property string keyword;
		property string type;
		property int pageNo: 1;
		property int pageSize: 20;
		property int pageCount: 0;
		property int totalCount: 0;
		property string order: "";

		function _SetType(t, i)
		{
			if(type == t) return;

			type = t;
			var orders = [];
			Util.ModelCopy(orders, Util.ModelGetValue(typeview.model, i, "order"));
			typerow.aOptions = orders;
			typerow.vCurrentValue = Util.ModelGetValue(typerow.aOptions, 0, "value");
			order = typerow.vCurrentValue;

			pageNo = 1;
			pageSize = 20;
			pageCount = 0;
			totalCount = 0;
		}

		function _IsAvBv(kw)
		{
			var s = kw.toLowerCase();
			if(s.indexOf("av") === 0)
				return /^\d+$/.test(s.substring(2));
			if(s.indexOf("bv") === 0)
				return /^[0-9a-z]{10}$/.test(s.substring(2));
			return false;
		}

		function _OpenAvBv(kw)
		{
			var s = kw.toLowerCase();
			var aid = s.indexOf("av") === 0 ? kw.substring(2) : kw.toUpperCase();
			root.bBusy = true;

			var d = {
				model: [],
				aid: aid,
			};
			var suc = function(data){
				root.bBusy = false;
				Script.AddViewHistory(data.aid, data.title, data.preview, data.up, constants._eVideoType);
				input._MakeBlur();
				controller._OpenDetailPage(data.bvid || data.aid);
			};
			var fail = function(err){
				root.bBusy = false;
				controller._ShowMessage(err);
			};

			Script.GetVideoDetail(d, suc, fail);
		}

		function _SearchResult(kw, p)
		{
			if(kw)
				input.sText = kw;

			if(input.sText.trim() !== keyword)
			{
				keyword = input.sText.trim();
				typerow.iCurrentIndex = 0;
				order = typerow.aOptions[0].value;
			}
			if(keyword == "") return;

			if(_IsAvBv(keyword))
			{
				_OpenAvBv(keyword);
				return;
			}

			root.bBusy = true;

			var pn;
			if(typeof(p) === "number") pn = p;
			else if(p === constants._sNextPage) pn = pageNo + 1;
			else if(p === constants._sPrevPage) pn = pageNo - 1;
			else if(p === constants._sThisPage) pn = pageNo;
			else pn = 1;
			var d = {
				keyword: keyword,
				model: view.model,
				pageNo: pn,
				type: type,
				order: order,
			};

			if(p === undefined)
			{
				pageNo = 1;
				pageSize = 20;
				pageCount = 0;
				totalCount = 0;
			}
			Util.ModelClear(view.model);

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

			Script.SearchKeyword(d, s, f);
		}
	}

	TabListWidget{
		id: typeview;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: header.bottom;
		height: constants._iSizeXL;
		bTabMode: true;
		onClicked: {
			obj._SetType(value, index);
			obj._SearchResult(obj.keyword);
		}
	}
	TypeRowWidget{
		id: typerow;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: typeview.bottom;
		sText: qsTr("Order");
		onSelected: {
			obj.order = value;
			obj._SearchResult(obj.keyword);
		}
	}

	ResultListWidget{
		id: view;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: typerow.bottom;
		anchors.bottom: parent.bottom;
		onRefresh: {
			obj._SearchResult(obj.keyword, constants._sThisPage);
		}
	}

	PagedWidget{
		anchors.bottom: parent.bottom;
		anchors.horizontalCenter: parent.horizontalCenter;
		pageNo: obj.pageNo;
		pageSize: obj.pageSize;
		pageCount: obj.pageCount;
		totalCount: obj.totalCount;
		onPrev: {
			obj._SearchResult(obj.keyword, constants._sPrevPage);
		}
		onNext: {
			obj._SearchResult(obj.keyword, constants._sNextPage);
		}
	}

	Component.onCompleted: {
		typeview._LoadModel(aSearchTypes);
		obj._SetType(Util.ModelGetValue(typeview.model, 0, "value"), 0);
	}
}
