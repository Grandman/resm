-module(resm_app_tests).
-include_lib("eunit/include/eunit.hrl").

-define(APPS, [ranch, cowlib, cowboy, resm]).

http_test_() ->
  {
    setup,
    fun() -> [ok = application:start(App) || App <- ?APPS] end,
    fun(_) -> [ok = application:stop(App) || App <- lists:reverse(?APPS)] end,
    [
      {
        "Init list",
        ?_assertMatch({ok, {{_HttpV, 200, "OK"}, _Headers, "{\"allocated\":[],\"deallocated\":[\"r1\",\"r2\",\"r3\"]}"}},
                      httpc:request("http://127.0.0.1:8080/list"))
      },
      {
        "Allocate",
        ?_assertMatch({ok, {{_HttpV, 201, "Created"}, _Headers, "r1"}},
                      httpc:request("http://127.0.0.1:8080/allocate/alice"))
      },
      {
        "List after allocate",
        ?_assertMatch({ok, {{_HttpV, 200, "OK"}, _Headers, "{\"allocated\":{\"r1\":\"alice\"},\"deallocated\":[\"r2\",\"r3\"]}"}},
                      httpc:request("http://127.0.0.1:8080/list"))
      },
      {
        "Allocate all resources",
        [
          ?_assertMatch({ok, {{_HttpV, 201, "Created"}, _Headers, "r2"}},
                        httpc:request("http://127.0.0.1:8080/allocate/alice")),
          ?_assertMatch({ok, {{_HttpV, 201, "Created"}, _Headers, "r3"}},
                        httpc:request("http://127.0.0.1:8080/allocate/alice")),
          ?_assertMatch({ok, {{_HttpV, 503, "Service Unavailable"}, _Headers, "Out of resources"}},
                        httpc:request("http://127.0.0.1:8080/allocate/alice"))
        ]
      },
      {
        "List of all allocated resources by user",
        ?_assertMatch({ok, {{_HttpV, 200, "OK"}, _Headers, "[\"r1\",\"r2\",\"r3\"]"}},
         httpc:request("http://127.0.0.1:8080/list/alice"))
      },
      {
        "Deallocate requests",
        [
          ?_assertMatch({ok, {{_HttpV, 204, "No Content"}, _Headers, ""}},
                        httpc:request("http://127.0.0.1:8080/deallocate/r1")),
          ?_assertMatch({ok, {{_HttpV, 404, "Not Found"}, _Headers, "Not allocated"}},
                        httpc:request("http://127.0.0.1:8080/deallocate/r1"))
        ]
      },
      {
        "Reset",
        ?_assertMatch({ok, {{_HttpV, 204, "No Content"}, _Headers, ""}},
                      httpc:request("http://127.0.0.1:8080/reset"))
      },
      {
        "Request for non-existent page",
        ?_assertMatch({ok, {{_HttpV, 400, "Bad Request"}, _Headers, "Bad Request"}},
                      httpc:request("http://127.0.0.1:8080/not_exist_page"))
      }
    ]
  }.
