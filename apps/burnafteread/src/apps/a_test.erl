-module(a_test).
-include_lib("liberl/include/liberl.hrl").
-export([test/1]).

test(Req)->
	?B("test module"),
	?B("test for sync"),
	?HTTP_OK(Req).
