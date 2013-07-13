# Based on Makefile template from "Programming Erlang" 2/ed
# by Joe Armstrong, p. 163 (PDF version)

.SUFFIXES: .erl .beam .yrl

.erl.beam:
	erlc -W $<

.yrl.erl:
	erlc -W $<

ERL = erl -boot start_clean 

MODS = event_manager log_handler ringer_fsm phone_fsm

all: compile

compile: ${MODS:%=%.beam}
	
clean:	
	rm -rf *.beam erl_crash.dump
