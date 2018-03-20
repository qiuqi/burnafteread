$(document).ready(function(){
	empty();

	$('#sendmsg').on('click', function(){ 
		post();
	}); 
	$('#workitout').on('click', function(){
		read();
	});
});

function encrypt(){
	Plain = $("#plain").val();
	if(Plain==""){
		alert("请输入要加密的文字");
		return;
	}
	Secret = nacl.randomBytes(nacl.secretbox.keyLength);
	SecretB64 = nacl.util.encodeBase64(Secret);
	Nonce = nacl.randomBytes(nacl.secretbox.nonceLength);
	NonceB64 = nacl.util.encodeBase64(Nonce);
	$("#nonce").val(NonceB64);
	$("#secret").val(SecretB64);
	Plain = $("#plain").val();
	PlainUtf = nacl.util.decodeUTF8(Plain);
	Cipher = nacl.secretbox(PlainUtf, Nonce, Secret);
	CipherB64 = nacl.util.encodeBase64(Cipher);
	$("#cipher").val(CipherB64);
}

function empty(){
	$("#plain").val("");
	$("#nonce").val("");
	$("#secret").val("");
	$("#cipher").val("");
	$("#msgid").val("");
	$("#decrypt").val("");
	$("#url").val("");
}

function read(){
	$.ajax({
		url:"/api/get/"+$("#msgid").val(),
		type:"GET",
		dataType:"json",
		success:function(Data, Status){
			MsgId = Data.msgid;
			if(Data.msg != undefined){
				MsgB64 = Data.msg;
				NonceB64 = Data.nonce;
				SecretB64 = $("#secret").val();
				Msg = nacl.util.decodeBase64(MsgB64);
				Non = nacl.util.decodeBase64(NonceB64);
				Sec = nacl.util.decodeBase64(SecretB64);
				PlainAgainUtf = nacl.secretbox.open(Msg, Non, Sec);
				PlainAgain = nacl.util.encodeUTF8(PlainAgainUtf);
				$("#decrypt").val(PlainAgain);
				$("#read").val(Data.read);
			}else{
				alert("消息已经过期");
			}

		}
	});

}
function post(){
	Type = $('input:radio[name=type]:checked').val();
	encrypt();
	if(Type==1){
		READ = 1;
		TTL = 3000;
	}else{
		READ = 10000000;
		TTL = 600;
	}
	$.ajax({
		url:"/api/post",
		type:"POST",
		data: JSON.stringify(
				{msg:$("#cipher").val(), nonce:$("#nonce").val(), read:READ, ttl:TTL}
				),
		contentType:"application/json; charset=utf-8",
		dataType:"json",
		success:function(Data, Status){
			MsgId = Data.msgid;
			TTL = Data.ttl;
			$("#msgid").val(MsgId);
			Url = "http://kkn.anet6.cc/l?"+MsgId+"#"+$("#secret").val();
			$("#url").val(Url);
		}
	});
}

function concatenate(resultConstructor, ...arrays) {
	let totalLength = 0;
	for (let arr of arrays) {
		totalLength += arr.length;
	}
	let result = new resultConstructor(totalLength);
	let offset = 0;
	for (let arr of arrays) {
		result.set(arr, offset);
		offset += arr.length;
	}
	return result;
}
