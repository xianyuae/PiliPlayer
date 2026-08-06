import QtQuick 1.1

Rectangle {
    id: root;

	objectName: "idHeaderWidget";
    property alias sText: title.text;
    property alias cTextColor: title.color;
    property alias iTextSize: title.font.pixelSize;
    property alias bMouseEnabled: mousearea.enabled;
		property int iTextMargin: 0;
    signal clicked(variant mouse);

    anchors.top: parent.top;
    anchors.left: parent.left;
    anchors.right: parent.right;
    width: parent.width;
    height: constants._iHeaderHeight;
    z: constants._iHeaderZ;

    color: constants._cGlobalColor;
    clip: true;

    Rectangle{
        anchors.fill: parent;
        color: "#ffffff";
        opacity: 0.08;
    }

    Rectangle{
        id: bottomline;
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
        height: 1;
        color: "#000000";
        opacity: 0.22;
    }

    Text{
        id: title;
        anchors.fill: parent;
        anchors.leftMargin: root.iTextMargin;
        anchors.rightMargin: root.iTextMargin;
        z: 1;
        horizontalAlignment: Text.AlignHCenter;
        verticalAlignment: Text.AlignVCenter;
        maximumLineCount: 2;
        font.pixelSize: constants._iFontXL;
        elide: Text.ElideRight;
        font.bold: true;
        clip: true;
        color: constants._cHeaderTitleColor;
    }

    MouseArea{
        id: mousearea;
        anchors.fill: parent;
        onClicked: root.clicked(mouse);
    }
}
