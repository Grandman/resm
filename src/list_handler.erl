-module(list_handler).
-behaviour(cowboy_http_handler).

-export([init/3, handle/2, terminate/3]).

init(Type, Req, _Opts) ->
  {ok, Req, no_state}.

handle(Req, State) ->
    {ok, Req2} = cowboy_req:reply(200, [
      {<<"content-type">>, <<"text/plain">>}
    ], <<"ololo">>,Req),
    {ok, Req2, State}.

terminate(_Reason, Req, State) ->
    ok.
