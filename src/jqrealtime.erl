%% @author Simon Lamellière <simon@lamellie.re>
%% @copyright 2013 Simon Lamellière <simon@lamellie.re>

%% @doc jqrealtime.

-module(jqrealtime).
-author("Simon Lamellière <simon@lamellie.re>").
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.


%% @spec start() -> ok
%% @doc Start the jqrealtime server.
start() ->
    jqrealtime_deps:ensure(),
    ensure_started(crypto),
    application:start(jqrealtime).


%% @spec stop() -> ok
%% @doc Stop the jqrealtime server.
stop() ->
    application:stop(jqrealtime).
