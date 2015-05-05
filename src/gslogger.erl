%%%-------------------------------------------------------------------
%%% @author alexr
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Апр. 2015 20:45
%%%-------------------------------------------------------------------
-module(gslogger).
-author("alexr").

-behaviour(gen_server).

%% API
-export([start_link/1, start_link/0, stop/0, log/1, log_str/1, upread/1, truncate/0, log_binary/2]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).
-import(i32lib, [i32/1, getint32/1]).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================
start_link(Filename) ->
  gen_server:start_link({local, gslogger}, gslogger, Filename, []).

stop() ->
  gen_server:call(gslogger, stop).

log(Term) ->
  gen_server:call(gslogger, {log, term_to_binary(Term)}).

log_str(Str) ->
  gen_server:call(gslogger, {log_str, Str}).

upread(Fun) ->
  gen_server:call(gslogger, {upread, Fun}).

truncate() ->
  gen_server:call(gslogger, truncate).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term()} | ignore).

init(FileName) ->
  case file:open(FileName, [write, append, raw]) of
    {ok, Fd} ->
      io:format("File: ~p open for log ~p \n", [FileName, Fd]),
      {ok, Fd};
    {error, Reason} ->
      warn("Can't open ~p~n", [FileName]),
      {stop, Reason}
  end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
  {reply, Reply :: term(), NewState :: #state{}} |
  {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_call({log, Bin}, _From, Fd) ->
  {reply, log_binary(Fd, Bin), Fd};

handle_call({log_str, Str}, _From, Fd) ->
  {reply, log_string(Fd, Str), Fd};

handle_call(truncate, _From, Fd) ->
  file:position(Fd, bof),
  file:truncate(Fd),
  {reply, ok, Fd};

handle_call(stop, _, Fd) ->
  {stop, stopped, Fd}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Msg, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
  {noreply, NewState :: #state{}} |
  {noreply, NewState :: #state{}, timeout() | hibernate} |
  {stop, Reason :: term(), NewState :: #state{}}).
handle_info(_Info, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, Fd) ->
  file:close(Fd).


%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
  {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


log_binary(Fd, Bin) ->
  Sz = size(Bin),
  case file:write(Fd, [i32(Sz), Bin]) of
    ok ->
      {ok, Fd};
    {error, Reason} ->
      warn("Cant't write logfile ~p ", [Reason]),
      {error, Reason}
  end.

log_string(Fd, Str) ->
  {{Year, Month, Day}, {Hour, Min, Sec}} = erlang:localtime(),
  FStr = io_lib:format("~p/~p/~p ~p:~p:~p --> ~p \n", [Year, Month, Day, Hour, Min, Sec, Str]),
  case file:write(Fd, FStr) of
    ok ->
      {ok, Fd};
    {error, Reason} ->
      warn("Cant't write logfile ~p \n", [Reason]),
      {error, Reason}
  end.


warn(Fmt, As) ->
  io:format(user, "gslogger: " ++ Fmt, [As]).


