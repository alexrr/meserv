%%%-------------------------------------------------------------------
%%% @author alexr
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20.05.2015 23:23
%%%-------------------------------------------------------------------

-define(VERSION, 135).
-module(mess).
-author("alexr").
-import(string, [join/2, concat/2, str/2]).
-import(timer, [sleep/1]).
-import(messr_sv, [init/1,start_link/0,getPid4Msg/0]).
-import(gslogger, [write_log_Msg/2]).
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
   write_log_Msg("~p: Starting reciever\n", [self()]),
   messr_sv:start_link(),
   {ok,Reciver_ch} = messr_sv:getchild(),
   {ok,Pid1} = supervisor:start_child(messr_sv, Reciver_ch),
   write_log_Msg("~p: Process reciever started on ~p\n", [self(),Pid1]),
   write_log_Msg("~p: Starting sender\n", [self()]),
   Pid2 = spawn(fun() -> sender(messr_sv, 0, 0,{9, 3}) end),
   write_log_Msg("~p: Process sender started on ~p\n",[self(),Pid2]).

-spec(getPidReciever() ->
  {Pid :: pid()} | {Reason :: term()}).
getPidReciever() ->
	Res = getPid4Msg(),
	case Res of
		{ok,Pid} -> Pid;
	    {error,Reson} ->
  			write_log_Msg("\n============>Pid not found for reson:\n ~p\n", [Reson]),Reson
end.

sender(Reciver, TypeMsg, Counter, Params) ->
  Pid = getPidReciever(),
  if is_pid(Pid) ->
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
				write_log_Msg("~p: Msg sent\n",[self()]),
		      receive
                 {From, ack_msg} -> 
                         	write_log_Msg("~p: Ack  recieved from ~p \n",[self(),From]);
				 {From, _} ->
                         	write_log_Msg("~p: Unkown msg from ~p \n",[self(),From])
				after 40 ->
                         	write_log_Msg("~p: Ack not recieved\n",[self()])
				end,
				if (Counter+1) rem PauseCounter == 0 -> 
                	write_log_Msg("~p: Sleeping after ~p / ~p \n",[self(),Counter,PauseCounter]),
					sleep(250),
            	    write_log_Msg("~p: next MSG: id=[~p] type=[~p] to ~p\n", [self(), Counter + 1, NextMsg, Pid]),
					sender(Reciver, NextMsg, Counter + 1, Params);
                  true->
            	    write_log_Msg("~p: next MSG: id=[~p] type=[~p] to ~p\n", [self(), Counter + 1, NextMsg, Pid]),
     				sender(Reciver, NextMsg, Counter + 1, Params)
				end;
			true ->
				stopping(Pid),
				sleep(10),
   				sender(Reciver, 0, 1, Params)
		 end;
 	  true ->
		write_log_Msg("~p: can't find reciever process:", [self(),Pid]),
		sleep(10),
		sender(Reciver, TypeMsg, Counter, Params)	
   end.

stopping(Pid) ->
  write_log_Msg("~p: Counter exeed \n", [self()]),
  write_log_Msg("~p: Sending stop msg to ~p \n", [self(), Pid]),
  Pid ! {self(), stop},
  receive
    {RPid, stop_ack} -> write_log_Msg("~p: Reciever ~p stopped ok \n", [self(), RPid])
  after 200 ->
    write_log_Msg("~p: Reciever NOT stopped\n", [self()])
  end.

version() ->
    io:fwrite("\nHello my version is ~p!\n",[?VERSION]),
	ok.

megaf()->
    io:fwrite("\nHello MegaF!\n"),
	ok.




