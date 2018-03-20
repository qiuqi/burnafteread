-module(url).
-author('Mada <madafoo@gmail.com>').
-include_lib("liberl/include/liberl.hrl").

-export([init/2]).
-export([info/3]).

init(Req, Opts) ->
	Path = cowboy_req:path(Req),
	Method = cowboy_req:method(Req),
	case Method of
		<<"GET">> ->
			ListPath = binary_to_list(Path),
			case string:tokens(ListPath, "/") of
				["v1", "longpull", Uid] -> commapi:longpull(Req, list_to_binary(Uid), Opts);
				_ ->
					handle(Method, Path, Req, Opts)
			end;
		<<"POST">> ->
			case Path of
				<<"/v2/getmessage/", _Mixun/binary>> ->
					commapi:comet(Req, Opts);
				_ ->
					handle(Method, Path, Req, Opts)
			end;
		_ ->
			handle(Method, Path, Req, Opts)
	end.

handle(Method, Path, Req, Opts) ->
	{PeerIp, _PeerPort} = cowboy_req:peer(Req),
	?B([inet_parse:ntoa(PeerIp), Method, Path, Opts]),
	try
		case Method of
			<<"GET">> ->
				http_get_dispatch(Path, Req, Opts);
			<<"POST">> ->
				?B(Path),
				http_post_dispatch(Path, Req, Opts);
			_ ->
				not_found(Req)
		end
	catch
		Type:What ->
			?B([Type, What, Path, erlang:get_stacktrace()]),
			j:jsonFailed(Req)
	end.

http_get_dispatch(Path, Req, _Opts) ->
	ListPath = binary_to_list(Path),
	case string:tokens(ListPath, "/") of
		["api", "play"] -> a_play:play(Req);
		["api", "get", MsgId] -> a_bra:get_msg(Req, MsgId);
		["api", "test"] ->a_test:test(Req);
		["api", "test", "post"] -> a_bra:test_post(Req);
		Url ->
			?B([Url, "not found"]),
			not_found(Req)
	end.

http_post_dispatch(Path, Req, _Opts) ->
	?B(Path),
	case Path of
		<<"/api/post">> -> a_bra:post(Req);
		Url ->
			?B([Url, "not found"]),
			not_found(Req)
	end.

info(eof, Req, Opts) ->
	{stop, Req, Opts};
info({_, _Key, {ok, Message}}, Req, Opts) ->
	commapi:handle_message(Req, Message, Opts);
info({keepalive, Keepalive}, Req, Opts) ->
	http_resp:stream_body(Req, Keepalive, Opts),
	erlang:send_after(1000, self(), {keepalive, <<"Keepalive">>}),
	{ok, Req, Opts}.

not_found(Req) ->
	Req1 = cowboy_req:reply(404, #{}, <<"<h1>404</h1>">>, Req),
	{ok, Req1}.

