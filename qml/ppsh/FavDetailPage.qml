import QtQuick 1.1
import com.nokia.meego 1.1
import "component"
import "../js/main.js" as Script
import "../js/util.js" as Util

BasePage {
	id: root;

	sTitle: obj.title !== "" ? obj.title + "[" + obj.totalCount + "]" : qsTr("Favorites detail");
	objectName: "idFavDetailPage";

	Header{
		id: header;
		sText: root.sTitle;
		iTextMargin: back.width;
		onClicked: {
			obj._GetFavFolderDetail();
		}
		LocalToolIcon{
			id: back;
			anchors.left: parent.left;
			anchors.verticalCenter: parent.verticalCenter;
			iconId: "toolbar-back";
			onClicked: pageStack.pop();
		}
	}

	function _Init(id, title)
	{
		if(!id) return;
		obj.mediaId = id;
		if(title !== undefined) obj.title = title;
		obj._GetFavFolderDetail();
	}

	QtObject{
		id: obj;
		property string mediaId: "";
		property string title: "";
		property int pageNo: 1;
		property int pageSize: 20;
		property int pageCount: 0;
		property int totalCount: 0;

		function _GetFavFolderDetail(p)
		{
			if(mediaId === "") return;

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
				mediaId: mediaId,
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

			Script.GetFavFolderDetail(d, s, f);
		}
	}

	MixedListWidget{
		id: view;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: header.bottom;
		anchors.bottom: parent.bottom;
		sCoverRatio: "16/10";
		onRefresh: {
			obj._GetFavFolderDetail(constants._sThisPage);
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
			obj._GetFavFolderDetail(constants._sPrevPage);
		}
		onNext: {
			obj._GetFavFolderDetail(constants._sNextPage);
		}
	}

	onStatusChanged: {
		if(status === PageStatus.Active)
		{
			obj._GetFavFolderDetail(constants._sThisPage);
		}
	}
}
