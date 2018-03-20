$(document).ready(function(){
	var u = url();
	if(!is_wxqq()){$("#share").text("分享: "+u.u);}
	joke();
	if(document.referrer=="http://kkn.anet6.cc/"){
		$("#cc").hide();
	}else{
		$('#cc').on('click', function(){
			if($('#cc').text()=="看看"){
				read(u.m, u.p);
				$('#cc').text("闭上眼睛");
			}else{
				window.location.href = "http://kkn.anet6.cc#"+(new Date().getTime());
			}
		});
	}
});

function is_wxqq(){
	var ua = navigator.userAgent.toLowerCase();
	if (ua.indexOf('micromessenger')!=-1) {return true;
	}else if(ua.indexOf('mqqbrowser')!=-1){return true;
	}else{return false;}
}

function url(){
	Url = window.location.href;
	var a = Url.split('#');
	p = a[1];
	var b = a[0].split('?'); 
	var c = b[1].split('&');
	var d = c[0].split('=');
	m = d[0];
	u = "http://kkn.anet6.cc/l?"+m+"#"+p;
	return {
		'u':u,
		'p':p,
		'm':m
	};
}
function read(MsgId, Password){
	$.ajax({
		url:"/api/get/"+MsgId,
		type:"GET",
		dataType:"json",
		success:function(Data, Status){
			if(Data.msg != undefined){
				MsgB64 = Data.msg;
				NonceB64 = Data.nonce;
				SecretB64 = Password;
				if(Data.read == 0){
					Word1 = "唯一知情者";
					$("#sharetip").hide();
				}else{
					Already = 10000000 - Data.read;
					Word1 = "第"+Already+"名看客"
				}
				Word = "你是第"+Data.v+"个看到自己的人!";
				Msg = nacl.util.decodeBase64(MsgB64);
				Non = nacl.util.decodeBase64(NonceB64);
				Sec = nacl.util.decodeBase64(SecretB64);
				PlainAgainUtf = nacl.secretbox.open(Msg, Non, Sec);
				PlainAgain = nacl.util.encodeUTF8(PlainAgainUtf);
				$('#message').text(PlainAgain);
				$('#read').text(Word1);
				$('#view').text(Word);
				$('.hide').show();
			}else{
				$("#message").text("!@#$%^&*()(*&^%$#@$%^&^%^&*");
				$("#mbody").attr("class", "w3-panel w3-large w3-pale-red w3-leftbar w3-rightbar w3-border-blue hide");
				$("#read").text("有给一个人看的消息，有会过期的消息！");
				$("#view").text("迟到的人一无所获");
				$("#sharetip").hide();
				$('.hide').show();
			}

		}
	});
}

function joke(){
	$.ajax({
		url:"/api/play",
		type:"GET",
		dataType: "text",
		success:function(Data, Status){
			$("#joke").text(Data);
			$("title").text(Data);
		}
	});
}
/*
wx.config({
	debug:true,
	appId:"wx36b30a5049b7d633";
});
var imgUrl="http://kkn.anet6.cc/eye.png";
var lineLink="http://kkn.anet6.cc";
var descContent = "我们需要你看看";
var shareTitle="看看你";
function shareFriend(){
	WeixinJSBridge.invoke('sendAppMessage', {
		"appid": appid,
		"img_url":imgUrl,
		"img_width":"200",
		"img_height":"200",
		"link":lineLink,
		"desc":descContent,
		"title":shareTitle
	}, function(res){
	});
}
function shareTimeline() {
	WeixinJSBridge.invoke('shareTimeline',{
		"img_url": imgUrl,
		"img_width": "200",
		"img_height": "200",
		"link": lineLink,
		"desc": descContent,
		"title": shareTitle
	}, function(res) {
		//_report('timeline', res.err_msg);
	});
}
function shareWeibo() {
	WeixinJSBridge.invoke('shareWeibo',{
		"content": descContent,
		"url": lineLink,
	}, function(res) {
		//_report('weibo', res.err_msg);
	});
}

document.addEventListener('WeixinJSBridgeReady', function onBridgeReady(argv){
	WeixinJSBridge.on('menu:share:appmessage', function(argv){
		alert("here");
		shareFriend();
	});
	WeixinJSBridge.on('menu:share:timeline', function(argv){
		alert("send to timeline");
	});
	WeixinJSBridge.on('menu:share:weibo', function(argv){
		alert("send to weibo");
	});
}, false);

*/
