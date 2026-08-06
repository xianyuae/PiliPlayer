.pragma library

function RandColor(alpha)
{
    var a = typeof(alpha) === "number" ? alpha : 1.0;
    return Qt.rgba(Math.random(), Math.random(), Math.random(), a);
}

function ModelClear(model)
{
	if(Array.isArray(model))
		model = [];
	else
		model.clear();
}

function ModelSize(model)
{
	var length = Array.isArray(model) ? "length" : "count";
	return model[length];
}

var ModelCount = ModelSize;

function ModelPush(model, element)
{
	var push = Array.isArray(model) ? "push" : "append";
	model[push](element);
}

function ModelGet(model, i)
{
	if(Array.isArray(model))
		return model[i];
	else
		return model.get(i);
}

function ModelGetValue(model, i, name)
{
	if(Array.isArray(model))
		return model[i][name];
	else
		return model.get(i)[name];
}

function ModelSetValue(model, i, name, value)
{
	if(Array.isArray(model))
		model[i][name] = value;
	else
		model.get(i)[name] = value;
}

function ModelForeach(model, func)
{
	var len = ModelSize(model);
	for(var i = 0; i < len; i++)
	{
		func(ModelGet(model, i), i);
	}
}

function ModelRemove(model, i)
{
	if(Array.isArray(model))
		model.splice(i, 1);
	else
		model.remove(i);
}

function ModelCopy(dst, src)
{
	ModelClear(dst);
	ModelForeach(src, function(e, i){
		ModelPush(dst, e);
	});
}



function GetSize(w, h, p)
{
	var percent = p === "16/9" ? 16 / 9 : (p === "16/10" ? 16 / 10 : 4 / 3);
	if(w)
		return w * (1 / percent);
	if(h)
		return h * (percent);
	return 0;
}

function FormatDuration(seconds)
{
	var sec = Math.max(0, Math.floor(seconds));
	var r = "";
	var s = sec % 60;
	var m = parseInt(sec % 3600 / 60);
	var h = parseInt(sec / 3600);
	if(h !== 0)
		r += (h < 10 ? "0" : "") + h + ":";
	r += (m < 10 ? "0" : "") + m + ":";
	r += (s < 10 ? "0" : "") + s;
	return r;
}

function FormatDateTime(ts, dt)
{
	var ndt = typeof(dt) === "string" ? dt.toUpperCase() : "DATETIME";
	var d = new Date(ts * 1000);
	switch(ndt)
	{
		case "DATE":
			return Qt.formatDate(d, "yyyy-MM-dd");
		case "TIME":
			return Qt.formatTime(d, "hh:mm:ss");
		case "DATETIME":
		default:
			return Qt.formatDateTime(d, "yyyy-MM-dd hh:mm:ss");
	}
}

function FormatTimestamp(sec)
{
	var now = Date.now() / 1000;
	var diff = now - sec;
	var p = 1;
	var Rules = [
	{ limit: 60, name: qsTr(" seconds "), },
	{ limit: 3600, name: qsTr(" minutes "), },
	{ limit: 86400, name: qsTr(" hours "), },
		{ limit: 2592000, name: qsTr(" days "), },
		{ limit: 31104000, name: qsTr(" months "), },
			// { limit: 62208000, name: qsTr("years"), },
	];
	for(var i in Rules)
	{
		if(diff < Rules[i].limit)
		{
			return "%1%2%3".arg(parseInt(diff / p)).arg(Rules[i].name).arg(qsTr("ago"));
		}
		p = Rules[i].limit;
	}
	return FormatDateTime(sec, "DATE");
}

function FormatCount(c)
{
	var Rules = [
	{ limit: 100000000, name: qsTr("HM"), },
	{ limit: 10000, name: qsTr("W"), },
	];
	for(var i in Rules)
	{
		if(c >= Rules[i].limit)
		{
			return "%1%2".arg((c / Rules[i].limit).toFixed(1)).arg(Rules[i].name);
		}
	}
	return c.toString();
}

var _MaterialIconMap = {
	"toolbar-back": "arrow_back",
	"toolbar-close": "close",
	"toolbar-view-menu": "menu",
	"toolbar-refresh": "refresh",
	"toolbar-done": "done",
	"toolbar-edit": "edit",
	"toolbar-list": "view_list",
	"toolbar-grid": "grid_view",
	"toolbar-gallery": "photo_library",
	"toolbar-new-chat": "chat",
	"toolbar-chat": "chat",
	"toolbar-previous": "chevron_left",
	"toolbar-next": "chevron_right",
	"toolbar-up": "arrow_upward",
	"toolbar-down": "arrow_downward",
	"toolbar-tab-previous": "chevron_left",
	"toolbar-tab-next": "chevron_right",
	"toolbar-stop": "stop",
	"toolbar-search": "search",
	"toolbar-pages-all": "web",
	"toolbar-mediacontrol-play": "play_arrow",
	"toolbar-mediacontrol-pause": "pause",
	"toolbar-mediacontrol-previous": "skip_previous",
	"toolbar-mediacontrol-next": "skip_next",
	"toolbar-mediacontrol-stop": "stop",
	"toolbar-settings": "settings",
	"toolbar-home": "home",
	"toolbar-alarm": "live_tv",
	"toolbar-live-tv": "live_tv",
	"toolbar-favorite-mark": "favorite",
	"toolbar-favorite-star": "star",
	"toolbar-thumb-up": "thumb_up",
	"toolbar-thumb-down": "thumb_down",
	"toolbar-coin": "paid",
	"toolbar-schedule": "schedule",
	"toolbar-video": "smart_display",
	"toolbar-logout": "logout",
	"toolbar-power": "power_settings_new",
	"toolbar-rank": "leaderboard",
	"toolbar-new": "fiber_new",
	"toolbar-trending": "trending_up",
	"toolbar-category": "category",
	"toolbar-online": "visibility",
	"toolbar-application": "info",
	"toolbar-directory": "history",
	"toolbar-jump-to": "terminal",
	"toolbar-share": "share"
};

function HandleIconFile(iconId, inverted)
{
	var key = String(iconId || "");
	if(key.indexOf("icon-m-") === 0)
	{
		key = key.substring(7);
		if(key.indexOf("-white") === key.length - 6)
			key = key.substring(0, key.length - 6);
		if(key.indexOf("toolbar-") !== 0)
			key = "toolbar-" + key;
	}
	var name = _MaterialIconMap[key] || "help";
	return name + (inverted ? "_white" : "_black") + ".svg";
}

function Bind(src, pro_src, dst, pro_dst)
{
	var f = function(){
		dst[pro_dst] = src[pro_src];
	};
	src[pro_src + "Changed"].connect(f);
	return f;
}

function Unbind(src, pro_src, func)
{
	src[pro_src + "Changed"].disconnect(func);
}

function IsFunction(v)
{
	return typeof(v) === "function";
}

function Science(n)
{
	var i = Math.floor(Math.log(n) / Math.LN10);
	return "" + n * Math.pow(10, -i) + "e" + i;
}

function Print_r(v)
{
	var t = typeof(v);
	switch(t)
	{
		case "number":
			console.log(v, t, v.toString(16) + "(16) " + v.toString(2) + "(2) " + v.toString(8) + "(8) " + Science(v) + "(E)");
			break;
		case "string":
			console.log(v, t + "[" + v.length + "]");
			break;
		case "object":
			if(v)
			{
				if(Array.isArray(v))
					console.log(JSON.stringify(v), "array" + "[" + v.length + "]");
				else
					console.log(JSON.stringify(v), t);
			}
			else
				console.log("NULL");
			break;
		case "function":
			console.log(v, t);
			break;
		case "undefined":
			console.log("UNDEFINED");
			break;
		default:
			console.log(v, t);
			break;
	}
}

function GetElementsByTagName(obj, name)
{
	if(!obj || !name)
		return null;

	var doc = obj.documentElement || obj;
	if(!doc)
		return null;

	var r = [];
	var f = function(o, n, arr)
	{
		if(!o || !n || !arr)
			return;
		if(o.tagName && o.tagName === n)
		{
			arr.push(o);
		}

		if(Array.isArray(o.childNodes))
		{
			for(var i in o.childNodes)
			{
				f(o.childNodes[i], n, arr);
			}
		}
	}

	f(doc, name, r);
	return r;
}
