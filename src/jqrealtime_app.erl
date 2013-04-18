%% @author Simon Lamellière <simon@lamellie.re>
%% @copyright 2013 Simon Lamellière <simon@lamellie.re>

%% @doc Callbacks for the jqrealtime application.

-module(jqrealtime_app).
-author("Simon Lamellière <simon@lamellie.re>").

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for jqrealtime.
start(_Type, _StartArgs) ->
    jqrealtime_deps:ensure(),
    jqrealtime_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for jqrealtime.
stop(_State) ->
    ok.
