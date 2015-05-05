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
      printMsg_recive(do_a_flip, self(), Counter, From);
    {From, Counter, fish} ->
      printMsg_recive(fish, self(), Counter, From);
    _ ->
      io:format("~p: Heh, we're smarter than you humans.~n", [self()])
  end,
  ppr().

printMsg_recive(Msg, Pid, Counter, From) ->
  Fmt = lists:flatten(io_lib:format("~p: recieved msg [~p] ~p from ~p\n", [Pid, Counter, Msg, From])),
  Fmt,
  gslogger:log_str(Fmt),
  ok.
