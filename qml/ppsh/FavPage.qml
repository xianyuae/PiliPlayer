import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;

	sTitle: qsTr("Favorites") + "[" + obj.totalCount + "]";
	objectName: "idFavPage";

	Header{
		id: header;
		sText: root.sTitle;
		iTextMargin: back.width;
		onClicked: {
			obj._GetFavFolders();
		}
		LocalToolIcon{
			id: back;
			anchors.left: parent.left;
			anchors.verticalCenter: parent.verticalCenter;
			iconId: "toolbar-back";
			onClicked: pageStack.pop();
		}
	}

	function _Init()
	{
		obj._GetFavFolders();
	}

	QtObject{
		id: obj;
		property string uid: app.sMid;
		property int pageNo: 1;
		property int pageSize: 20;
		property int pageCount: 0;
		property int totalCount: 0;

		function _GetFavFolders(p)
		{
			if(!app.bLogin || uid === "")
			{
				controller._ShowMessage(qsTr("Please login first"));
				controller._OpenLoginPage();
				return;
			}

			root.bBusy = true;

			var pn;
			if(typeof(p) === "number") pn = p;
			else if(p === constants._sNextPage) pn = pageNo + 1;
			else if(p === constants._sPrevPage) pn = pageNo - 1;
			else if(p === constants._sThisPage) pn = pageNo;
			else pn = 1;

			if(p === undefined)
			{
				pageNo = 1;
				pageSize = 20;
				pageCount = 0;
				totalCount = 0;
			}
			Util.ModelClear(view.model);

			var d = {
				uid: uid,
				model: view.model,
				pageNo: pn,
				pageSize: pageSize,
				limit: pageSize,
			};

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

			Script.GetFavFolders(d, s, f);
		}
	}

	FavFolderWidget{
		id: view;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: header.bottom;
		anchors.bottom: parent.bottom;
		onRefresh: {
			obj._GetFavFolders(constants._sThisPage);
		}
		onClicked: {
			controller._OpenFavDetailPage(id, data.title);
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
			obj._GetFavFolders(constants._sPrevPage);
		}
		onNext: {
			obj._GetFavFolders(constants._sNextPage);
		}
	}

	onStatusChanged: {
		if(status === PageStatus.Active)
		{
			obj._GetFavFolders(constants._sThisPage);
		}
	}
}
