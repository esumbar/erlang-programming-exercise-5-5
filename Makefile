# From "Programming Erlang" 2/ed by Joe Armstrong p. 163

.SUFFIXES: .erl .beam .yrl

.erl.beam:
	erlc -W $<

.yrl.erl:
	erlc -W $<

ERL = erl -boot start_clean 

MODS = event_manager log_handler ringer phone

all: compile

compile: ${MODS:%=%.beam}
	
clean:	
	rm -rf *.beam erl_crash.dump