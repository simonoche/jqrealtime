%% @author Simon Lamellière <simon@lamellie.re>
%% @copyright 2013 Simon Lamellière <simon@lamellie.re>

%% @doc Web server for jqrealtime.

-module(jqrealtime_web).
-author("Simon Lamellière <simon@lamellie.re>").
-export([start/1, stop/0, loop/2]).

%% MySQL Configuration
-define(MYSQL_SERVER, "localhost").
-define(MYSQL_USER, "root").
-define(MYSQL_PASSWD, "").
-define(MYSQL_TABLE, "jqrealtime").
-define(MYSQL_PORT, 3306).

%% External API
start(Options) ->
    {DocRoot, Options1} = get_option(docroot, Options),
    Loop = fun (Req) ->
                   ?MODULE:loop(Req, DocRoot)
           end,
    
    % start mysql
    application:start(emysql),
    emysql:add_pool(myjqrealtime, 1, ?MYSQL_USER, ?MYSQL_PASSWD, ?MYSQL_SERVER, ?MYSQL_PORT, ?MYSQL_TABLE, utf8),

    % start mochiweb
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options1]).

stop() ->
    mochiweb_http:stop(?MODULE).

loop(Req, DocRoot) ->
    "/" ++ Path = Req:get(path),
    try
        case Req:get(method) of
            Method when Method =:= 'GET'; Method =:= 'HEAD' ->
                case Path of
                    "poll" ->
                        jqrealtime_poller:wait(Req);
                    "push" ->
                        jqrealtime_poller:send(Req);
                    _ ->
                        Req:serve_file(Path, DocRoot)
                end;
            'POST' ->
                case Path of
                    _ ->
                        Req:not_found()
                end;
            _ ->
                Req:respond({501, [], []})
        end
    catch
        Type:What ->
            Report = ["web request failed",
                      {path, Path},
                      {type, Type}, {what, What},
                      {trace, erlang:get_stacktrace()}],
            error_logger:error_report(Report),
            %% NOTE: mustache templates need \ because they are not awesome.
            Req:respond({500, [{"Content-Type", "text/plain"}],
                         "An error has occured. Please try again later.\n"})
    end.

%% Internal API

get_option(Option, Options) ->
    {proplists:get_value(Option, Options), proplists:delete(Option, Options)}.