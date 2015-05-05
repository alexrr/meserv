%%%-------------------------------------------------------------------
%%% @author child
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Май 2015 10:40
%%%-------------------------------------------------------------------
-module(messr).
-author("child").

%% API
-export([init/1]).

init([]) ->
  Pid1 = spawn(fun() -> ppr() end),
  {ok, Pid1}.

ppr() ->
  receive
    {From, Counter, do_a_flip} ->
      printMsg_recive("~p: recieved [do_a_flip] id[~p] from ~p\n", [self(), Counter, From]);
    {From, Counter, fish} ->
      printMsg_recive("~p: recieved [fish] id[~p] from ~p\n", [self(), Counter, From]);
    {From, Counter, A} when is_atom(A) ->
      printMsg_recive("~p: recieved atom[~p] id[~p] from ~p\n", [self(), A,Counter, From]);
    {From, Counter, A} when is_integer(A) ->
      printMsg_recive("~p: recieved int[~p] id[~p] from ~p\n", [self(), A,Counter, From]);
    _ ->
      printMsg_recive("~p: recieved uknown message\n", [self()])
  end,
  ppr().

printMsg_recive(Str, Args) ->
  Fmt = lists:flatten(io_lib:format(Str, Args)),
  io:fwrite(Fmt),
  gslogger:log_str(Fmt),
  ok.

