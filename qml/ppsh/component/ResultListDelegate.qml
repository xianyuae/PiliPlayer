import QtQuick 1.1
import com.nokia.meego 1.1
import "../../js/util.js" as Util

Item{
	id: root;
	property bool editMode: false;
	signal clicked(string mid, variant data);
	signal imageClicked(string mid, variant data);
	signal longPressed(int index, variant data);
	objectName: "idResultListDelegate";

	MouseArea{
		anchors.fill: parent;
		onClicked: {
			root.clicked(model.mid, model);
		}
		onPressAndHold: {
			root.longPressed(index, model);
		}
	}

	Rectangle{
		anchors.fill: parent;
		anchors.leftMargin: constants._iSpacingMedium;
		anchors.rightMargin: constants._iSpacingMedium;
		anchors.topMargin: constants._iSpacingSmall;
		anchors.bottomMargin: constants._iSpacingSmall;
		radius: constants._iRadiusMedium;
		color: constants._cCardColor;
		border.width: 1;
		border.color: constants._cDividerColor;
		clip: true;
		smooth: true;

		Image{
			id: preview;
			anchors.left: parent.left;
			anchors.leftMargin: constants._iSpacingMedium;
			anchors.verticalCenter: parent.verticalCenter;
			height: parent.height - constants._iSpacingMedium * 2;
			width: model.type == constants._eBangumiType ? Util.GetSize(height, 0, "4/3") : (model.type == constants._eUserType ? height : Util.GetSize(0, height, "16/9"));
			fillMode: Image.PreserveAspectCrop;
			clip: true;
			source: model.preview;
			cache: true;
			sourceSize: Qt.size(width, height);
			MouseArea{
				anchors.fill: parent;
				onClicked: {
					root.imageClicked(model.mid, model);
				}
			}
			Rectangle{
				anchors.right: parent.right;
				anchors.bottom: parent.bottom;
				anchors.rightMargin: constants._iSpacingSmall;
				anchors.bottomMargin: constants._iSpacingSmall;
				width: signlabel.paintedWidth + constants._iSpacingLarge * 2;
				height: constants._iSizeSmall;
				radius: height / 2;
				color: constants._cBadgeBg;
				clip: true;
				visible: model.sign ? true : false;
				Text{
					id: signlabel;
					anchors.centerIn: parent;
					text: model.sign || "";
					verticalAlignment: Text.AlignVCenter;
					horizontalAlignment: Text.AlignHCenter;
					font.pixelSize: constants._iFontSmall;
					elide: Text.ElideRight;
					color: "#ffffff";
				}
			}
		}

		Item{
			anchors.left: preview.right;
			anchors.leftMargin: constants._iSpacingMedium;
			anchors.right: parent.right;
			anchors.rightMargin: constants._iSpacingLarge;
			anchors.verticalCenter: parent.verticalCenter;
			height: preview.height;
			Text{
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.bottom: extracol.top;
				text: model.title;
				font.pixelSize: constants._iFontLarge;
				elide: Text.ElideRight;
				color: constants._cTextPrimary;
				wrapMode: Text.WrapAnywhere;
				maximumLineCount: height > parent.height / 2 ? 2 : 1;
				clip: true;
				z: 1;
			}
			Column{
				id: extracol;
				anchors.bottom: parent.bottom;
				anchors.left: parent.left;
				anchors.right: parent.right;
				clip: true;
				spacing: constants._iSpacingTiny;
				Text{
					width: parent.width;
					text: model.subtitle;
					font.pixelSize: constants._iFontMedium;
					elide: Text.ElideRight;
					color: constants._cTextSecondary;
				}
				Flow{
					id: extras;
					property variant __model: model.extras;
					width: parent.width;
					spacing: constants._iSpacingLarge;
					Repeater{
						model: extras.__model;
						delegate: Component{
							Text{
								visible: model.value !== undefined;
								text: (model.name ? model.name + " " : "") + model.value + (model.unit ? " " + model.unit : "");
								font.pixelSize: constants._iFontSmall;
								color: constants._cTextSecondary;
							}
						}
					}
				}
			}
		}
	}
}
