import QtQuick 1.1
import com.nokia.meego 1.1
import karin.ppsh 1.0
import QtMultimediaKit 1.1
import "../component"
import "../../js/main.js" as Script

BasePage {
	id: root;

	sTitle: "Test Video";
	objectName: "idTestVideoPage";

	Header{
		id: header;
		//sText: root.sTitle;
		Row{
			anchors.fill: parent;
			clip: true;
			spacing: constants._iSpacingSmall;
			LocalToolIcon{
				id: menuicon;
				anchors.verticalCenter: parent.verticalCenter;
				iconId: "toolbar-view-menu";
				onClicked: mainmenu.open();
			}
			TextField{
				id: input;
				anchors.verticalCenter: parent.verticalCenter;
				width: parent.width - parent.spacing - menuicon.width;
				clip: true;
				placeholderText: "Input data";
				inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase;
				platformStyle: TextFieldStyle{
					paddingLeft: constants._iSpacingSuper;
					paddingRight: clear.width;
				}
				platformSipAttributes: SipAttributes{
					id: sip;
					actionKeyHighlighted: actionKeyEnabled;
					actionKeyEnabled: input.text.length !== 0;
					actionKeyLabel: "Parse";
				}
				Keys.onReturnPressed: {
					input.platformCloseSoftwareInputPanel();
					obj._parse();
				}
				LocalToolIcon{
					id: clear;
					anchors.right: parent.right;
					anchors.verticalCenter: parent.verticalCenter;
					width: height;
					height: constants._iSizeMedium;
					iconId: "toolbar-close";
					inverted: constants._bInverted;
					enabled: input.text !== "";
					visible: enabled;
					onClicked: {
						input.text = "";
						input.forceActiveFocus();
						input.platformOpenSoftwareInputPanel();
					}
				}
			}
		}
	}

	function _Init(data)
	{
		obj._Parse(data);
	}


	QtObject{
		id: obj;
		function _Parse(data)
		{
			var s = function(url){
				video.source = url;
				video.play();
			};
			var f = function(json){
				root.bBusy = false;
				controller._ShowMessage("Error");
				resp.text = json;
			};
			var d = {
				id: "3361877",
			};

			Script.TEST(d, s, f);
		}
	}

	PPSHVideo {
		id: video;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: header.bottom;
		anchors.bottom: parent.bottom;

		headersEnabled: true;
		requestHeaders: [
			{
				name: "User-Agent",
				value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36",
			},
			{
				name: "Referer",
				value: "https://www.bilibili.com",
			},
		];
		onError:{
			if(error !== PPSHVideo.NoError){
				controller._ShowMessage("[ERROR]: %1 -> %2".arg(error).arg(errorString));
			}
		}
		focus: true
		Keys.onSpacePressed: paused = !paused;
		Keys.onLeftPressed: position -= 5000;
		Keys.onRightPressed: position += 5000;
	}

	ContextMenu{
		id: mainmenu;
		MenuLayout {
			MenuItem {
				text: "Open externally";
				enabled: video.source != "";
				onClicked: {
					if(video.source != "") _UT.OpenPlayer(video.source.toString());
				}
			}
			MenuItem{
				text: "Copy url";
				enabled: video.source != "";
				onClicked: {
					if(video.source != "") controller._CopyToClipboard(video.source.toString());
				}
			}
			MenuItem {
				text: "Back";
				onClicked: {
					pageStack.pop();
				}
			}
		}
	}
}
