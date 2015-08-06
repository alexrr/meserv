%%%-------------------------------------------------------------------
%%% @author alexr
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20.05.2015 23:23
%%%-------------------------------------------------------------------

-define(VERSION, 131).
-module(mess).
-author("alexr").
-import(string, [join/2, concat/2, str/2]).
-import(timer, [sleep/1]).
-import(messr_sv, [init/1,start_link/0]).
-compile(export_all).

start() ->
  %% ok  333
  %% ddd
	%% new line for test
	%% mega line
   version(),
   megaf(),
   file:make_dir("log"),
   gslogger:start_link("log\\gnlogger.log"),
   gslogger:truncate(),
   write_log_Msg("~p: Ok\n",[self()]),
   write_log_Msg("~p: Starting sender\n", [self()]),
   Pid2 = spawn(fun() -> sender(messr_ch, 0, 0,{9, 3}) end),
   write_log_Msg("~p: Process sender started on ~p\n",[self(),Pid2]),
   write_log_Msg("~p: Starting reciever\n", [self()]),
   messr_sv:start_link(),
   {ok,Reciver_ch} = messr_sv:getchild(),
%%   {ok,Pid1} = supervisor:start_child(messr_sv, Reciver_ch),
   Pid1 = whereis(messr_ch),
   Lchild = supervisor:which_children(messr_sv),
   write_log_Msg("\n============\nchilds:\n ~p\n", [Lchild]),
   write_log_Msg("~p: Process reciever started on ~p", [self(),Pid1]).

sender(Reciver, TypeMsg, Counter, Params) ->
  Pid = whereis(Reciver),
  {MaxCounter,PauseCounter}  = Params,
  write_log_Msg("~p: try send MSG: id=[~p] type=[~p] to ~p\n", [self(), Counter, TypeMsg, Pid]),
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
    sender(Pid, NextMsg, Counter + 1, Params);
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

version() ->
    io:fwrite("\nHello my version is ~p!\n",[?VERSION]),
	ok.

megaf()->
    io:fwrite("\nHello MegaF!\n"),
	ok.




