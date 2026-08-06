import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "../js/main.js" as Script

BasePage {
	id: root;

	sTitle: qsTr("Login");
	objectName: "idLoginPage";

	function _Init()
	{
		obj._Load();
	}

	QtObject{
		id: obj;
		property bool checking: false;
		property bool polling: false;
		property string qrcodeKey: "";
		property string mode: "qr";
		property string sStatus: "正在生成二维码";

		function _Load()
		{
			qrtimer.stop();
			mode = "qr";
			sStatus = "正在生成二维码";
			root.bBusy = true;
			Script.GetLoginQrcode(
				function(data){
					root.bBusy = false;
					qrcodeKey = data.qrcode_key || "";
					var path = "";
					try
					{
						var dataUrl = Script.MakeQrcodeDataUrl(data.url || "");
						path = _UT.SaveDataUrl(dataUrl);
					}
					catch(e)
					{
						sStatus = e.toString();
						return;
					}
					if(path == "")
					{
						sStatus = "二维码生成失败";
						return;
					}
					qrimage.source = "";
					qrimage.source = path;
					sStatus = "等待扫码";
					if(mode === "qr")
					{
						qrtimer.start();
					}
				},
				function(err){
					root.bBusy = false;
					sStatus = err;
				}
			);
		}

		function _ToggleMode()
		{
			if(mode === "qr")
			{
				qrtimer.stop();
				mode = "cookie";
			}
			else
			{
				mode = "qr";
				if(qrcodeKey == "")
				{
					_Load();
				}
				else
				{
					qrtimer.start();
				}
			}
		}

		function _CookieLogin()
		{
			var sessdata = sessdataField.text.trim();
			if(sessdata == "")
			{
				controller._ShowMessage("请输入 SESSDATA");
				return;
			}
			if(sessdata.indexOf("SESSDATA=") === 0)
				sessdata = sessdata.substring(9);
			var cookies = {};
			cookies["SESSDATA"] = sessdata;
			var bilijct = bilijctField.text.trim();
			if(bilijct.indexOf("bili_jct=") === 0)
				bilijct = bilijct.substring(9);
			if(bilijct != "")
				cookies["bili_jct"] = bilijct;
			_UT.SetBilibiliCookies(cookies);
			_CheckLogin();
		}

		function _Poll()
		{
			if(qrcodeKey == "" || polling) return;
			polling = true;
			Script.GetLoginQrcodeStatus(
				qrcodeKey,
				function(data){
					polling = false;
					if(mode !== "qr") return;
					var code = data.code !== undefined ? data.code : -1;
					if(code === 0)
					{
						qrtimer.stop();
						_CheckLogin();
					}
					else if(code === 86101)
					{
						sStatus = "等待扫码";
					}
					else if(code === 86090)
					{
						sStatus = "已扫码，请在手机上确认";
					}
					else if(code === 86038)
					{
						sStatus = "二维码已过期";
						_Load();
					}
				},
				function(err){
					polling = false;
					if(mode !== "qr") return;
					qrtimer.stop();
					sStatus = err;
				}
			);
		}

		function _CheckLogin()
		{
			if(checking) return;
			checking = true;
			root.bBusy = true;
			Script.RefreshLoginStatus(
				function(data){
					checking = false;
					root.bBusy = false;
					if(data && data.bLogin)
					{
						qrtimer.stop();
						app._SetLogin(data);
						controller._ShowMessage(qsTr("Login successful"));
						pageStack.pop();
					}
					else
						controller._ShowMessage(qsTr("Not logged in yet"));
				},
				function(err){
					checking = false;
					root.bBusy = false;
					if(err === "logout")
						controller._ShowMessage(qsTr("Not logged in yet"));
					else
						controller._ShowMessage(err);
				}
			);
		}
	}

	Timer{
		id: qrtimer;
		interval: 2000;
		repeat: true;
		running: false;
		onTriggered: obj._Poll();
	}

	Header{
		id: header;
		sText: root.sTitle;
		iTextMargin: constants._iSizeXXL + constants._iSpacingLarge;
		LocalToolIcon{
			anchors.left: parent.left;
			anchors.verticalCenter: parent.verticalCenter;
			width: height;
			iconId: "toolbar-back";
			onClicked: pageStack.pop();
		}
		LocalToolIcon{
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			width: height;
			iconId: "toolbar-refresh";
			onClicked: obj._Load();
		}
	}

	Item{
		id: content;
		anchors.top: header.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: actionbar.top;
		clip: true;

		Rectangle{
			id: qrgroup;
			anchors.fill: parent;
			visible: obj.mode === "qr";
			color: constants._cLightestColor;

			Rectangle{
				id: qrframe;
				anchors.centerIn: parent;
				anchors.verticalCenterOffset: -constants._iSizeSmall;
				width: Math.min(parent.width - constants._iSizeBig, parent.height - constants._iSizeBig, constants._iSizeTooBig);
				height: width;
				color: "#ffffff";
				border.width: 1;
				border.color: constants._cLightColor;
				radius: constants._iRadiusMedium;
				Image{
					id: qrimage;
					anchors.fill: parent;
					anchors.margins: constants._iSpacingLarge;
					fillMode: Image.PreserveAspectFit;
					cache: false;
				}
			}

			Text{
				id: qrstatus;
				anchors.top: qrframe.bottom;
				anchors.horizontalCenter: parent.horizontalCenter;
				anchors.topMargin: constants._iSpacingXXL;
				text: obj.sStatus;
				color: constants._cTextPrimary;
				font.pixelSize: constants._iFontLarge;
			}
		}

		Rectangle{
			id: cookiegroup;
			anchors.fill: parent;
			visible: obj.mode === "cookie";
			color: constants._cLightestColor;

			Column{
				anchors.centerIn: parent;
				width: parent.width - constants._iSpacingSuper * 2;
				spacing: constants._iSpacingXXL;

				Text{
					width: parent.width;
					text: "Cookie 登录";
					font.pixelSize: constants._iFontXXL;
					font.bold: true;
					color: constants._cTextPrimary;
				}

				TextField{
					id: sessdataField;
					width: parent.width;
					height: constants._iSizeXL;
					placeholderText: "SESSDATA";
					platformSipAttributes: SipAttributes{
						actionKeyHighlighted: actionKeyEnabled;
						actionKeyEnabled: sessdataField.text.length !== 0;
						actionKeyLabel: qsTr("OK");
					}
					Keys.onReturnPressed: {
						obj._CookieLogin();
						sessdataField.platformCloseSoftwareInputPanel();
					}
				}

				TextField{
					id: bilijctField;
					width: parent.width;
					height: constants._iSizeXL;
					placeholderText: "bili_jct（可选）";
					platformSipAttributes: SipAttributes{
						actionKeyHighlighted: actionKeyEnabled;
						actionKeyEnabled: bilijctField.text.length !== 0;
						actionKeyLabel: qsTr("OK");
					}
					Keys.onReturnPressed: {
						obj._CookieLogin();
						bilijctField.platformCloseSoftwareInputPanel();
					}
				}
			}
		}
	}

	Rectangle{
		id: actionbar;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		height: constants._iSizeXXL;
		color: constants._cLightestColor;
		Rectangle{
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			height: constants._iSpacingMicro;
			color: constants._cLightColor;
		}
		Row{
			anchors.fill: parent;
			anchors.leftMargin: constants._iSpacingLarge;
			anchors.rightMargin: constants._iSpacingLarge;
			spacing: constants._iSpacingLarge;
			Button{
				id: modebtn;
				anchors.verticalCenter: parent.verticalCenter;
				text: obj.mode === "qr" ? "凭证登录" : "扫码登录";
				width: parent.width * 0.3;
				onClicked: obj._ToggleMode();
			}
			Button{
				id: actionbtn;
				anchors.verticalCenter: parent.verticalCenter;
				text: obj.mode === "qr" ? "重新生成" : "登录";
				width: parent.width * 0.3;
				onClicked: {
					if(obj.mode === "qr")
					{
						obj._Load();
					}
					else
					{
						obj._CookieLogin();
					}
				}
			}
			Button{
				id: refreshbtn;
				anchors.verticalCenter: parent.verticalCenter;
				text: "刷新状态";
				width: parent.width * 0.3;
				onClicked: obj._CheckLogin();
			}
		}
	}
}
