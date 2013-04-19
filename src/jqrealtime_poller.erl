%% @author Simon Lamellière <simon@lamellie.re>
%% @copyright 2013 Simon Lamellière <simon@lamellie.re>

%% @doc Poller server for jqrealtime.

-module(jqrealtime_poller).
-author("Simon Lamellière <simon@lamellie.re>").
-export([wait/2, poll/1]).

%% Poller Config
-define(TIMEOUT, 30000).
-define(HEADERS, [{"Pragma", "no-cache"},{"Expires", 0}, {"Cache-Control", "must-revalidate"},{"Cache-Control", "no-cache"},{"Cache-Control", "no-store"}]).

%% Define our models
-record(sessions, {id, user_id, cookie}).
-record(pids, {id, user_id, pid, browser_session, created_at, end_at}).

%% Long Polling spawner
wait(Req, UserId) ->

    %% Parse QS
    AuthCookie = Req:get_cookie_value("jqr"),
    QueryString = Req:parse_qs(),

    Test = emysql:execute(myjqrealtime, lists:concat(["SELECT * FROM sessions WHERE cookie = ", emysql_util:quote(AuthCookie), " LIMIT 1"])),

    Recs = emysql_util:as_record(Test, sessions, record_info(fields, sessions)),
    [begin
      io:format("foo: ~p, ~p, ~p~n", [Foo#sessions.id, Foo#sessions.user_id, Foo#sessions.cookie])
    end || Foo <- Recs],

    %% Spawn our new process
    Listener = spawn(?MODULE, poll, [Req]),
    Proc = erlang:pid_to_list(Listener),

    %% Remove outdated processes
    emysql:execute(myjqrealtime, <<"DELETE FROM processes WHERE end_at < NOW()">>),

    %% Calculate process death
    CurrentTime = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
    {{Y,M,D},{H,I,S}} = calendar:gregorian_seconds_to_datetime(round(CurrentTime + (?TIMEOUT/1000))),

    %% Output Process Id
    io:format(Proc),

    %% Register this process
    emysql:execute(myjqrealtime,
        lists:concat([
            "INSERT INTO processes SET user_id = ", emysql_util:quote(UserId),
            ", browser_session = ", emysql_util:quote(proplists:get_value("id", QueryString)), 
            ", pid = ", emysql_util:quote(Proc),
            ", end_at = ", emysql_util:quote(lists:concat([Y,"-",M,"-",D," ",H,":",I,":",S]))
            ])
        ),

    %% Execute our listener
    Listener.

%% Long Polling
poll(Req) ->
    receive
        {DataType, DataText} ->
            io:format("Process ended"),
            Req:ok({"text/javascript", ?HEADERS, 
                lists:concat([
                    mochijson2:encode({
                            struct, [ 
                            { 
                                <<"realtime">>, 
                                [list_to_binary(DataType), list_to_binary(DataText)]
                            }
                        ]
                    }) 
                ])
            }),
            stop

    after ?TIMEOUT ->
        Req:ok({"text/javascript", ?HEADERS, lists:concat([mochijson2:encode({
            struct, [ {error, <<"timeout">> } ]
            })])
        })
    end.