%% @author Simon Lamellière <simon@lamellie.re>
%% @copyright 2013 Simon Lamellière <simon@lamellie.re>

%% @doc Poller functions of jqrealtime.

-module(jqrealtime_poller).
-author("Simon Lamellière <simon@lamellie.re>").
-export([send_all/1, valid_token/1, respond/4, respond/3, rmv_pr/1, rmv_old_pr/0, getclean/1, wait/1, send/1, poll/1, check_session/1]).

%% Poller Config
-define(TIMEOUT, 30000).
-define(HEADERS, [{"Pragma", "no-cache"},{"Expires", 0}, {"Cache-Control", "must-revalidate"},{"Cache-Control", "no-cache"},{"Cache-Control", "no-store"}]).
-define(SECRET_KEY, <<"bf3cc858ce88c3fcebcf3e7c691983a28b8dabba">>).

%% Macros
-define(record_to_tuplelist(Rec, Ref), lists:zip(record_info(fields, Rec),tl(tuple_to_list(Ref)))).

%% Define our models
-record(sessions, {id, user_id, cookie}).
-record(pids, {id, user_id, pid, browser_session, security, created_at, end_at}).

%% Debug
% -record(result_packet, {seq_num, field_list, rows, extra}).
% -record(ok_packet, {seq_num, affected_rows, insert_id, status, warning_count, msg}).
% -record(error_packet, {seq_num, code, msg}).

%% Check session util
check_session(Req) ->

    %% Check session
    CheckSession = emysql:execute(myjqrealtime, 
        lists:concat([
            "SELECT * FROM sessions WHERE cookie = ", 
            emysql_util:quote(getclean(Req:get_cookie_value("jqr"))),
            " LIMIT 1"
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

%% Call all processes and send data
%% @todo : code repetition, MUST combine send_all() and send()
send_all(Req) ->
    case valid_token(Req) of
        false ->
            Req:ok({"text/javascript", ?HEADERS, lists:concat([mochijson2:encode({
                            struct, [ {dispatch, -1} ]
                            })])
                        });
        true ->
            %% Parse QS & Get Json Data to send
            QueryString = Req:parse_post(),
            UserData = getclean(proplists:get_value("data", QueryString)),
            
            %% rmv outdated
            rmv_old_pr(),

            %% Get All Unique processes (if more than one page opened)
            CheckPids = emysql:execute(myjqrealtime, lists:concat(["SELECT * FROM (SELECT * FROM `processes` ORDER BY end_at DESC) as Sub GROUP BY Sub.browser_session"])),

            %% Convert to erlang records
            Records = emysql_util:as_record(CheckPids, pids, record_info(fields, pids)),

            %% dispatch data
            Result = case length(Records) of
                0 ->
                    false;
                _ ->
                    [begin
                        %% Broadcast each process found
                        Process = list_to_pid(binary_to_list(Record#pids.pid)),

                        %% RMV Process
                        rmv_pr(integer_to_list(Record#pids.id)),

                        %% Broadcast data
                        Process ! {UserData}
                    end || Record <- Records],
                    true
            end,

            %% Respond
            Req:ok({"text/javascript", ?HEADERS, lists:concat([mochijson2:encode({
                        struct, [ {dispatch, Result} ]
                        })])
                    })
        end.

%% Call a process and Send Data
send(Req) ->

    case valid_token(Req) of
        false ->
            Req:ok({"text/javascript", ?HEADERS, lists:concat([mochijson2:encode({
                            struct, [ {dispatch, -1} ]
                            })])
                        });
        true ->
            %% Parse QS & Get Json Data to send
            QueryString = Req:parse_post(),
            UserData = getclean(proplists:get_value("data", QueryString)),
            UserId = getclean(proplists:get_value("uid", QueryString)),

            %% rmv outdated
            rmv_old_pr(),
            
            %% Get All Unique processes (if more than one page opened)
            CheckPids = emysql:execute(myjqrealtime, lists:concat(["SELECT * FROM (SELECT * FROM `processes` WHERE user_id = ", emysql_util:quote(UserId), " ORDER BY end_at DESC) as Sub GROUP BY Sub.browser_session"])),

            %% Convert to erlang records
            Records = emysql_util:as_record(CheckPids, pids, record_info(fields, pids)),

            %% dispatch data
            Result = case length(Records) of
                0 ->
                    false;
                _ ->
                    [begin
                        %% Broadcast each process found
                        Process = list_to_pid(binary_to_list(Record#pids.pid)),

                        %% RMV Process
                        rmv_pr(integer_to_list(Record#pids.id)),

                        %% Broadcast data
                        Process ! {UserData}
                    end || Record <- Records],
                    true
            end,

            %% Respond
            Req:ok({"text/javascript", ?HEADERS, lists:concat([mochijson2:encode({
                        struct, [ {dispatch, Result} ]
                        })])
                    })
        end.

%% Long Polling spawner
wait(Req) ->

    %% Parse QS
    QueryString = Req:parse_qs(),

    %% Case
    case check_session(Req) of
        {UserId} ->
            %% Spawn our new process
            Listener = spawn(?MODULE, poll, [Req]),
            Proc = erlang:pid_to_list(Listener),

            %% rmv outdated
            rmv_old_pr(),

            %% Calculate process death
            CurrentTime = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
            {{Y,M,D},{H,I,S}} = calendar:gregorian_seconds_to_datetime(round(CurrentTime + (?TIMEOUT/1000))),

            %% Register this process
            emysql:execute(myjqrealtime,
                lists:concat([
                    "INSERT INTO processes SET user_id = ", emysql_util:quote(UserId),
                    ", browser_session = ", emysql_util:quote(getclean(proplists:get_value("id", QueryString))), 
                    ", pid = ", emysql_util:quote(Proc),
                    ", security = ", round(random:uniform()*1000000),
                    ", end_at = ", emysql_util:quote(lists:concat([Y,"-",M,"-",D," ",H,":",I,":",S]))
                    ])
                ),

            %% Execute our listener
            Listener;
        false ->
            respond(Req, false, false)
    end.

%% Remove particular process
rmv_pr(ProcessId) ->
    emysql:execute(myjqrealtime, lists:concat(["DELETE FROM processes WHERE id = ", ProcessId])).

%% Remove Old Processes
rmv_old_pr() ->
    %% Remove outdated processes
    emysql:execute(myjqrealtime, <<"DELETE FROM processes WHERE end_at < NOW()">>).

%% Long Polling
poll(Req) ->
    receive
        {DataJson} ->
            respond(Req, true, false, DataJson),
            stop
    after ?TIMEOUT ->
        respond(Req, true, true)
    end.

%% Check user token (pull func)
valid_token(Req) ->
    %% Putting an empty SECRET_KEY disable this security
    %% It's highly recommanded to set your secret_key if you use this app in production mode
    case list_to_binary(getclean(proplists:get_value("token", Req:parse_post()))) of
        ?SECRET_KEY ->
            true;
        _ ->
            false
    end. 
    %% curl -X POST -d "uid=1&data=%7B%22message%22%20%3A%20%22Hello%20World%22%7D&token=bf3cc858ce88c3fcebcf3e7c691983a28b8dabba" http://localhost:8080/push

%% Generic Response of jqRealtime
respond(Req, Session, Timeout, DataJson) ->
    Req:ok({"text/javascript", ?HEADERS, 
        lists:concat([
                getclean(proplists:get_value("callback", Req:parse_qs())),
                "(", 
                 mochijson2:encode({
                    struct, [ 
                        {session, Session}, 
                        {timeout, Timeout}, 
                        {realtime, mochijson2:decode(DataJson)}
                    ]
                }),
                ")"
            ])
        }).

respond(Req, Session, Timeout) ->
    respond(Req, Session, Timeout, binary_to_list(<<"{}">>)).

%% Get Value or "" if undefined
getclean(X) when X /= undefined ->
    X;
getclean(_) ->
    "".