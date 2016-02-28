%%%-------------------------------------------------------------------
%% @doc resm public API
%% @end
%%%-------------------------------------------------------------------

-module(resm_app).

%-behaviour(application).

%% Application callbacks
-export([start/2
        ,stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([{'_',[
      {"/allocate/:user", allocate_handler, []},
      {"/deallocate/:resource", deallocate_handler, []},
      {"/list/[:user]", list_handler, []},
      {"/reset", reset_handler, []},
      {'_', not_found_handler, []}
    ]}]),

    {ok, Port} = application:get_env(resm, port),
    {ok, _} = cowboy:start_http(?MODULE, 100, [{port, Port}],
      [{env, [{dispatch, Dispatch}]}]
    ),
    {ok, ResourcesNumber} = application:get_env(resm, resources_number),
    resm:start_link(ResourcesNumber),
    resm_sup:start_link().
%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
