$(document).ready(function(){
	$('#cc').on('click', function(){
		if(check()==false){return false;}
		encrypt(1, $("#plain").val());
	});
	$('#tt').on('click', function(){
		if(check()==false){return false;}
		encrypt(9999, $("#plain").val());
	});
	var clipboard = new Clipboard('.btn');
	clipboard.on('success', function(e){g()});
	clipboard.on('error', function(e){$("#copyresult").text("复制失败");});
});
function g(){self.location=$('#url').val();}
function check(){
	if($("#plain").val()!="")return true;
	return false;
}
function encrypt(Read, Plain){
	Secret = nacl.randomBytes(nacl.secretbox.keyLength);
	SecretB64 = nacl.util.encodeBase64(Secret);
	Nonce = nacl.randomBytes(nacl.secretbox.nonceLength);
	NonceB64 = nacl.util.encodeBase64(Nonce);
	PlainUtf = nacl.util.decodeUTF8(Plain);
	Cipher = nacl.secretbox(PlainUtf, Nonce, Secret);
	CipherB64 = nacl.util.encodeBase64(Cipher);
	post(Read, CipherB64, NonceB64, SecretB64);
}
function post(Read, Cipher, Nonce, Secret){
	if(Read==1){
		TTL = 3000;
	}else{
		READ = 10000000;
		TTL = 600;
	}
	$.ajax({
		url:"/api/post",
		type:"POST",
		data: JSON.stringify({msg:Cipher, nonce:Nonce, read:Read, ttl:TTL}),
		contentType:"application/json; charset=utf-8",
		dataType:"json",
		success:function(Data, Status){
			TTL = Data.ttl;
			$('.hide').show();
			$("#url").text("http://kkn.anet6.cc/l?"+Data.msgid+"#"+Secret).autoHeight();
			$("#total").text("您是第"+N+"个想看的人！");
		}
	});
}

function concatenate(resultConstructor, ...arrays) {
	let totalLength = 0;
	for (let arr of arrays) {totalLength += arr.length;}
	let result = new resultConstructor(totalLength);
	let offset = 0;
	for (let arr of arrays) {result.set(arr, offset);offset += arr.length;}
	return result;
}
jQuery.fn.extend({
	autoHeight: function(){
		return this.each(function(){
			var $this = jQuery(this);
			if( !$this.attr('_initAdjustHeight') ){
				$this.attr('_initAdjustHeight', $this.outerHeight());
			}
			_adjustH(this).on('input', function(){
				_adjustH(this);
			});
		});
		function _adjustH(elem){
			var $obj = jQuery(elem);
			return $obj.css({height: $obj.attr('_initAdjustHeight'), 'overflow-y': 'hidden'})
				.height( elem.scrollHeight );
		}
	}
});

