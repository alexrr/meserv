%%%-------------------------------------------------------------------
%%% @author alexr
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. Янв. 2015 23:23
%%%-------------------------------------------------------------------
-module(mess).
-author("alexr").
-import(string, [join/2, concat/2, str/2]).
-import(timer, [sleep/1]).
-import(messr, [init/1]).
-compile(export_all).

start() ->
  gslogger:start_link("gnlogger.log"),
  gslogger:truncate(),
  gslogger:log_str(ok),
  gslogger:log_str("Start sender"),
  {ok, Pid1} = messr:init([]),
  Pid2 = spawn(fun() -> sender(Pid1, 0, 0) end),
  io:format(" Process reciever ~p started\n Process sender ~p started\n", [Pid1, Pid2]).

sender(Pid, TypeMsg, Counter) ->
  printMsg_send("~p: try send MSG: id=[~p] type=[~p] from ~p\n", [self(), Counter, TypeMsg, Pid]),
  if Counter < 15 ->
    case TypeMsg of
      0 -> Pid ! {self(), Counter, do_a_flip}, NextMsg = 1;
      1 -> Pid ! {self(), Counter, fish}, NextMsg = 2;
      2 -> Pid ! {self(), Counter, blah_blah}, NextMsg = 0;
      _ -> NextMsg = 0
    end,
    sleep(5),
    sender(Pid, NextMsg, Counter + 1);
    true ->
      printMsg_send("~p: Counter exeed", [self()])
  end.

printMsg_send(Str, Args) ->
  Fmt = lists:flatten(io_lib:format(Str, Args)),
  io:fwrite(Fmt),
  gslogger:log_str(Fmt),
  ok.





