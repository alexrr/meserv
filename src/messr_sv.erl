%%%-------------------------------------------------------------------
%%% @author alexr
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Апр. 2015 11:07
%%%-------------------------------------------------------------------
-module(messr_sv).
-import(gslogger, [write_log_Msg/2]).
-author("alexr").

-behaviour(supervisor).

%% API
-export([start_link/0,getchild/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
  {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
    MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
    [ChildSpec :: supervisor:child_spec()]
  }} |
  ignore |
  {error, Reason :: term()}).
init([]) ->
  write_log_Msg("\n~p: Module messr_sv init\n",[self()]),
  RestartStrategy = one_for_all,
  MaxRestarts = 1000,
  MaxSecondsBetweenRestarts = 3600,

  SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

%%  {ok,AChild} = getchild(),
  {ok, {SupFlags, []}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

getchild() ->
  Restart = permanent,
  Shutdown = 2000,
  Type = worker,

  AChild = {messr_ch, {mereciev, start_link, []},
    Restart, Shutdown, Type, [mereciev]},
 {ok,AChild}.

