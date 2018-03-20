-module(a_bra).
-include_lib("liberl/include/liberl.hrl").
-export([post/1]).
-export([get_msg/2]).
-export([test_post/1]).
-define(TIMEOUT, 3600*6).
-define(TIMEOUT_ONCE, 3600*24).

rnd_key(Length)->
	F=fun(Len, AllowedChars) ->    lists:foldl(fun(_, Acc) -> [lists:nth(rand:uniform(length(AllowedChars)),  AllowedChars)]  ++ Acc  end, [], lists:seq(1, Len)) end,
	F(Length, "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").


test_post(Req)->
	Msg = "Hello Test",
	MsgId = rnd_key(20),
	m:save_msg(MsgId, Msg, ?TIMEOUT),
	TTL = m:ttl_msg(MsgId),
	ReturnJson = [
		      {"msgid", ?U(MsgId)},
		      {"ttl", TTL}
		     ],
	j:json(Req, ReturnJson).

post(Req)->
	?B(post),
	{ok, Data, _Opt} = cowboy_req:read_body(Req),
	?B(Data),
	true = size(Data)<16384,
	{struct, Json} = ?JSON_DECODE(Data),
	?B(Json),
	Msg = ?GETVALUES(<<"msg">>, Json),
	_TTL = ?GETVALUE(<<"ttl">>, Json),
	Read = ?GETVALUE(<<"read">>, Json),
	Nonce = ?GETVALUES(<<"nonce">>, Json),

	MsgId = rnd_key(20),
	?B(MsgId),
	case Read of
		1 ->
			m:save_msg(MsgId, Msg, Nonce, ?TIMEOUT_ONCE),
			m:set_read(MsgId, Read, ?TIMEOUT_ONCE+600);
		_ ->
			m:save_msg(MsgId, Msg, Nonce, ?TIMEOUT),
			m:set_read(MsgId, 10000000, ?TIMEOUT+600)
	end,
	Number = m:incr_new(),
	Left = m:ttl_msg(MsgId),
	ReturnJson = [
		      {"msgid", ?U(MsgId)},
		      {"ttl", Left},
		      {"n", Number}
		     ],
	j:json(Req, ReturnJson).

get_msg(Req, MsgId)->
	Number = m:incr_view(),
	ReturnJson = case m:get_read(MsgId) of
		0 ->
			[{"msgid", ?U(MsgId)},
			 {"ttl", m:ttl_msg(MsgId)},
			 {"read", 0}];
		Read ->
			case m:get_msg(MsgId) of
				failed ->
					[{"msgid", ?U(MsgId)},
					 {"ttl", -1},
					 {"read", Read}];
				{Msg, Nonce} ->
					Read2 = case m:decr_read(MsgId) of
						0 ->
							m:del_msg(MsgId),
							0;
						N ->
							N
					end,
					[{"msgid", ?U(MsgId)},
					 {"msg", ?U(Msg)},
					 {"nonce", ?U(Nonce)},
					 {"ttl", m:ttl_msg(MsgId)},
			 		 {"v", Number},
					 {"read", Read2}]
			end
	end,
	j:json(Req, ReturnJson).
