-module(reset_handler).
-behaviour(cowboy_http_handler).

-export([init/3, handle/2, terminate/3]).

-define(TEXT_CONTENT_TYPE, {<<"content-type">>, <<"text/plain; charset=utf-8">>}).

init(_Type, Req, _Opts) ->
  {ok, Req, no_state}.

handle(Req, State) ->
  ok = resm:reset(),
  {ok, Req2} = cowboy_req:reply(204, [?TEXT_CONTENT_TYPE],
                                "", Req),
  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.
