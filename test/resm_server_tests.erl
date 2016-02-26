-module(resm_server_tests).
-include_lib("eunit/include/eunit.hrl").

start_link_test() ->
  ?assertEqual({error, resource_count_incorrect}, resm:start_link(0)).


list_test_() ->
  {setup,
   fun() -> {ok, Pid} = resm:start_link(5), Pid end,
   fun(Pid) -> ok = resm:stop(Pid) end,
   [
    {
      "List",
        ?_assertEqual({ok, #{allocated => #{}, deallocated => [r1, r2, r3, r4, r5]}}, resm:list())
    }
   ]
  }.

allocate_test_() ->
  {setup,
   fun() -> {ok, Pid} = resm:start_link(1), Pid end,
   fun(Pid) -> ok = resm:stop(Pid) end,
   [
    {
      "Allocate if exists free resource",
      [
        {"Return resource", ?_assertEqual({ok, r1}, resm:allocate('Alice'))},
        {"Resource should allocated", ?_assertEqual({ok, #{allocated => #{r1 => 'Alice'}, deallocated => []}}, resm:list())}
      ]
    },
    {
      "Error if not exist free resource",
       ?_assertEqual({error, out_of_resources}, resm:allocate('Alice'))
    }
   ]
  }.

deallocate_test_() ->
  {setup,
   fun() -> {ok, Pid} = resm:start_link(1), resm:allocate('Alice'), Pid end,
   fun(Pid) -> ok = resm:stop(Pid) end,
   [
    {
      "Deallocate if exist allocated resource",
      [
        {"Return ok", ?_assertEqual(ok, resm:deallocate(r1))},
        {"Resource should be deallocated",  ?_assertEqual({ok, #{allocated => #{}, deallocated => [r1]}}, resm:list())}
      ]
    },
    {
      "Deallocate if not exists alocated resources",
      ?_assertEqual({error, not_allocated}, resm:deallocate('r3'))
    }
   ]
  }.
list_of_user_test_() ->
  {
    setup,
    fun() -> {ok, Pid} = resm:start_link(1), resm:allocate('Alice'), Pid end,
    fun(Pid) -> ok = resm:stop(Pid) end,
    [
      {
        "Return resources if user have allocated",
        ?_assertEqual({ok, [r1]}, resm:list('Alice'))
      },
      {
        "Return empty if user not have allocated",
        ?_assertEqual({ok, []}, resm:list('Bob'))
      }

    ]
  }.
reset_test_() ->
  {
    setup,
    fun() -> {ok, Pid} = resm:start_link(2), resm:allocate('Alice'), Pid end,
    fun(Pid) -> ok = resm:stop(Pid) end,
    [
      {
        "Reset resources",
        [
          {"Return ok", ?_assertEqual(ok, resm:reset())},
          {"All resources should be deallocated", ?_assertEqual({ok, #{allocated => #{}, deallocated => [r2, r1]}}, resm:list())}
        ]
      }
    ]
  }.
