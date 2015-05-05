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
      write_log_Msg("~p: recieved [do_a_flip] id[~p] from ~p\n", [self(), Counter, From]);
    {From, Counter, fish} ->
      write_log_Msg("~p: recieved [fish] id[~p] from ~p\n", [self(), Counter, From]);
    {From, Counter, A} when is_atom(A) ->
      write_log_Msg("~p: recieved atom[~p] id[~p] from ~p\n", [self(), A,Counter, From]);
    {From, Counter, A} when is_integer(A) ->
      write_log_Msg("~p: recieved int[~p] id[~p] from ~p\n", [self(), A,Counter, From]);
    _ ->
      write_log_Msg("~p: recieved uknown message\n", [self()])
  end,
  ppr().

write_log_Msg(Str, Args) ->
  Fmt = lists:flatten(io_lib:format(Str, Args)),
  io:fwrite(Fmt),
  gslogger:log_str(Fmt),
  ok.

