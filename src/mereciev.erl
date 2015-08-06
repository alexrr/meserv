%% coding: UTF-8
%%%-------------------------------------------------------------------
%%% @author alexrr
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. May 2015 10:40
%%%-------------------------------------------------------------------
-module(mereciev).
-author("child").
-import(timer, [sleep/1]).
-import(gslogger, [write_log_Msg/2]).

%% API
-export([init/1,start_link/0]).

init([]) ->
  Pid1 = spawn(fun() -> ppr(0) end),
  {ok, Pid1}.

start_link() ->
  write_log_Msg("~p: Reciever started\n", [self()]),
  Pid1 = spawn_link((fun() -> ppr(0) end)),
  {ok, Pid1}.

ppr(CountWait) ->
  sleep(1),
  if CountWait > 5 ->
    write_log_Msg("~p: wait for ~p times, end working", [self(), CountWait]),
	{error, counter_exceed};
    true ->
      receive
        {From, Counter, do_a_flip} ->
          write_log_Msg("~p: recieved [do_a_flip] id[~p] from ~p\n", [self(), Counter, From]), ppr(0);
        {From, Counter, fish} ->
          write_log_Msg("~p: recieved [fish] id[~p] from ~p\n", [self(), Counter, From]), ppr(0);
        {From, Counter, A} when is_atom(A) ->
          write_log_Msg("~p: recieved atom[~p] id[~p] from ~p\n", [self(), A, Counter, From]), ppr(0);
        {From, Counter, A} when is_integer(A) ->
          write_log_Msg("~p: recieved int[~p] id[~p] from ~p\n", [self(), A, Counter, From]), ppr(0);
        {From,  stop} ->
          write_log_Msg("~p: recieved stop message\n", [self()]),
          From ! {self(),stop_ack},
          exit(0);
        _ ->
          write_log_Msg("~p: recieved uknown message\n", [self()]), ppr(0)
      after 200 ->
        write_log_Msg("~p: no message ~p\n", [self(), CountWait]),
        if CountWait<0 -> ppr(CountWait);
	        true -> 
				ppr(CountWait + 1)
		end
      end
  end.

