import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import "component"
import "../js/main.js" as Script
import "../js/main.js" as Util

PageStackWindow {
	id: app;

	property int iStatusBarHeight: __statusBarHeight; // private property
	property int __noneDevMenuCount: 5;
	property bool bLogin: false;
	property string sUname: "";
	property string sFace: "";
	property string sMid: "";
	property int iLevel: 0;
	property real fCoins: 0;
	property int iFollowing: 0;
	property int iFollower: 0;
	property variant __preloadQueue: [];

	objectName: "idMainWindow";
	showStatusBar: inPortrait && (pageStack.currentPage && !pageStack.currentPage.bFull);
	showToolBar: false;
	platformStyle: PageStackWindowStyle {
		cornersVisible: app.inPortrait && !settings.bFullscreen;
	}
	initialPage: 
	MainPage
	//PlayerPage
	{
		id: mainpage
	}

	Connections{
		target: _UT;
		onHasUpdate: {
			var texts = [];
			var updates = _UT.Changelog().CHANGES;
			for(var i in updates)
			{
				texts.push({
					text: updates[i],
				});
			}
			controller._Info(
				qsTr("Info"),
				qsTr("Version") + ": " + version,
				texts,
				undefined,
				function(link){
					eval(link);
				}
			);
		}
	}

	Binding{
		target: theme;
		property: "inverted";
		value: constants._bInverted;
	}

	Constants{
		id: constants;
	}

	SettingsObject{
		id: settings;
	}

	Controller{
		id: controller;
	}

	MenuWidget{
		id: menu;
		anchors.fill: parent;
		anchors.topMargin: iStatusBarHeight;
		bLogin: app.bLogin;
		sUname: app.sUname;
		sFace: app.sFace;
		sMid: app.sMid;
		iLevel: app.iLevel;
		fCoins: app.fCoins;
		iFollowing: app.iFollowing;
		iFollower: app.iFollower;
		tools: [
			LocalToolIcon{
				iconId: "toolbar-power";
				inverted: constants._bInverted;
				onClicked: Qt.quit();
			},
			LocalToolIcon{
				iconId: "toolbar-back";
				inverted: constants._bInverted;
				visible: pageStack.depth > 1;
				onClicked: {
					menu._Toggle(false);
					if(pageStack.depth > 1)
					{
						var p = pageStack.currentPage;
						if(typeof(p._DeInit() === "function")) p._DeInit();
						pageStack.pop();
					}
				}
			}
		]
		onLoginRequested: {
			menu._Toggle(false);
			controller._OpenLoginPage();
		}
		onProfileRequested: {
			menu._Toggle(false);
			if(app.sMid !== "") controller._OpenUserPage(app.sMid);
		}
		onLogoutRequested: {
			menu._Toggle(false);
			app._Logout();
		}
	}

	InfoBanner{
		id: infobanner;
		topMargin: (app.showStatusBar ? iStatusBarHeight : 0) + constants._iSpacingLarge;
		leftMargin: constants._iSpacingMedium;
		z: constants._iMaxZ;
		function _ShowMessage(text)
		{
			infobanner.text = text;
			infobanner.show();
		}
	}

	Timer{
		id: preloadTimer;
		interval: 1;
		repeat: false;
		running: false;
		onTriggered: {
			controller._PreloadPages(__preloadQueue.splice(0, 4));
			if(__preloadQueue.length > 0)
				preloadTimer.start();
		}
	}

	Rectangle{
		id: statusbar;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		height: iStatusBarHeight;
		z: Number.MAX_VALUE;
		color: constants._cGlobalColor;
		opacity: 0.4;
		visible: app.showStatusBar && (_UT.dev !== 0 || settings.bFullscreen);
	}
	function _RestoreLogin()
	{
		bLogin = _UT.GetSetting("account/login");
		sUname = _UT.GetSetting("account/uname").toString();
		sFace = _UT.GetSetting("account/face").toString();
		sMid = _UT.GetSetting("account/mid").toString();
		iLevel = Number(_UT.GetSetting("account/level"));
		fCoins = Number(_UT.GetSetting("account/coins"));
		iFollowing = Number(_UT.GetSetting("account/following"));
		iFollower = Number(_UT.GetSetting("account/follower"));
	}

	function _SetLogin(data)
	{
		bLogin = true;
		sUname = data.uname || "";
		sFace = data.face || "";
		sMid = data.mid !== undefined ? data.mid.toString() : "";
		iLevel = Number(data.level || 0);
		fCoins = Number(data.coins !== undefined ? data.coins : 0);
		iFollowing = Number(data.following || 0);
		iFollower = Number(data.follower || 0);

		_UT.SetSetting("account/login", true);
		_UT.SetSetting("account/uname", sUname);
		_UT.SetSetting("account/face", sFace);
		_UT.SetSetting("account/mid", sMid);
		_UT.SetSetting("account/level", iLevel);
		_UT.SetSetting("account/coins", fCoins);
		_UT.SetSetting("account/following", iFollowing);
		_UT.SetSetting("account/follower", iFollower);
		_UT.DumpCookies();
	}

	function _ClearLogin()
	{
		bLogin = false;
		sUname = "";
		sFace = "";
		sMid = "";
		iLevel = 0;
		fCoins = 0;
		iFollowing = 0;
		iFollower = 0;

		_UT.SetSetting("account/login", false);
		_UT.SetSetting("account/uname", "");
		_UT.SetSetting("account/face", "");
		_UT.SetSetting("account/mid", "");
		_UT.SetSetting("account/level", 0);
		_UT.SetSetting("account/coins", 0);
		_UT.SetSetting("account/following", 0);
		_UT.SetSetting("account/follower", 0);
	}

	function _RefreshLogin()
	{
		Script.RefreshLoginStatus(
			function(data){
				_SetLogin(data);
			},
			function(err){
				if(err === "logout")
				{
					if(bLogin) _UT.ClearCookies();
					_ClearLogin();
					return;
				}
			}
		);
	}

	function _Logout()
	{
		controller._Query(
			qsTr("WARNING"),
			qsTr("Logout Bilibili account?"),
			qsTr("Logout"), qsTr("Cancel"),
			function(){
				Script.Logout(
					function(){
						_ClearLogin();
						_UT.ClearCookies();
					},
					function(){
						_ClearLogin();
						_UT.ClearCookies();
					}
				);
			}
		);
	}

	function __Dev()
	{
		if(_UT.dev !== 0)
		{
			Util.ModelPush(menu.model, {
				label: "TEST",
				name: "Test",
				icon: "jump-to",
				func: "controller.__Test();",
			});
			Util.ModelPush(menu.model, {
				label: "Test request",
				name: "TestRequest",
				icon: "share",
				func: "controller._OpenTestRequestPage();",
			});
			Util.ModelPush(menu.model, {
				label: "Test video",
				name: "TestVideo",
				icon: "mediacontrol-play",
				func: "controller._OpenTestVideoPage();",
			});
		}
		else
		{
			while(Util.ModelSize(menu.model) > app.__noneDevMenuCount) Util.ModelRemove(menu.model, app.__noneDevMenuCount);
		}
	}

	Component.onCompleted: {
		Util.ModelPush(menu.model, {
			label: qsTr("Browser"),
			name: "Browser",
			icon: "pages-all",
			func: "controller._OpenUrl(undefined, 0);",
		});
		Util.ModelPush(menu.model, {
			label: qsTr("Favorites"),
			name: "Fav",
			icon: "favorite-mark",
			func: "controller._OpenFavPage();",
		});
		Util.ModelPush(menu.model, {
			label: qsTr("View history"),
			name: "History",
			icon: "directory",
			func: "controller._OpenHistoryPage();",
		});
		Util.ModelPush(menu.model, {
			label: qsTr("Setting"),
			name: "Setting",
			icon: "settings",
			func: "controller._OpenSettingPage();",
		});
		Util.ModelPush(menu.model, {
			label: qsTr("About"),
			name: "About",
			icon: "application",
			func: "controller._OpenAboutPage();",
		});

		__Dev();

		_UT.CheckUpdate();

		Script.Init(_UT);
		_RestoreLogin();
		_RefreshLogin();
		__preloadQueue = [
			"SettingPage",
			"SearchPage",
			"ResultPage",
			"BrowserPage",
			"UserPage",
			"LoginPage",
			"CategoryPage",
			"HistoryPage",
			"FavPage",
			"FavDetailPage",
			"RankingPage",
			"DetailPage",
			"ArticlePage",
			"AboutPage",
			"BangumiPage",
			"BangumiDetailPage",
			"LivePage",
			"LiveDetailPage",
			"PlayerPage",
			"component/VideoPlayer"
		];
		preloadTimer.start();
	}
}
