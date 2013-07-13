-module (phone).

%% Code from 
%%   Erlang Programming
%%   Francecso Cesarini and Simon Thompson
%%   O'Reilly, 2008
%%   http://oreilly.com/catalog/9780596518189/
%%   http://www.erlangprogramming.org/
%%   (c) Francesco Cesarini and Simon Thompson

-export ([start/1, stop/0, init/0]).
-export ([incoming/1, outgoing/1]).
-export ([off_hook/0, on_hook/0]).
-export ([other_on_hook/1, other_off_hook/1]).

start(Log) ->
  event_manager:start(phone_event_manager,[{log_handler, Log}]),
  ringer:start(),
  register(phone, spawn(?MODULE, init, [])),
  ok.

stop() ->
  phone ! {stop, self()},
  receive ok -> ok end,
  ringer:stop(),
  event_manager:stop(phone_event_manager),
  ok.

init() -> idle().

incoming(Number)       -> phone ! {incoming, Number}, ok.
outgoing(Number)       -> phone ! {outgoing, Number}, ok.
off_hook()             -> phone ! off_hook, ok.
on_hook()              -> phone ! on_hook, ok.
other_on_hook(Number)  -> phone ! {other_on_hook, Number}, ok.
other_off_hook(Number) -> phone ! {other_on_hook, Number}, ok.

idle() ->
  receive
    {incoming, Number} ->
      ringer:start_ringing(),
      ringing(Number);
    off_hook ->
      ringer:start_tone(),
      dial();
    {stop, Pid} ->
      Pid ! ok
  end.

ringing(Number) ->
  receive
    {other_on_hook, Number} ->
      ringer:stop_ringing(),
      idle();
    off_hook ->
      ringer:stop_ringing(),
      connected(Number)
  end.

dial() ->
  receive
    on_hook ->
      ringer:stop_tone(),
      idle();
    {outgoing, Number} ->
      ringer:stop_tone(),
      waiting(Number)
  end.

waiting(Number) ->
  receive
    {other_off_hook, Number} ->
      connected(Number);
    on_hook ->
      idle()
  end.

connected(Number) ->
  event_manager:send_event(phone_event_manager, {start, Number, phone_call}),
  receive
    on_hook ->
      event_manager:send_event(phone_event_manager, {stop, Number, phone_call}),
      idle();
    {other_on_hook, Number} ->
      event_manager:send_event(phone_event_manager, {stop, Number, phone_call}),
      ringer:start_tone(),
      disconnected()
  end.

disconnected() ->
  receive
    on_hook ->
      ringer:stop_tone(),
      idle()
  end.
