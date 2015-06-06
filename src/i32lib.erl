%%%-------------------------------------------------------------------
%%% @author alexr
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Май 2015 18:39
%%%-------------------------------------------------------------------
-module(i32lib).
-author("alexr").

%% API
-export([i32/1, getint32/1]).

i32(B) when is_binary(B) ->
  i32(binary_to_list(B, 1, 4));
i32([X1, X2, X3, X4]) ->
  (X1 bsl 24) bor (X2 bsl 16) bor (X3 bsl 8) bor X4;
i32(Int) when integer(Int) ->
  [(Int bsr 24) band 255,
    (Int bsr 16) band 255,
    (Int bsr 8) band 255,
    Int band 255].

integer(Int) ->
  error(not_implemented).

getint32(F) ->
  {ok, B} = file:read(F, 4),
  i32(B).

