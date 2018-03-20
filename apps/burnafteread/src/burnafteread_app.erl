%%%-------------------------------------------------------------------
%% @doc burnafteread public API
%% @end
%%%-------------------------------------------------------------------

-module(burnafteread_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-include_lib("liberl/include/liberl.hrl").

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	?B("Let's play it!"),
	Dispatch = cowboy_router:compile([
					  {'_', [
						 {"/", cowboy_static, {priv_file, burnafteread, "www/index.html"}},
						 {"/i", cowboy_static, {priv_file, burnafteread, "www/index.html"}},
						 {"/s", cowboy_static, {priv_file, burnafteread, "www/s", [{mimetypes, {<<"text">>, <<"html">>, []}}]}},
						 {"/l", cowboy_static, {priv_file, burnafteread, "www/l", [{mimetypes, {<<"text">>, <<"html">>, []}}]}},
						 {"/api/[...]", url, []},
						 {"/[...]", cowboy_static, {priv_dir, burnafteread, "www", [{mimetypes, cow_mimetypes, all}]}}
						]}
					 ]),
	PrivDir = code:priv_dir(burnafteread),
	?B(PrivDir),
	{ok, _} = cowboy:start_clear(http, [
					    {port, 80}
					   ],
				     #{
				       env => #{dispatch => Dispatch},
				       request_timeout => 6000
				      }),
	{ok, _} = cowboy:start_tls(https, [{port, 443},
					    {cacertfile, PrivDir++"/ssl/ca.crt"},
					    {certfile, PrivDir++"/ssl/server.crt"},
					    {keyfile, PrivDir++"/ssl/server.key"}
					   ],
				     #{
				       env => #{dispatch => Dispatch},
				       request_timeout => 6000,
				       idle_timeout => 3000
				      }),
	?B("https start working ..."),
	burnafteread_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
	ok.

%%====================================================================
%% Internal functions
%%====================================================================
