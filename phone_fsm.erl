-module (phone_fsm).

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
  event_manager:start(phone,[{log_handler, Log}]),
  ringer_fsm:start(),
  register(phone_fsm, spawn(?MODULE, init, [])),
  ok.

stop() ->
  phone_fsm ! {stop, self()},
  receive ok -> ok end,
  ringer_fsm:stop(),
  event_manager:stop(phone),
  ok.

init() -> idle().

incoming(Number)       -> phone_fsm ! {incoming, Number}, ok.
outgoing(Number)       -> phone_fsm ! {outgoing, Number}, ok.
off_hook()             -> phone_fsm ! off_hook, ok.
on_hook()              -> phone_fsm ! on_hook, ok.
other_on_hook(Number)  -> phone_fsm ! {other_on_hook, Number}, ok.
other_off_hook(Number) -> phone_fsm ! {other_on_hook, Number}, ok.

idle() ->
  receive
    {incoming, Number} ->
      ringer_fsm:start_ringing(),
      ringing(Number);
    off_hook ->
      ringer_fsm:start_tone(),
      dial();
    {stop, Pid} ->
      Pid ! ok
  end.

ringing(Number) ->
  receive
    {other_on_hook, Number} ->
      ringer_fsm:stop_ringing(),
      idle();
    off_hook ->
      ringer_fsm:stop_ringing(),
      event_manager:send_event(phone, {no_billing, Number, incoming_call}),
      connected(Number)
  end.

dial() ->
  receive
    on_hook ->
      ringer_fsm:stop_tone(),
      idle();
    {outgoing, Number} ->
      ringer_fsm:stop_tone(),
      waiting(Number)
  end.

waiting(Number) ->
  receive
    {other_off_hook, Number} ->
      event_manager:send_event(phone, {start_billing, Number, outgoing_call}),
      connected(Number);
    on_hook ->
      idle()
  end.

connected(Number) ->
  receive
    on_hook ->
      event_manager:send_event(phone, {stop_billing, Number, on_hook}),
      idle();
    {other_on_hook, Number} ->
      event_manager:send_event(phone, {stop_billing, Number, other_on_hook}),
      ringer_fsm:start_tone(),
      disconnected()
  end.

disconnected() ->
  receive
    on_hook ->
      ringer_fsm:stop_tone(),
      idle()
  end.
