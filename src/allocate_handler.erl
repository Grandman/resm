-module(allocate_handler).
-behaviour(cowboy_http_handler).

-export([init/3, handle/2, terminate/3]).

-define(TEXT_CONTENT_TYPE, {<<"content-type">>, <<"text/plain; charset=utf-8">>}).

init(Type, Req, _Opts) ->
  {User, Req2} = cowboy_req:binding(user, Req),
  {ok, Req2, {user, User}}.

handle(Req, {user, User}) ->
  case resm:allocate(User) of
    {ok, Resource} ->
      {ok, Req2} = cowboy_req:reply(201, [?TEXT_CONTENT_TYPE], atom_to_list(Resource), Req);
    {error, out_of_resources} ->
      {ok, Req2} = cowboy_req:reply(503, [?TEXT_CONTENT_TYPE], <<"Out of resources">>, Req)
  end,
  {ok, Req2, {user, User}}.

terminate(_Reason, _Req, _State) ->
  ok.
