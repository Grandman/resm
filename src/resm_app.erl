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
     {"/list", list_handler, []},
     {'_', not_found_handler, []}
   ]}]),

    {ok, _} = cowboy:start_http(?MODULE, 100, [{port, 8080}],
        [{env, [{dispatch, Dispatch}]}]
   ),
    resm:start_link(6),
    resm_sup:start_link().
%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
