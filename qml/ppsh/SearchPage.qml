import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;

	sTitle: qsTr("Search");
	objectName: "idSearchPage";

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
				bListenTextChanged: true;
				sPlaceholder: qsTr("Search videos / UPs / av / BV");
				sActionKeyLabel: qsTr("Search");
				onSearch: {
					obj._Search();
				}
				onTextChanged: {
					obj._OnInput(text);
				}
				onCleared: {
					obj._OnInput("");
				}
			}
		}
	}

	function _Init()
	{
		if(input.sText.trim() !== "")
			obj._ShowSuggest(input.sText);
		else
			obj._ShowHome();
	}

	QtObject{
		id: obj;
		property int __suggestSeq: 0;

		function _GetKeywordHistory()
		{
			Util.ModelClear(view.model);
			Script.GetKeywordHistory(view.model);
		}

		function _RemoveHistory(kw)
		{
			Script.RemoveKeywordHistory(kw);
			_GetKeywordHistory();
		}

		function _ClearHistory()
		{
			Script.RemoveKeywordHistory();
			_GetKeywordHistory();
			controller._ShowMessage(qsTr("Search history cleared"));
		}

		function _GetDefaultKeyword()
		{
			var seq = ++__suggestSeq;
			Util.ModelClear(hotrepeater.model);

			var tmp = [];
			var d = {
				model: tmp,
				limit: 12,
			};

			var s = function(){
				if(seq === __suggestSeq)
					Util.ModelCopy(hotrepeater.model, tmp);
			};
			var f = function(err){
				if(seq === __suggestSeq)
					controller._ShowMessage(err);
			};

			Script.GetDefaultKeyword(d, s, f);
		}

		function _GetSuggest(kw)
		{
			var seq = ++__suggestSeq;
			var keyword = kw === undefined ? input.sText : kw;
			Util.ModelClear(hotrepeater.model);
			if(keyword.trim() === "") return;

			var tmp = [];
			var d = {
				model: tmp,
				keyword: keyword,
				limit: 12,
			};

			var s = function(){
				if(seq === __suggestSeq)
					Util.ModelCopy(hotrepeater.model, tmp);
			};
			var f = function(err){
				if(seq === __suggestSeq)
					if(_UT.dev !== 0) console.log("Search suggest: " + err);
			};

			Script.GetSearchSuggest(d, s, f);
		}

		function _ShowHome()
		{
			__suggestSeq++;
			hotlabel.sText = qsTr("Hot keyword");
			historylabel.visible = true;
			view.visible = true;
			_GetDefaultKeyword();
			_GetKeywordHistory();
		}

		function _ShowSuggest(kw)
		{
			__suggestSeq++;
			hotlabel.sText = qsTr("Related search");
			historylabel.visible = false;
			view.visible = false;
			suggestTimer.restart();
		}

		function _OnInput(text)
		{
			if(text === undefined || text.trim() === "")
				_ShowHome();
			else
				_ShowSuggest(text);
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

		function _Search(kw)
		{
			if(kw !== undefined && kw !== null)
				input.sText = kw;
			suggestTimer.stop();
			__suggestSeq++;

			var keyword = input.sText.trim();
			if(keyword === "")
			{
				controller._ShowMessage(qsTr("Please input keyword"));
				return;
			}

			Script.AddKeywordHistory(keyword);
			_GetKeywordHistory();

			if(_IsAvBv(keyword))
			{
				_OpenAvBv(keyword);
				return;
			}

			input._MakeBlur();
			controller._OpenResultPage(keyword, true);
		}
	}

	SectionWidget{
		id: hotlabel;
		anchors.top: header.bottom;
		anchors.left: parent.left;
		width: parent.width;
		sText: qsTr("Hot keyword");
		onClicked: {
			obj._ShowHome();
		}
	}

	Flow{
		id: hot;
		anchors.top: hotlabel.bottom;
		anchors.left: parent.left;
		width: parent.width;
		Repeater{
			id: hotrepeater;
			model: ListModel{}
			delegate: Component{
				Item{
					width: hotkeyword.paintedWidth + constants._iSpacingMedium * 2;
					height: constants._iSizeLarge;
					clip: true;
					Text{
						id: hotkeyword;
						anchors.horizontalCenter: parent.horizontalCenter;
						height: parent.height;
						verticalAlignment: Text.AlignVCenter;
						font.pixelSize: constants._iFontXL;
						text: model.keyword;
						color: constants._cDarkerColor;
					}
					MouseArea{
						anchors.fill: parent;
						onClicked: {
							obj._Search(model.keyword);
						}
					}
				}
			}
		}
	}

	SectionWidget{
		id: historylabel;
		anchors.top: hot.bottom;
		anchors.left: parent.left;
		width: parent.width;
		sText: qsTr("Search history") + "[" + view.count + "]";
		onClicked: {
			obj._GetKeywordHistory();
		}
		LocalToolIcon{
			anchors.right: parent.right;
			anchors.rightMargin: constants._iSpacingLarge;
			anchors.verticalCenter: parent.verticalCenter;
			width: height;
			height: constants._iSizeLarge;
			z: 1;
			iconId: "toolbar-close";
			inverted: constants._bInverted;
			enabled: view.count > 0;
			visible: enabled;
			onClicked: {
				obj._ClearHistory();
			}
		}
	}

	GridView{
		id: view;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: historylabel.bottom;
		anchors.bottom: parent.bottom;
		clip: true;
		cacheBuffer: 320;
		model: ListModel{}
		cellWidth: width / 2;
		cellHeight: constants._iSizeLarge;
		delegate: Component{
			Item{
				width: GridView.view.cellWidth;
				height: GridView.view.cellHeight;
				clip: true;
				Text{
					anchors.fill: parent;
					anchors.leftMargin: constants._iSpacingLarge;
					anchors.rightMargin: constants._iSpacingLarge;
					verticalAlignment: Text.AlignVCenter;
					font.pixelSize: constants._iFontXL;
					text: model.keyword;
					elide: Text.ElideRight;
					color: constants._cDarkerColor;
				}
				MouseArea{
					anchors.fill: parent;
					onClicked: {
						obj._Search(model.keyword);
					}
					onPressAndHold: {
						obj._RemoveHistory(model.keyword);
					}
				}
			}
		}
	}

	Timer{
		id: suggestTimer;
		interval: 250;
		repeat: false;
		onTriggered: {
			obj._GetSuggest(input.sText);
		}
	}

	ScrollDecorator{
		flickableItem: view;
	}
}
