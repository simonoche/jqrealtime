%% @author Simon Lamellière <simon@lamellie.re>
%% @copyright 2013 Simon Lamellière <simon@lamellie.re>

%% @doc Poller functions of jqrealtime.

-module(jqrealtime_poller).
-author("Simon Lamellière <simon@lamellie.re>").
-export([display/1, wait/1, send/1, poll/1, check_session/1]).

%% Poller Config
-define(TIMEOUT, 30000).
-define(HEADERS, [{"Pragma", "no-cache"},{"Expires", 0}, {"Cache-Control", "must-revalidate"},{"Cache-Control", "no-cache"},{"Cache-Control", "no-store"}]).

%% Macros
-define(record_to_tuplelist(Rec, Ref), lists:zip(record_info(fields, Rec),tl(tuple_to_list(Ref)))).

%% Define our models
-record(sessions, {id, user_id, cookie}).
-record(pids, {id, user_id, pid, browser_session, security, created_at, end_at}).

display(Session) ->
    io:format("User cookie is ~p~n",[Session]).

%% Check session util
check_session(Req) ->

    %% Parse QS
    CheckSession = emysql:execute(myjqrealtime, 
        lists:concat([
            "SELECT * FROM sessions WHERE cookie = ", 
            emysql_util:quote(Req:get_cookie_value("jqr"),
            " LIMIT 1")
        ]
    )),

    %% Convert to records
    Records = emysql_util:as_record(CheckSession, sessions, record_info(fields, sessions)),

    %% Check existence & return user_id if possible
    if
        length(Records) == 1 ->
            %% Get UserId of element
            [{_, _, UserId, _}] = [Rec || Rec <- Records],
            {integer_to_list(UserId)};
        true ->
            false
    end.

%% Call a process and Send Data
send(Req) ->
    Req:ok({"text/javascript", ?HEADERS, lists:concat([mochijson2:encode({
                struct, [ {dispatch, <<"true">> } ]
                })])
            }).
    
%% Long Polling spawner
wait(Req) ->

    %% Parse QS
    QueryString = Req:parse_qs(),

    %% Case
    case ?MODULE:check_session(Req) of
        {UserId} ->
            %% Spawn our new process
            Listener = spawn(?MODULE, poll, [Req]),
            Proc = erlang:pid_to_list(Listener),

            %% Remove outdated processes
            emysql:execute(myjqrealtime, <<"DELETE FROM processes WHERE end_at < NOW()">>),

            %% Calculate process death
            CurrentTime = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
            {{Y,M,D},{H,I,S}} = calendar:gregorian_seconds_to_datetime(round(CurrentTime + (?TIMEOUT/1000))),

            %% Register this process
            emysql:execute(myjqrealtime,
                lists:concat([
                    "INSERT INTO processes SET user_id = ", emysql_util:quote(UserId),
                    ", browser_session = ", emysql_util:quote(proplists:get_value("id", QueryString)), 
                    ", pid = ", emysql_util:quote(Proc),
                    ", security = ", round(random:uniform()*1000000),
                    ", end_at = ", emysql_util:quote(lists:concat([Y,"-",M,"-",D," ",H,":",I,":",S]))
                    ])
                ),

            %% Execute our listener
            Listener;
        false ->
            Req:ok({"text/javascript", ?HEADERS, lists:concat([mochijson2:encode({
                struct, [ {session, <<"false">> }, {timeout, <<"false">> }, {realtime, {} } ]
                })])
            })
    end.

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
                                <<"session">>, 
                                    [<<"true">>],
                                <<"timeout">>, 
                                    [<<"false">>],
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
            struct, [ {session, <<"true">> }, {timeout, <<"true">> }, {realtime, {} } ]
            })])
        })
    end.