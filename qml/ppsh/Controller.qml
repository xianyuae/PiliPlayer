import QtQuick 1.1
import "../js/util.js" as Util

QtObject {
	id: root;

	objectName: "idControllerObject";
	property variant __queryDialog: null;
	property variant __selectionDialog: null;
	property variant __infoDialog: null;
	property variant __pageComponents: ({});

	function _Component(name)
	{
		var c = __pageComponents[name];
		if(c)
			return c;

		c = Qt.createComponent(Qt.resolvedUrl(name + ".qml"));
		if(c && c.status === Component.Ready)
		{
			__pageComponents[name] = c;
			return c;
		}

		if(c && c.status === Component.Error)
			console.log("Component load error: " + name + " -> " + c.errorString());
		return c;
	}

	function _PreloadPages(names)
	{
		var list = names || [];
		for(var i in list)
			_Component(list[i]);
	}

	// page
	function _OpenSettingPage(im)
	{
		if(_IsCurrentPage("Setting")) return;
		var page = _Component("SettingPage");
		pageStack.push(page, undefined, im);
	}

	function _OpenSearchPage(im)
	{
		if(_IsCurrentPage("Search")) return;
		var page = _Component("SearchPage");
		var p = pageStack.push(page, undefined, im);
		p._Init();
	}

	function _OpenResultPage(kw, im)
	{
		if(_IsCurrentPage("Result")) return;
		var page = _Component("ResultPage");
		var p = pageStack.push(page, undefined, im);
		p._Init(kw);
	}

	function _OpenUrl(url, type, im)
	{
		var t = type === undefined ? settings.iDefaultBrowser : type;
		if(t == 0)
		{
			//if(_IsCurrentPage("Browser")) return;
			var page = _Component("BrowserPage");
			var p= pageStack.push(page, undefined, im);
			p._Init(url);
		}
		else Qt.openUrlExternally(url);
	}

	function _OpenUserPage(uid, im)
	{
		if(_IsCurrentPage("User")) return;
		var page = _Component("UserPage");
		var p = pageStack.push(page, undefined, im);
		p._Init(uid);
	}

	function _OpenLoginPage(im)
	{
		if(_IsCurrentPage("Login")) return;
		var page = _Component("LoginPage");
		var p = pageStack.push(page, undefined, im);
		p._Init();
	}

	function _OpenCategoryPage(im)
	{
		if(_IsCurrentPage("Category")) return;
		var page = _Component("CategoryPage");
		var p = pageStack.push(page, undefined, im);
		p._Init();
	}

	function _OpenHistoryPage(im)
	{
		if(_IsCurrentPage("History")) return;
		var page = _Component("HistoryPage");
		var p = pageStack.push(page, undefined, im);
		//p._Init();
	}

	function _OpenFavPage(im)
	{
		if(_IsCurrentPage("Fav")) return;
		if(!app.bLogin)
		{
			_ShowMessage(qsTr("Please login first"));
			_OpenLoginPage(im);
			return;
		}
		var page = _Component("FavPage");
		var p = pageStack.push(page, undefined, im);
		p._Init();
	}

	function _OpenFavDetailPage(id, title, im)
	{
		if(_IsCurrentPage("FavDetail")) return;
		var page = _Component("FavDetailPage");
		var p = pageStack.push(page, undefined, im);
		p._Init(id, title);
	}

	function _OpenRankingPage(im)
	{
		if(_IsCurrentPage("Ranking")) return;
		var page = _Component("RankingPage");
		var p = pageStack.push(page, undefined, im);
		p._Init();
	}

	function _OpenDetailPage(aid, im)
	{
		var page = _Component("DetailPage");
		var p = pageStack.push(page, undefined, im);
		p._Init(aid);
	}

	function _OpenArticlePage(aid, im)
	{
		var page = _Component("ArticlePage");
		var p = pageStack.push(page, undefined, im);
		p._Init(aid);
	}

	function _OpenAboutPage(im)
	{
		if(_IsCurrentPage("About")) return;
		var page = _Component("AboutPage");
		pageStack.push(page, undefined, im);
	}

	function _OpenBangumiPage(im)
	{
		if(_IsCurrentPage("Bangumi")) return;
		var page = _Component("BangumiPage");
		var p = pageStack.push(page, undefined, im);
		p._Init();
	}

	function _OpenBangumiDetailPage(mid, im)
	{
		//if(_IsCurrentPage("BangumiDetail")) return;
		var page = _Component("BangumiDetailPage");
		var p = pageStack.push(page, undefined, im);
		p._Init(mid);
	}

	function _OpenLivePage(im)
	{
		//if(_IsCurrentPage("Live")) return;
		var page = _Component("LivePage");
		var p = pageStack.push(page, undefined, im);
		p._Init();
	}

	function _OpenLiveDetailPage(rid, im)
	{
		//if(_IsCurrentPage("LiveDetail")) return;
		var page = _Component("LiveDetailPage");
		var p = pageStack.push(page, undefined, im);
		p._Init(rid);
	}

	function _OpenPlayer(aid, contents, index, player, type)
	{
		var cids = [];
		Util.ModelForeach(contents, function(e, i){
			cids.push({
				aid: e.aid || aid,
				bvid: e.bvid || "",
				cid: e.cid,
				epid: e.epid || "",
				name: e.name,
			});
		});
		player._Init(aid, cids, index, type);
	}

	function _OpenPlayerPage(aid, type)
	{
		if(_IsCurrentPage("Player")) return;
		var page = _Component("PlayerPage");
		var p = pageStack.push(page, undefined, true);
		p._Init(aid, type);
	}

	// hide
	function __Test(data)
	{
		if(_UT.dev === 0)
		{
			_ShowMessage("Only for developer");
			return;
		}

		_OpenPlayerPage("14266370");
	}

	function _OpenTestRequestPage(im)
	{
		if(_IsCurrentPage("TestRequest")) return;
		var page = _Component("test/TestRequestPage");
		pageStack.push(page, undefined, im);
	}

	function _OpenTestVideoPage(im)
	{
		if(_IsCurrentPage("TestVideo")) return;
		var page = _Component("test/TestVideoPage");
		pageStack.push(page, undefined, im);
	}

	// util
	function _ShowMessage(msg)
	{
		if(_UT.dev !== 0) console.log(msg);
		infobanner._ShowMessage(msg);
	}

	function _CopyToClipboard(text, name)
	{
		_UT.CopyToClipboard(text);
		_ShowMessage(qsTr("Copy %1 to clipboard successful").arg(name ? name : qsTr("data")));
		if(_UT.dev !== 0) console.log("Copy data -> " + text);
	}

	function _Query(title, message, acceptText, rejectText, acceptCallback, rejectCallback)
	{
		if(!__queryDialog)
		{
			__queryDialog = Qt.createComponent("component/DynamicQueryDialog.qml");
		}
		var msg = Array.isArray(message) ? message.join("\n") : message;
		var prop = {
			titleText: title,
			message: msg + "\n",
			acceptButtonText: acceptText,
			rejectButtonText: rejectText
		};
		var diag = __queryDialog.createObject(pageStack.currentPage, prop);
		if(typeof(acceptCallback) === "function") diag.accepted.connect(acceptCallback);
		if(typeof(rejectCallback) === "function") diag.rejected.connect(rejectCallback);

		return diag;
	}

	function _Info(title, subtitle, content, bottomtitle, handlelink, refresh, footer)
	{
		if(!__infoDialog)
		{
			__infoDialog = Qt.createComponent("component/InfoDialog.qml");
		}
		var prop = {
			titleText: title,
			sTitle: subtitle,
			aTexts: content,
			sBottomTitle: bottomtitle || "",
		};
		var diag = __infoDialog.createObject(pageStack.currentPage, prop);
		if(typeof(handlelink) === "function") diag.linkClicked.connect(handlelink);
		if(typeof(refresh) === "function") diag.clicked.connect(refresh);
		if(typeof(footer) === "function") diag.footerClicked.connect(footer);

		return diag;
	}

	function _Select(title, model, selection_func, field, cur_selected)
	{
		if(!__selectionDialog)
		{
			__selectionDialog = Qt.createComponent("component/DynamicSelectionDialog.qml");
		}
		var prop = {
			titleText: title,
			sField: field || "",
			model: model, // QStringList | JS string array => modelData
			selectedIndex: cur_selected,
		};
		var diag = __selectionDialog.createObject(pageStack.currentPage, prop);
		if(typeof(selection_func) === "function") diag.select.connect(selection_func);

		return diag;
	}

	function _IsCurrentPage(name)
	{
		return(pageStack && pageStack.currentPage.objectName === "id" + name + "Page");
	}
}
