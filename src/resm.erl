-module(resm).
-behavior(gen_server).
-export([allocate/1, deallocate/1, list/0, list/1,
         init/1, stop/1, reset/0, start_link/1, handle_call/3,
         handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

allocate(User) ->
  gen_server:call(?SERVER, {allocate, User}).

deallocate(Resource) ->
  gen_server:call(?SERVER, {deallocate, Resource}).

list() ->
  gen_server:call(?SERVER, list).

list(User) ->
  gen_server:call(?SERVER, {list, User}).

reset() ->
  gen_server:call(?SERVER, reset).

init([ResourceCount]) ->
  {ok, #{allocated => #{}, deallocated => [convert_resource_name(X)|| X <- lists:seq(1, ResourceCount)]}}.

start_link(ResourceCount) when ResourceCount =< 0 ->
  {error, resource_count_incorrect};

start_link(ResourceCount) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [ResourceCount], []).

stop(Pid) ->
  gen_server:stop(Pid).

handle_call({allocate, _User}, _From, #{allocated := _Allocated, deallocated := []} = Resources) ->
  {reply, {error, out_of_resources}, Resources};

handle_call({allocate, User}, _From, #{allocated := Allocated, deallocated := [FreeResource | Tail]}) ->
  {reply, {ok, {resource, FreeResource}}, #{allocated => maps:put(FreeResource, User, Allocated), deallocated => Tail}};

handle_call({deallocate, Resource}, _From, #{allocated := Allocated, deallocated := Deallocated} = Resources) ->
  case maps:find(Resource, Allocated) of
    {ok, _} -> {reply, ok, #{allocated => maps:remove(Resource, Allocated), deallocated => [Resource | Deallocated]}};
    _ -> {reply, {error, not_allocated}, Resources}
  end;

handle_call(list, _From, Resources) ->
  {reply, {ok, {resources, Resources}}, Resources};

handle_call({list, User}, _From, #{allocated := Allocated, deallocated := _Deallocated} = State) ->
  {reply, {ok, {resources, allocated_by_user(User, Allocated)}}, State};

handle_call(reset, _From, #{allocated := Allocated, deallocated := Deallocated}) ->
  {reply, ok, #{allocated => #{}, deallocated => Deallocated ++ maps:keys(Allocated)}}.

handle_cast(stop, State) ->
  {stop, normal, State};

handle_cast(_Req, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

convert_resource_name(Number) ->
  list_to_atom(lists:concat(["r", Number])).

allocated_by_user(User, AllocatedResource) ->
  FindUser = fun(_K,V) -> V =:= User end,
  AllocatedByUser = maps:filter(FindUser, AllocatedResource),
  maps:keys(AllocatedByUser).
