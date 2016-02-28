-module(deallocate_handler).
-behaviour(cowboy_http_handler).

-export([init/3, handle/2, terminate/3]).

-define(TEXT_CONTENT_TYPE, {<<"content-type">>, <<"text/plain; charset=utf-8">>}).

init(_Type, Req, _Opts) ->
  {Resource, Req2} = cowboy_req:binding(resource, Req),
  {ok, Req2, {resource, binary_to_atom(Resource, utf8)}}.

handle(Req, {resource, Resource}) ->
  case resm:deallocate(Resource) of
    ok ->
      {ok, Req2} = cowboy_req:reply(204, [?TEXT_CONTENT_TYPE], "", Req);
    {error, not_allocated} ->
      {ok, Req2} = cowboy_req:reply(404, [?TEXT_CONTENT_TYPE], <<"Not allocated">>, Req)
  end,
  {ok, Req2, {resource, Resource}}.

terminate(_Reason, _Req, _State) ->
  ok.
