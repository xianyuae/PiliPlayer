.pragma library

Qt.include("network.js");
Qt.include("api.js");
Qt.include("util.js");
Qt.include("database.js");
Qt.include("qrcode.js");

var _UT;
var db = new idDatabase("ppsh", "Pili Player database", 2 * 1024 * 1024);
var _WbiKeys = null;
var _WbiLoading = false;
var _WbiQueue = [];

function Init(ut)
{
	_UT = ut;
	db.Create('keyword', '(tid INTEGER PRIMARY KEY AUTOINCREMENT, keyword TEXT NOT NULL UNIQUE, ts INTEGER DEFAULT 0)');
	db.Create('view', '(tid INTEGER PRIMARY KEY AUTOINCREMENT, aid TEXT NOT NULL UNIQUE, title TEXT, preview TEXT, up TEXT, type INTEGER, ts INTEGER DEFAULT 0)');
	db.CreateIndex('keyword', 'idx_keyword_ts', 'ts DESC');
	db.CreateIndex('view', 'idx_view_ts', 'ts DESC');

	Request("https://space.bilibili.com/1/dynamic", "GET", undefined, function(){
		// response Set-Cookie (buvid3 etc.) will be stored by the engine's cookie jar
	}, function(){
	}, "TEXT");
}

function RefreshLoginStatus(success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		if(!json || json.code !== 0 || !json.data || !json.data.isLogin)
		{
			f(json && json.code === -101 ? "logout" : (json && json.message ? json.message : "Get user info fail"));
			return;
		}
		var d = json.data;
		if(d && d.wbi_img && d.wbi_img.img_url && d.wbi_img.sub_url)
		{
			var imgUrl = d.wbi_img.img_url;
			var subUrl = d.wbi_img.sub_url;
			_WbiKeys = {
				imgKey: imgUrl.substring(imgUrl.lastIndexOf("/") + 1).split(".")[0],
				subKey: subUrl.substring(subUrl.lastIndexOf("/") + 1).split(".")[0],
			};
		}
		var info = {
			bLogin: true,
			uname: d.uname || "",
			face: d.face || "",
			mid: d.mid !== undefined ? d.mid : "",
			level: d.level_info ? (d.level_info.current_level || 0) : 0,
			coins: d.money !== undefined ? d.money : 0,
			following: 0,
			follower: 0,
		};
		var ss = function(sjson){
			if(sjson && sjson.code === 0 && sjson.data)
			{
				info.following = sjson.data.following || 0;
				info.follower = sjson.data.follower || 0;
			}
			if(typeof(success) === "function") success(info);
		};
		Request(idAPI.USER_STAT_OWNER, "GET", undefined, ss, function(){
			if(typeof(success) === "function") success(info);
		});
	};
	Request(idAPI.USER_NAV, "GET", undefined, s, f);
}

function Logout(success, fail)
{
	Request(idAPI.LOGOUT, "GET", undefined, success, fail, "TEXT");
}

function GetLoginQrcode(success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		if(json && json.code === 0 && json.data && json.data.qrcode_key)
		{
			if(typeof(success) === "function") success(json.data);
		}
		else
			f(json && json.message ? json.message : "Get qrcode fail");
	};
	Request(idAPI.QRCODE_GENERATE, "GET", undefined, s, f);
}

function GetLoginQrcodeStatus(key, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		if(json && json.code === 0 && json.data)
		{
			if(typeof(success) === "function") success(json.data);
		}
		else
			f(json && json.message ? json.message : "Get qrcode status fail");
	};
	Request(idAPI.QRCODE_POLL, "GET", { qrcode_key: key }, s, f);
}

function MakeQrcodeDataUrl(text)
{
	if(!text) return "";
	var qr = qrcode(0, "M");
	qr.addData(text);
	qr.make();
	return qr.createDataURL(6, 6);
}

function Request(url, method, args, success, fail, type)
{
    var req = new idNetwork(url, method, args, type);

    req.Request(success, fail);
		return req;
}

function GetCsrf()
{
	return _UT ? _UT.Csrf() : "";
}

function _GetWbiKeys(success, fail)
{
	if(_WbiKeys)
	{
		if(typeof(success) === "function") success(_WbiKeys);
		return;
	}
	if(_WbiLoading)
	{
		_WbiQueue.push({
			success: success,
			fail: fail,
		});
		return;
	}

	_WbiLoading = true;
	var f = function(err){
		_WbiLoading = false;
		while(_WbiQueue.length > 0)
		{
			var item = _WbiQueue.shift();
			if(typeof(item.fail) === "function") item.fail(err);
		}
		if(typeof(fail) === "function") fail(err);
	};
	var s = function(json){
		if(!json || !json.data || !json.data.wbi_img)
		{
			f("Get wbi keys fail");
			return;
		}
		var imgUrl = json.data.wbi_img.img_url;
		var subUrl = json.data.wbi_img.sub_url;
		_WbiKeys = {
			imgKey: imgUrl.substring(imgUrl.lastIndexOf("/") + 1).split(".")[0],
			subKey: subUrl.substring(subUrl.lastIndexOf("/") + 1).split(".")[0],
		};
		_WbiLoading = false;
		while(_WbiQueue.length > 0)
		{
			var item = _WbiQueue.shift();
			if(typeof(item.success) === "function") item.success(_WbiKeys);
		}
		if(typeof(success) === "function") success(_WbiKeys);
	};
	Request("https://api.bilibili.com/x/web-interface/nav", "GET", undefined, s, f);
}

function SignWbi(params, success, fail)
{
	var p = params || {};
	_GetWbiKeys(function(keys){
		var sign = _UT.WbiSign(p, keys.imgKey, keys.subKey);
		if(typeof(success) === "function") success(sign);
	}, fail);
}

function RequestWbi(url, method, args, success, fail, type)
{
	SignWbi(args || {}, function(signed){
		Request(url, method, signed, success, fail, type);
	}, fail);
}

// SearchPage
function GetDefaultKeyword(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeDefaultKeyword(json, data.model, data.limit) === 0)
		{
			if(typeof(success) === "function") success();
		}
		else
			f(json.message);
	};
	Request(idAPI.HOT_KEYWORD, "GET", undefined, s, f);
}

function GetSearchSuggest(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeSearchSuggest(json, data.model, data.limit) === 0)
		{
			if(typeof(success) === "function") success();
		}
		else
			f(json.message);
	};
	var opt = {
		term: data.keyword,
		main_ver: "v1",
		highlight: "1",
	};
	Request(idAPI.SEARCH_SUGGEST, "GET", opt, s, f);
}

// ResultPage
function SearchKeyword(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeSearchResult(json, data.model, data.type, data.limit) === 0)
		{
			var page_json = json.data;
			if(data.type === "live" && json.data.pageinfo && json.data.pageinfo.live_room)
			{
				var room = json.data.pageinfo.live_room;
				page_json = {
					page: json.data.page || room.page,
					pagesize: json.data.pagesize || room.pagesize,
					numResults: room.numResults,
					numPages: room.numPages,
				};
			}
			var page_data = __GetPageData(page_json, ["page", "pagesize", "numResults", "numPages"]);
			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var opt = {
		search_type: data.type || "video",
		keyword: data.keyword,
		page_size: data.pageSize || 20,
	};
	if(data.pageNo !== undefined)
		opt.page = data.pageNo;
	if(data.order !== undefined)
		opt.order = data.order;
	RequestWbi(idAPI.SEARCH, "GET", opt, s, f);
}

// DetailPage
function GetVideoDetail(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeContent(json, data.model) !== 0)
			f(json.message);

		var r = new Object();
		if(idAPI.MakeVideoInfo(json, r) === 0)
		{
			if(typeof(success) === "function") success(r);
		}
		else
			f(json.message);
	};
	var opt = {};
	if(data.bvid || (typeof(data.aid) === "string" && data.aid.indexOf("BV") === 0))
		opt.bvid = data.bvid || data.aid;
	else
		opt.aid = data.aid;
	Request(idAPI.VIDEO_DETAIL, "GET", opt, s, f);
}

function __VideoIdParams(data)
{
	var opt = {};
	if(data.bvid)
		opt.bvid = data.bvid;
	else if(data.aid)
	{
		if(typeof(data.aid) === "string" && data.aid.indexOf("BV") === 0)
			opt.bvid = data.aid;
		else
			opt.aid = data.aid;
	}
	return opt;
}

function __NormalizeAid(data)
{
	var aid = data.aid;
	if(typeof(aid) === "string" && aid.indexOf("BV") === 0 && _UT && _UT.Bv2Av)
	{
		var av = _UT.Bv2Av(aid);
		if(av !== "")
			aid = av;
	}
	return aid;
}

function GetVideoLikeState(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(typeof(success) === "function") success(json.data);
	};
	var opt = __VideoIdParams(data);
	Request(idAPI.VIDEO_HAS_LIKE, "GET", opt, s, f);
}

function GetVideoCoinState(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(typeof(success) === "function") success(json.data);
	};
	var opt = __VideoIdParams(data);
	Request(idAPI.VIDEO_HAS_COIN, "GET", opt, s, f);
}

function GetVideoFavState(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(typeof(success) === "function") success(json.data);
	};
	var opt = {
		aid: __NormalizeAid(data),
	};
	Request(idAPI.VIDEO_HAS_FAV, "GET", opt, s, f);
}

function SetVideoLike(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var csrf = GetCsrf();
	if(csrf === "")
	{
		f(qsTr("CSRF token missing, please login again"));
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(typeof(success) === "function") success(json.data);
	};
	var opt = __VideoIdParams(data);
	opt.like = data.like;
	opt.csrf = csrf;
	Request(idAPI.VIDEO_LIKE, "POST", opt, s, f);
}

function SetVideoCoin(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var csrf = GetCsrf();
	if(csrf === "")
	{
		f(qsTr("CSRF token missing, please login again"));
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(typeof(success) === "function") success(json.data);
	};
	var opt = __VideoIdParams(data);
	opt.multiply = data.multiply;
	opt.select_like = 0;
	opt.csrf = csrf;
	Request(idAPI.VIDEO_COIN_ADD, "POST", opt, s, f);
}

function SetVideoFav(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var csrf = GetCsrf();
	if(csrf === "")
	{
		f(qsTr("CSRF token missing, please login again"));
		return;
	}
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(typeof(success) === "function") success(json.data);
	};
	var opt = {
		rid: __NormalizeAid(data),
		type: 2,
		add_media_ids: data.addIds || "",
		del_media_ids: data.delIds || "",
		csrf: csrf,
	};
	Request(idAPI.VIDEO_FAV_DEAL, "POST", opt, s, f);
}

function GetVideoFavFolders(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		var model = [];
		if(idAPI.MakeVideoFavFolders(json, model) === 0)
		{
			if(typeof(success) === "function") success(model);
		}
		else
			f(json.message);
	};
	var opt = {
		up_mid: data.uid,
		rid: __NormalizeAid(data),
	};
	Request(idAPI.VIDEO_FAV_LIST_ALL, "GET", opt, s, f);
}

function GetRecommend(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeRecommend(json, data.model, data.limit) === 0)
		{
			if(typeof(success) === "function") success();
		}
		else
			f(json.message);
	};
	Request(idAPI.RECOMMEND.arg(data.aid), "GET", undefined, s, f);
}

function GetRecommendFeed(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeRecommendFeed(json, data.model, data.limit) === 0)
		{
			if(typeof(success) === "function") success();
		}
		else
			f(json.message);
	};
	var opt = {
		version: 1,
		feed_version: "V3",
		homepage_ver: 1,
		ps: data.ps || 20,
		fresh_idx: data.freshIdx || 0,
		brush: data.freshIdx || 0,
		fresh_type: 4,
	};
	Request(idAPI.RECOMMEND_FEED, "GET", opt, s, f);
}

function GetComment(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeComment(json, data.model) === 0)
		{
			var page_data = __GetPageData(json.data.page, ["num", "size", "count", null]);
			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var opt = {
		type: 1,
		sort: 0, // 2: hot
		oid: data.aid,
		nohot: 1,
		plat: 1,
	};
	if(data.pageNo !== undefined)
		opt.pn = data.pageNo;
	if(data.order !== undefined)
		opt.sort = data.order;
	if(data.type !== undefined)
		opt.type = data.type;
	Request(idAPI.COMMENT, "GET", opt, s, f);
}

function GetReply(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeComment(json, data.model) === 0)
		{
			var page_data = __GetPageData(json.data.page, ["num", "size", "count", null]);
			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var opt = {
		type: 1,
		oid: data.aid,
		root: data.rid,
		plat: 1,
	};
	if(data.pageNo !== undefined)
		opt.pn = data.pageNo;
	if(data.pageSize !== undefined)
		opt.ps = data.pageSize;
	if(data.type !== undefined)
		opt.type = data.type;
	Request(idAPI.COMMENT_REPLY, "GET", opt, s, f);
}

// MainPage
function GetRanking(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeRanking(json, data.model, data.limit) === 0)
		{
			var page_data = {
				info: json.data.info,
			};
			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var opt = {
		rid: 0,
		day: 1,
	};
	if(data.rid !== undefined)
		opt.rid = data.rid;
	if(data.day !== undefined)
		opt.day = data.day;
	Request(idAPI.RANKING, "GET", opt, s, f);
}

// RankingPage
function GetChannels(data, success, fail)
{
	function __LocalChannels(model)
	{
		var push = Array.isArray(model) ? "push" : "append";
		var list = idCategory.children || [];
		for(var i in list)
		{
			var e = list[i];
			if(!e.rid) continue;
			model[push]({
				value: e.rid,
				count: 0,
				name: e.name,
			});
		}
	}

	var f = function(message){
		__LocalChannels(data.model);
		if(typeof(success) === "function") success();
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeChannels(json, data.model) === 0)
		{
			var page_data = {
				all_count: json.data.all_count,
				web_online: json.data.web_online,
				play_online: json.data.play_online,
			};
			if(typeof(success) === "function") success(page_data);
		}
		else
		{
			__LocalChannels(data.model);
			if(typeof(success) === "function") success();
			f(json.message);
		}
	};
	var opt = {
		jsonp: "jsonp",
	};
	Request(idAPI.CHANNELS_IDS, "GET", opt, s, f);
}

function GetCategoryRanking(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}

		if(idAPI.MakeCategoryRanking(json, data.model, data.limit) === 0)
		{
			if(typeof(success) === "function") success();
		}
		else
			f(json.message);
	};
	var opt = {
		rid: data.rid,
		original: 0,
		day: 7,
	};
	if(data.original !== undefined)
		opt.original = data.original;
	if(data.day !== undefined)
		opt.day = data.day;
	Request(idAPI.CATEGORY_RANKING, "GET", opt, s, f);
}

function GetCategoryNewlist(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}

		if(idAPI.MakeCategoryNewlist(json, data.model) === 0)
		{
			var page_data = __GetPageData(json.data.page, ["num", "size", "count", null]);
			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var opt = {
		rid: data.rid,
		type: 0,
	};
	if(data.pageNo !== undefined)
		opt.pn = data.pageNo;
	if(data.pageSize !== undefined)
		opt.ps = data.pageSize;
	if(data.type !== undefined)
		opt.type = data.type;
	Request(idAPI.CATEGORY_NEWLIST, "GET", opt, s, f);
}

function GetCategoryDynamic(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}

		if(idAPI.MakeCategoryDynamic(json, data.model) === 0)
		{
			var page_data = __GetPageData(json.data.page, ["num", "size", "count", null]);

			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var opt = {
		rid: data.rid,
		type: 0,
	};
	if(data.pageNo !== undefined)
		opt.pn = data.pageNo;
	if(data.pageSize !== undefined)
		opt.ps = data.pageSize;
	Request(idAPI.CATEGORY_DYNAMIC, "GET", opt, s, f);
}

// CategoryPage
function GetCategory(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}

		if(idAPI.MakeCategory(json, data.model) === 0)
		{
			var page_data = __GetPageData(json.data.page, ["num", "size", "count", null]);

			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var opt = {
		rid: data.rid,
		type: 0,
		ps: data.pageSize !== undefined ? data.pageSize : 20,
	};
	if(data.pageNo !== undefined)
		opt.pn = data.pageNo;
	if(data.pageSize !== undefined)
		opt.ps = data.pageSize;
	Request(idAPI.CATEGORY, "GET", opt, s, f);
}

function GetFullChannels(data, success, fail)
{
	if(data.local)
	{
		if(typeof(success) === "function") success(idCategory);
		return;
	}

	var f = function(message){
		if(typeof(success) === "function") success(idCategory);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeFullChannels(json, data.model) === 0)
		{
			if(typeof(success) === "function") success(data.model);
		}
		else
		{
			if(typeof(success) === "function") success(idCategory);
		}
	};
	Request(idAPI.CHANNELS, "GET", undefined, s, f);
}

// UserPage
function GetUserDetail(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		var r = new Object();
		if(idAPI.MakeUserInfo(json, r) === 0)
		{
			if(typeof(success) === "function") success(r);
		}
		else
			f(json.message);
	};
	var opt = {
		mid: data.uid,
		photo: true,
	};
	Request(idAPI.USER_DETAIL, "GET", opt, s, f);
}

function GetUserVideos(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var pn = data.pageNo ? data.pageNo : 1;
	var ps = data.pageSize ? data.pageSize : 20;
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeUserVideos(json, data.model, undefined, data.tmodel) === 0)
		{
			var d = json.data;
			var listData = d.list || d;
			var tlist = listData.tlist || d.tlist;
			var count = 0;
			if(listData.page)
				count = listData.page.count || listData.page.total || 0;
			if(tlist && data.tid == "0")
			{
				for(var k in tlist)
					count += tlist[k].count;
			}
			else if(tlist)
			{
				for(var k in tlist)
				{
					if(k == data.tid)
					{
						count = tlist[k].count;
						break;
					}
				}
			}
			var fake_json_data = {
				"pageNo": pn,
				"pageSize": ps,
				"totalCount": count,
			};
			var page_data = __GetPageData(fake_json_data, ["pageNo", "pageSize", "totalCount", null]);
			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var dmChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	var dmImgStr = "";
	var dmCoverImgStr = "";
	for(var i = 0; i < 32; i++)
		dmImgStr += dmChars.charAt(Math.floor(Math.random() * dmChars.length));
	for(var i = 0; i < 64; i++)
		dmCoverImgStr += dmChars.charAt(Math.floor(Math.random() * dmChars.length));
	var order = data.order || "pubdate";
	if(order === "update") order = "pubdate";
	var opt = {
		mid: data.uid,
		ps: ps,
		tid: data.tid || 0,
		pn: pn,
		order: order,
		platform: "web",
		web_location: 1550101,
		order_avoided: true,
		dm_img_list: "[]",
		dm_img_str: dmImgStr,
		dm_cover_img_str: dmCoverImgStr,
		dm_img_inter: '{"ds":[],"wh":[0,0,0],"of":[0,0,0]}',
	};
	RequestWbi(idAPI.USER_VIDEOS, "GET", opt, s, f);
}

function GetUserArticles(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeUserArticles(json, data.model) === 0)
		{
			var page_data = __GetPageData(json.data, ["pn", "ps", "count", null]);
			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var opt = {
		mid: data.uid,
		sort: data.order,
		jsonp: "jsonp",
	};
	if(data.pageNo !== undefined)
		opt.pn = data.pageNo;
	if(data.pageSize !== undefined)
		opt.ps = data.pageSize;
	Request(idAPI.USER_ARTICLES, "GET", opt, s, f);
}

// FavPage
function GetFavFolders(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var pn = data.pageNo ? data.pageNo : 1;
	var ps = data.pageSize ? data.pageSize : 20;
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeFavFolders(json, data.model, data.limit) === 0)
		{
			var count = json.data.count || ModelSize(data.model);
			var page_data = __GetPageData({pn: pn, ps: ps, count: count}, ["pn", "ps", "count", null]);
			page_data.hasMore = json.data.has_more;
			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var opt = {
		pn: pn,
		ps: ps,
		up_mid: data.uid,
	};
	Request(idAPI.USER_FAV_FOLDERS, "GET", opt, s, f);
}

function GetFavFolderDetail(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var pn = data.pageNo ? data.pageNo : 1;
	var ps = data.pageSize ? data.pageSize : 20;
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeFavResources(json, data.model, data.limit) === 0)
		{
			var info = json.data.info || {};
			var count = info.media_count || ModelSize(data.model);
			var page_data = __GetPageData({pn: pn, ps: ps, count: count}, ["pn", "ps", "count", null]);
			page_data.info = info;
			page_data.hasMore = json.data.has_more;
			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var opt = {
		media_id: data.mediaId,
		pn: pn,
		ps: ps,
		keyword: data.keyword || "",
		order: data.order || "mtime",
		type: 0,
		tid: 0,
		platform: "web",
	};
	Request(idAPI.USER_FAV_RESOURCES, "GET", opt, s, f);
}

// BangumiPage
function GetBangumi(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeBangumi(json, data.model) === 0)
		{
			var page_data = __GetPageData(json.data || {}, ["num", "size", "total", null]);
			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var opt = {
		season_version: -1,
		area: -1,
		is_finish: -1,
		season_status: -1,
		season_month: -1,
		pub_date: -1,
		style_id: -1,

		copyright: -1,
		st: 1,
		season_type: 1,
		type: 1,

		sort: 0,
		pagesize: 20,
	};
	if(data.pageNo !== undefined)
		opt.page = data.pageNo;
	if(data.pageSize !== undefined)
		opt.pagesize = data.pageSize;
	if(data.order !== undefined)
		opt.order = data.order;
	if(data.sort !== undefined)
		opt.sort = data.sort;

	if(data.season_version !== undefined)
		opt.season_version = data.season_version;
	if(data.area !== undefined)
		opt.area = data.area;
	if(data.is_finish !== undefined)
		opt.is_finish = data.is_finish;
	if(data.season_status !== undefined)
		opt.season_status = data.season_status;
	if(data.season_month !== undefined)
		opt.season_month = data.season_month;
	if(data.pub_date !== undefined)
		opt.pub_date = data.pub_date;
	if(data.style_id !== undefined)
		opt.style_id = data.style_id;

	Request(idAPI.BANGUMI, "GET", opt, s, f);
}

// BangumiDetailPage
function GetBangumiDetail(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(data.season_model)
		{
			if(idAPI.MakeBangumiSeasons(json, data.season_model) !== 0)
				f(json.message);
		}

		if(data.episode_model)
		{
			if(idAPI.MakeBangumiEpisode(json, data.episode_model) !== 0)
				f(json.message);
		}

		var r = new Object();
		if(idAPI.MakeBangumiInfo(json, r) === 0)
		{
			if(typeof(success) === "function") success(r);
		}
		else
			f(json.message);
	};
	var opt = {
		season_id: data.sid,
	};
	Request(idAPI.BANGUMI_DETAIL, "GET", opt, s, f);
}

function GetBangumiRecommend(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeBangumiRecommend(json, data.model, data.limit) === 0)
		{
			if(typeof(success) === "function") success();
		}
		else
			f(json.message);
	};
	var opt = {
		season_id: data.sid,
	};
	Request(idAPI.BANGUMI_RECOMMEND, "GET", opt, s, f);
}

// LivePage
function GetLiveChannels(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeLiveChannels(json, data.model) === 0)
		{
			if(typeof(success) === "function") success(data.model);
		}
		else
			f(json.message);
	};
	Request(idAPI.LIVE_CHANNELS, "GET", undefined, s, f);
}

function GetLiveFollowing(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeLiveFollowing(json, data.model, data.limit) === 0)
		{
			var count = json.data.count !== undefined ? json.data.count : ModelSize(data.model);
			var page_data = __GetPageData({
				pageNo: data.pageNo || 1,
				pageSize: data.pageSize || 20,
				totalCount: count,
			}, ["pageNo", "pageSize", "totalCount", null]);
			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var opt = {
		page: data.pageNo || 1,
		page_size: data.pageSize || 20,
		platform: "web",
		ignoreRecord: 1,
		hit_ab: true,
	};
	Request(idAPI.LIVE_FOLLOWING, "GET", opt, s, f);
}

function GetLive(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var pn = data.pageNo ? data.pageNo : 1;
	var ps = data.pageSize ? data.pageSize : 20;
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeLive(json, data.model, data.limit) === 0)
		{
			var count = json.data.count !== undefined ? json.data.count : (json.data.total || 0);
			var fake_json_data = {
				"pageNo": pn,
				"pageSize": ps,
				"totalCount": count,
			};
			var page_data = __GetPageData(fake_json_data, ["pageNo", "pageSize", "totalCount", null]);
			if(typeof(success) === "function") success(page_data);
		}
		else
			f(json.message);
	};
	var opt = {
		page: pn,
		page_size: ps,
		parent_area_id: 0,
		cate_id: 0,
		area_id: 0,
		sort_type: "online",
		platform: "web",
		//tag_version: 1,
	};
	if(data.pid !== undefined)
		opt.parent_area_id = data.pid;
	if(data.cid !== undefined)
		opt.cate_id = data.cid;
	if(data.aid !== undefined)
		opt.area_id = data.aid;
	if(data.order !== undefined)
		opt.sort_type = data.order;
	Request(idAPI.LIVE_ROOMS, "GET", opt, s, f);
}

// LiveDetailPage
function GetLiveRecommend(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeLiveRecommend(json, data.model, data.limit) === 0)
		{
			if(typeof(success) === "function") success();
		}
		else
			f(json.message);
	};
	var opt = {
		room_id: data.rid,
		count: 8,
	};
	if(data.count !== undefined)
		opt.count = data.count;
	Request(idAPI.LIVE_RECOMMEND, "GET", opt, s, f);
}

function GetLiveDetail(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		var r = new Object();
		if(idAPI.MakeLiveRoomInfo(json, r) === 0)
		{
			if(typeof(success) === "function") success(r);
		}
		else
			f(json.message);
	};
	var opt = {
		room_id: data.rid,
	};
	Request(idAPI.LIVE_ROOM_DETAIL, "GET", opt, s, f);
}

function GetLiveUserDetail(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		var r = new Object();
		if(idAPI.MakeLiveUserInfo(json, r) === 0)
		{
			if(typeof(success) === "function") success(r);
		}
		else
			f(json.message);
	};
	var opt = {
		roomid: data.rid,
	};
	Request(idAPI.LIVE_USER, "GET", opt, s, f);
}

function GetLiveQualityStreams(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(data.quality_model)
		{
			if(idAPI.MakeLiveQualitys(json, data.quality_model, data.rid, data.nosort) === 0)
			{
				if(typeof(success) === "function") success();
			}
			else
				f(json.message);
		}

		if(data.stream_model)
		{
			if(idAPI.MakeLiveStreams(json, data.stream_model) === 0)
			{
				if(typeof(success) === "function") success();
			}
			else
				f(json.message);
		}
	};
	var opt = {
		cid: data.rid,
		quality: 32,
		platform: "web",
	};
	if(data.quality !== undefined)
		opt.quality = data.quality;
	Request(idAPI.LIVE_URL, "GET", opt, s, f);
}

// ArticlePage
function GetArticleDetail(data, success, fail)
{
	var s = function(r){
		if(typeof(success) === "function") success(r);
	};
	s(idAPI.M_ARTICLE_URL.arg(data.aid));
}

// PlayerPage
function GetVideoUrl(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeVideoUrl(json, data.model, data.quality) !== 0)
			fail(json.message);
		if(typeof(success) === "function") success();
	};
	var bvid = data.bvid || _UT.Av2Bv(data.aid);
	var qn = data.quality == 48 ? 64 : (data.quality || 64);
	Request(idAPI.PLAYURL.arg(bvid).arg(data.cid).arg(qn).arg(data.epid || ""), "GET", undefined, s, f);
}

function GetBangumiUrl(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeBangumiUrl(json, data.model, data.quality) !== 0)
			fail(json.message);
		if(typeof(success) === "function") success();
	};
	var qn = data.quality == 48 ? 64 : (data.quality || 64);
	Request(idAPI.BANGUMI_PLAYURL.arg(data.aid).arg(data.cid).arg(qn).arg(data.epid || ""), "GET", undefined, s, f);
}

function GetLiveUrl(data, success, fail)
{
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		var res = idAPI.CheckResponse(json);
		if(res !== 0)
		{
			f(res);
			return;
		}
		if(idAPI.MakeLiveUrl(json, data.model, data.cid) !== 0)
			fail(json.message);
		if(typeof(success) === "function") success();
	};
	var opt = {
		cid: data.aid,
		quality: data.cid,
		platform: "web",
	};
	Request(idAPI.LIVE_URL, "GET", opt, s, f);
}

function GetDanmaku(data, success, fail)
{
	var usingCPP = (typeof(data.parser) === "string" && data.parser.toUpperCase() === "JS");
	var f = function(message){
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(xml){
		var res = false;
		if(usingCPP)
		{
			var ds = _UT.MakeDanmaku_cpp(xml, data.limit);
			if(ds)
			{
				data.model = ds;
				res = true;
			}
		}
		else
		{
			var json = _UT.XML_Parse(xml);
			res = (idAPI.MakeDanmaku(json, data.model, data.limit) === 0);
		}
		if(res)
		{
			if(typeof(success) === "function") success();
		}
		else
			f(qsTr("Get danmaku data fail"));
	};
	Request(idAPI.DANMAKU_XML.arg(data.cid), "GET", undefined, s, f);
}

// history
function AddViewHistory(aid, title, preview, up, type)
{
	db.Insert(db.Table("view"), [null, aid, title, preview, up, type, Date.now()]);
}

function ViewHistoryCount()
{
	return db.Count(db.Table("view"));
}

function GetViewHistory(model)
{
	db.Select(db.Table("view"), model);
}

function RemoveViewHistory(tid)
{
	if(tid !== undefined)
		db.Delete(db.Table("view"), "tid", tid.toString());
	else
		db.Drop(db.Table("view"));
}

// keyword
function AddKeywordHistory(kw)
{
	if(!kw) return;
	var text = kw.trim();
	if(text === "") return;
	db.Insert(db.Table("keyword"), [null, text, Date.now()]);
}

function KeywordHistoryCount()
{
	return db.Count(db.Table("keyword"));
}

function GetKeywordHistory(model)
{
	db.Select(db.Table("keyword"), model);
}

function RemoveKeywordHistory(keyword)
{
	if(keyword !== undefined)
		db.Delete(db.Table("keyword"), "keyword", "'" + keyword.replace(/'/g, "''") + "'");
	else
		db.Drop(db.Table("keyword"));
}

// other
function __GetPageData(obj, props)
{
	var r = {
		pageNo: 1,
		pageSize: 0,
		pageCount: 0,
		totalCount: 0,
	};
	if(obj)
	{
		if(props[0]) r.pageNo = obj[props[0]] || r.pageNo;
		if(props[1]) r.pageSize = obj[props[1]] || r.pageSize;
		if(props[2]) r.totalCount = obj[props[2]] || r.totalCount;

		if(props[3])
			r.pageCount = obj[props[3]] || r.pageCount;
		else
			r.pageCount = r.pageSize !== 0 ? Math.ceil(r.totalCount / r.pageSize) : 0;
	}
	return r;
}

// test
function TEST(data, success, fail)
{
	var f = function(message){
		console.log(message);
		if(typeof(fail) === "function")
			fail(message);
	};
	var s = function(json){
		console.log(JSON.stringify(json));
		if(typeof(success) === "function") success(json);
	};
	var room_id = data.id;
	var api_url = "http://www.douyutv.com/api/v1/";
	var	args = "room/%1?aid=wp&client_sys=wp&time=%2".arg(room_id).arg((Date.now() / 1000).toString());
	var	auth_md5 = (args + "zNzMV1y4EMxOHS6I5WKm"); //.encode("utf-8")
	var auth_str = Qt.md5(auth_md5);
	var json_request_url = "%1%2&auth=%3".arg(api_url).arg(args).arg(auth_str);

	var url = json_request_url;
	console.log(url);
	Request(url, "GET", undefined, s, f);
}
