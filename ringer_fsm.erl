-module (ringer).
-export ([start/0, stop/0, init/0]).
-export ([start_ringing/0, stop_ringing/0]).
-export ([start_tone/0, stop_tone/0]).

start() ->
	register(ringer, spawn(?MODULE, init, [])),
	ok.

stop() ->
	ringer ! {stop, self()},
	receive ok -> ok end.

init() -> silent().

start_ringing() -> ringer ! ringer_on.
stop_ringing()  -> ringer ! ringer_off.
start_tone()    -> ringer ! dial_tone_on.
stop_tone()     -> ringer ! dial_tone_off.

silent() ->
	receive
		ringer_on ->
			ringing();
		dial_tone_on ->
			dial_tone();
		{stop, Pid} ->
			Pid ! ok
	end.

ringing() ->
	receive
		ringer_off ->
			silent()
	after
		500 ->
			io:format("ringing~n"),
			ringing()
	end.

dial_tone() ->
	receive
		dial_tone_off ->
			silent()
	after
		500 ->
			io:format("dial tone~n"),
			dial_tone()
	end.