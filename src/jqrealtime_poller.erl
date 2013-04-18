%% @author Simon Lamellière <simon@lamellie.re>
%% @copyright 2013 Simon Lamellière <simon@lamellie.re>

%% @doc Poller server for jqrealtime.

-module(jqrealtime_poller).
-author("Simon Lamellière <simon@lamellie.re>").

-behaviour(poller).
-export([wait/1]).

wait(Req) ->
	Req:respond({500, [{"Content-Type", "text/plain"}],
                         "request failed, sorry\n"}).