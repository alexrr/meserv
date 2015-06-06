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
  %% ok  333
  %% ddd
  gslogger:start_link("gnlogger.log"),
  gslogger:truncate(),
  gslogger:log_str(ok),
  gslogger:log_str("Start sender"),
  {ok, Pid1} = messr:init([]),
  Pid2 = spawn(fun() -> sender(Pid1, 0, 40, 0, 12) end),
  io:format(" Process reciever ~p started\n Process sender ~p started\n", [Pid1, Pid2]).

sender(Pid, TypeMsg, MaxCounter, Counter, PauseCounter) ->
  write_log_Msg("~p: try send MSG: id=[~p] type=[~p] from ~p\n", [self(), Counter, TypeMsg, Pid]),
  if Counter < MaxCounter ->
    case TypeMsg of
      0 -> Pid ! {self(), Counter, do_a_flip}, NextMsg = 1;
      1 -> Pid ! {self(), Counter, fish}, NextMsg = 2;
      2 -> Pid ! {self(), Counter, blah_blah}, NextMsg = 3;
      3 -> Pid ! {self(), Counter, 555}, NextMsg = 0;
      _ -> NextMsg = 0
    end,
    if Counter rem PauseCounter == 0 -> sleep(25);
      true ->  sleep(5)
    end,
    sender(Pid, NextMsg, MaxCounter, Counter + 1, PauseCounter);
    true ->
      stopping(Pid)
  end.

stopping(Pid) ->
  write_log_Msg("~p: Counter exeed \n", [self()]),
  write_log_Msg("~p: Sending stop msg to ~p \n", [self(), Pid]),
  Pid ! {self(), stop},
  receive
    {RPid, stop_ack} -> write_log_Msg("~p: Recicer ~p stopped ok \n", [self(), RPid])
  after 200 ->
    write_log_Msg("~p: Recicer NOT stopped\n", [self()])
  end.

write_log_Msg(Str, Args) ->
  Fmt = lists:flatten(io_lib:format(Str, Args)),
  io:fwrite(Fmt),
  gslogger:log_str(Fmt),
  ok.





