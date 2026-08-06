import QtQuick 1.1
import com.nokia.meego 1.1
import "component"

BasePage {
	id: root;

	sTitle: "关于";
	objectName: "idAboutPage";

	Header{
		id: header;
		sText: root.sTitle;
		ToolBarLayout{
			anchors.fill: parent;
			LocalToolIcon{
				id: back;
				anchors.verticalCenter: parent.verticalCenter;
				iconId: "toolbar-back";
				onClicked: pageStack.pop();
			}
		}
	}

	function _Init()
	{
	}

	QtObject{
		id: obj;

		function _GetChangeLog()
		{
			var r = [];
			var c = _UT.Changelog();

			for(var i in c.CHANGES)
			{
				r.push({
					text: c.CHANGES[i],
				});
			}

			return r;
		}

		function _OpenLink(link)
		{
			var l = String(link || "");
			if(l.length > 0)
				controller._OpenUrl(l, 1);
		}
	}

	Component{
		id: infoRow;
		Item{
			id: rowitem;
			property string labelText: modelData.label;
			property string valueText: modelData.value;
			property bool richText: valueText.indexOf("<a ") >= 0;
			width: parent.width;
			height: Math.max(label.height, value.height) + constants._iSpacingLarge * 2;

			Rectangle{
				anchors.fill: parent;
				radius: constants._iRadiusSmall;
				color: index % 2 === 0 ? constants._cLighterColor : constants._cTransparent;
			}

			Row{
				anchors.fill: parent;
				anchors.leftMargin: constants._iSpacingXL;
				anchors.rightMargin: constants._iSpacingXL;
				spacing: constants._iSpacingXL;

				Text{
					id: label;
					anchors.verticalCenter: parent.verticalCenter;
					width: 120;
					text: rowitem.labelText;
					font.pixelSize: constants._iFontMedium;
					color: constants._cTextSecondary;
					elide: Text.ElideRight;
				}

				Text{
					id: value;
					anchors.verticalCenter: parent.verticalCenter;
					width: parent.width - label.width - parent.spacing;
					text: rowitem.valueText;
					textFormat: rowitem.richText ? Text.RichText : Text.PlainText;
					wrapMode: Text.WordWrap;
					font.pixelSize: constants._iFontMedium;
					color: constants._cDarkerColor;
					onLinkActivated: obj._OpenLink(link);
				}
			}

			Rectangle{
				anchors.bottom: parent.bottom;
				anchors.left: parent.left;
				anchors.right: parent.right;
				height: 1;
				color: constants._cDividerColor;
			}
		}
	}

	Flickable{
		id: flick;
		anchors.top: header.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		contentWidth: width;
		contentHeight: mainlayout.height + constants._iSpacingSuper * 2;
		clip: true;

		Column{
			id: mainlayout;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.topMargin: constants._iSpacingSuper;
			anchors.leftMargin: constants._iPageMargin;
			anchors.rightMargin: constants._iPageMargin;
			spacing: constants._iSpacingBig;

			Rectangle{
				width: parent.width;
				height: herocol.height + constants._iSpacingSuper * 2;
				radius: constants._iRadiusMedium;
				color: constants._cCardColor;
				border.width: 1;
				border.color: constants._cDividerColor;
				clip: true;

				Rectangle{
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;
					height: 5;
					color: constants._cGlobalColor;
				}

				Column{
					id: herocol;
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;
					anchors.topMargin: constants._iSpacingSuper;
					anchors.leftMargin: constants._iSpacingBig;
					anchors.rightMargin: constants._iSpacingBig;
					spacing: constants._iSpacingXL;

					Rectangle{
						id: iconbox;
						anchors.horizontalCenter: parent.horizontalCenter;
						width: constants._iSizeXXL + constants._iSpacingBig * 2;
						height: width;
						radius: constants._iRadiusMedium;
						color: constants._cLighterColor;
						border.width: 1;
						border.color: constants._cDividerColor;

						Image{
							anchors.centerIn: parent;
							width: constants._iSizeXXL;
							height: width;
							source: _UT.Get("ICON_PATH");
							smooth: true;
						}
					}

					Text{
						anchors.horizontalCenter: parent.horizontalCenter;
						text: _UT.Get("NAME");
						font.pixelSize: constants._iFontBig;
						font.bold: true;
						color: constants._cDarkerColor;
					}

					Text{
						width: parent.width;
						horizontalAlignment: Text.AlignHCenter;
						wrapMode: Text.WordWrap;
						text: _UT.Get("DESC");
						font.pixelSize: constants._iFontMedium;
						color: constants._cTextSecondary;
					}

					Rectangle{
						anchors.horizontalCenter: parent.horizontalCenter;
						width: versiontext.width + constants._iSpacingBig * 2;
						height: versiontext.height + constants._iSpacingMedium * 2;
						radius: height / 2;
						color: constants._cGlobalColor;

						Text{
							id: versiontext;
							anchors.centerIn: parent;
							text: _UT.Get("VER");
							font.pixelSize: constants._iFontSmall;
							font.bold: true;
							color: "#ffffff";
						}
					}
				}
			}

			Rectangle{
				width: parent.width;
				height: aicol.height + constants._iSpacingSuper * 2;
				radius: constants._iRadiusMedium;
				color: constants._bInverted ? "#2b2617" : "#fff7d6";
				border.width: 1;
				border.color: constants._bInverted ? "#b8932e" : "#f2c94c";
				clip: true;

				Rectangle{
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;
					height: 5;
					color: "#f2c94c";
				}

				Column{
					id: aicol;
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;
					anchors.topMargin: constants._iSpacingSuper;
					anchors.leftMargin: constants._iSpacingBig;
					anchors.rightMargin: constants._iSpacingBig;
					spacing: constants._iSpacingXL;

					Rectangle{
						anchors.horizontalCenter: parent.horizontalCenter;
						width: constants._iSizeXL;
						height: constants._iSizeMedium;
						radius: height / 2;
						color: "#f2c94c";

						Text{
							anchors.centerIn: parent;
							text: "AI";
							font.pixelSize: constants._iFontMedium;
							font.bold: true;
							color: "#1a1a1a";
						}
					}

					Text{
						anchors.horizontalCenter: parent.horizontalCenter;
						text: "此软件使用 AI 代码";
						font.pixelSize: constants._iFontXL;
						font.bold: true;
						color: constants._bInverted ? "#f5e08a" : "#7a5c00";
					}
				}
			}

			Rectangle{
				width: parent.width;
				height: maintaincol.height + constants._iSpacingSuper * 2;
				radius: constants._iRadiusMedium;
				color: constants._bInverted ? "#15242e" : "#e6f4fb";
				border.width: 1;
				border.color: constants._bInverted ? "#2f6f8f" : "#64b5f6";
				clip: true;

				Rectangle{
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;
					height: 5;
					color: "#42a5f5";
				}

				Column{
					id: maintaincol;
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;
					anchors.topMargin: constants._iSpacingSuper;
					anchors.leftMargin: constants._iSpacingBig;
					anchors.rightMargin: constants._iSpacingBig;
					spacing: constants._iSpacingXL;

					Rectangle{
						anchors.horizontalCenter: parent.horizontalCenter;
						width: constants._iSizeXL + constants._iSpacingSmall;
						height: constants._iSizeMedium;
						radius: height / 2;
						color: "#42a5f5";

						Text{
							anchors.centerIn: parent;
							text: "维护";
							font.pixelSize: constants._iFontMedium;
							font.bold: true;
							color: "#ffffff";
						}
					}

					Text{
						anchors.horizontalCenter: parent.horizontalCenter;
						width: parent.width;
						horizontalAlignment: Text.AlignHCenter;
						wrapMode: Text.WordWrap;
						text: "本分支由 xianyuaa123@gmail.com 维护，同时也希望各位大佬参与优化此软件。";
						font.pixelSize: constants._iFontXL;
						font.bold: true;
						color: constants._bInverted ? "#8fd3ff" : "#0d47a1";
					}
				}
			}

			Rectangle{
				width: parent.width;
				height: infocol.height + constants._iSpacingSuper * 2;
				radius: constants._iRadiusMedium;
				color: constants._cCardColor;
				border.width: 1;
				border.color: constants._cDividerColor;
				clip: true;

				Column{
					id: infocol;
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;
					anchors.topMargin: constants._iSpacingBig;
					anchors.leftMargin: constants._iSpacingBig;
					anchors.rightMargin: constants._iSpacingBig;
					spacing: constants._iSpacingXL;

					SectionWidget{
						sText: "软件信息";
						iMargins: 0;
						cColor: constants._cGlobalColor;
					}

					Repeater{
						model: [
							{ label: "版本", value: _UT.Get("VER") },
							{ label: "时间", value: _UT.Get("RELEASE") },
							{ label: "Qt", value: _UT.Get("QT") },
							{ label: "项目", value: "<a href='https://github.com/xianyuae/PiliPlayer'>PiliPlayer</a>" },
							{ label: "参考项目", value: "<a href='https://github.com/guozhigq/pilipala'>PiliPala</a>" },
						]
						delegate: infoRow;
					}
				}
			}

			Rectangle{
				width: parent.width;
				height: licensecol.height + constants._iSpacingSuper * 2;
				radius: constants._iRadiusMedium;
				color: constants._cCardColor;
				border.width: 1;
				border.color: constants._cDividerColor;
				clip: true;

				Column{
					id: licensecol;
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;
					anchors.topMargin: constants._iSpacingBig;
					anchors.leftMargin: constants._iSpacingBig;
					anchors.rightMargin: constants._iSpacingBig;
					spacing: constants._iSpacingXL;

					SectionWidget{
						sText: "许可协议";
						iMargins: 0;
						cColor: constants._cGlobalColor;
					}

					Repeater{
						model: [
							{ label: "版权", value: _UT.Get("COPYRIGHT") },
							{ label: "来源", value: "基于 PPSH 二次修改" },
							{ label: "许可协议", value: _UT.Get("LICENSE") },
							{ label: "许可文本", value: "<a href='%1'>查看许可文本</a>".arg(_UT.Get("LICENSE_URL")) },
						]
						delegate: infoRow;
					}
				}
			}

			Rectangle{
				width: parent.width;
				height: thirdcol.height + constants._iSpacingSuper * 2;
				radius: constants._iRadiusMedium;
				color: constants._cCardColor;
				border.width: 1;
				border.color: constants._cDividerColor;
				clip: true;

				Column{
					id: thirdcol;
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;
					anchors.topMargin: constants._iSpacingBig;
					anchors.leftMargin: constants._iSpacingBig;
					anchors.rightMargin: constants._iSpacingBig;
					spacing: constants._iSpacingXL;

					SectionWidget{
						sText: "第三方许可";
						iMargins: 0;
						cColor: constants._cGlobalColor;
					}

					Repeater{
						model: [
							{ label: "Qt 移动组件（诺基亚）", value: "<a href='https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html'>LGPL v2.0+ / v2.1</a>" },
							{ label: "KMPlayer++（Koos Vriezen）", value: "<a href='https://www.gnu.org/licenses/gpl-2.0.html'>GPL v2+ / LGPL v2+</a>" },
							{ label: "Material Symbols（Google）", value: "<a href='https://www.apache.org/licenses/LICENSE-2.0'>Apache 2.0 许可证</a>" },
						]
						delegate: infoRow;
					}
				}
			}

			Rectangle{
				width: parent.width;
				height: updatecol.height + constants._iSpacingSuper * 2;
				radius: constants._iRadiusMedium;
				color: constants._cCardColor;
				border.width: 1;
				border.color: constants._cDividerColor;
				clip: true;

				Column{
					id: updatecol;
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;
					anchors.topMargin: constants._iSpacingBig;
					anchors.leftMargin: constants._iSpacingBig;
					anchors.rightMargin: constants._iSpacingBig;
					spacing: constants._iSpacingXL;

					SectionWidget{
						sText: "更新";
						iMargins: 0;
						cColor: constants._cGlobalColor;
					}

					Repeater{
						model: obj._GetChangeLog();
						delegate: Component{
							Text{
								width: parent.width;
								wrapMode: Text.WordWrap;
								text: "* " + modelData.text;
								font.pixelSize: constants._iFontMedium;
								color: constants._cTextPrimary;
							}
						}
					}
				}
			}
		}
	}

	ScrollDecorator{
		flickableItem: flick;
	}
}
