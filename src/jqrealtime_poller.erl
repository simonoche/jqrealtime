%% @author Simon Lamellière <simon@lamellie.re>
%% @copyright 2013 Simon Lamellière <simon@lamellie.re>

%% @doc Poller server for jqrealtime.

-module(jqrealtime_poller).
-author("Simon Lamellière <simon@lamellie.re>").
-export([wait/1, poll/1]).

%% Poller Config
-define(TIMEOUT, 30000).
-define(HEADERS, [{"Pragma", "no-cache"},{"Expires", 0}, {"Cache-Control", "must-revalidate"},{"Cache-Control", "no-cache"},{"Cache-Control", "no-store"}]).

%% Long Polling spawner
wait(Req) ->
    Listener = spawn(?MODULE, poll, [Req]),
    Proc = erlang:pid_to_list(Listener),
    io:format(Proc),
    %% Execute our listener
    Listener.

%% Long Polling
poll(Req) ->
    QueryString = Req:parse_qs(),
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