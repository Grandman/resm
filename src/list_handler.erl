-module(list_handler).
-behaviour(cowboy_http_handler).

-export([init/3, handle/2, terminate/3]).

-define(JSON_CONTENT_TYPE, {<<"content-type">>, <<"application/json; charset=utf-8">>}).

init(_Type, Req, _Opts) ->
  {User, Req2} = cowboy_req:binding(user, Req),
  {ok, Req2, {user, User}}.

handle(Req, {user, undefined}) ->
  {ok, Resources} = resm:list(),
  {ok, Req2} = cowboy_req:reply(200, [?JSON_CONTENT_TYPE],
                                jsx:encode(empty_allocated_to_list(Resources)), Req),
  {ok, Req2, {user, undefined}};

handle(Req, {user, User}) ->
  {ok, Resources} = resm:list(User),
  {ok, Req2} = cowboy_req:reply(200, [?JSON_CONTENT_TYPE],
                                jsx:encode(Resources), Req),
  {ok, Req2, {user, User}}.

terminate(_Reason, _Req, _State) ->
  ok.

empty_allocated_to_list(#{allocated := Allocated, deallocated := Deallocated}) when map_size(Allocated) == 0 ->
  #{allocated => [], deallocated => Deallocated};
empty_allocated_to_list(Resources) ->
  Resources.
