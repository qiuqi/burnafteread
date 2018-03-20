-module(m).
-export([del_msg/1, get_msg/1, save_msg/4, ttl_msg/1]).
-export([set_read/3, get_read/1, decr_read/1]).
-export([incr_new/0, incr_view/0]).
-include_lib("liberl/include/liberl.hrl").
-include("bar.hrl").

-define(MSG(F), "msg:"++F).
-define(READ(F), "read:"++F).


incr_new()->
	db:incr(?R_TEMP, "number.new").

incr_view()->
	db:incr(?R_TEMP, "number.view").


del_msg(MsgId)->
	db:del(?R_TEMP, ?MSG(MsgId)).

get_msg(MsgId)->
	case db:get(?R_TEMP, ?MSG(MsgId)) of
		failed ->
			failed;
		MsgBin ->
			binary_to_term(MsgBin)
	end.

get_read(MsgId)->
	case db:get(?R_TEMP, ?READ(MsgId)) of
		failed ->
			0;
		NumBin ->
			binary_to_integer(NumBin)
	end.

decr_read(MsgId) ->
	case db:decr(?R_TEMP, ?READ(MsgId)) of
		{ok, N} ->
			N;
		Raw ->
			Raw
	end.


save_msg(MsgId, Msg, Nonce, Timeout)->
	db:setex(?R_TEMP, ?MSG(MsgId), term_to_binary({Msg, Nonce}), Timeout).

set_read(MsgId, Read, Timeout)->
	db:setex(?R_TEMP, ?READ(MsgId), Read, Timeout).

ttl_msg(MsgId)->
	case db:ttl(?R_TEMP, ?MSG(MsgId)) of
		-1 ->
			-1;
		Time ->
			?B(Time),
			Time;
		{ok, Time} ->
			Time
	end.
