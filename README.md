# Exercise 5-5: Phone FSM

This is one possible solution to exercise 5-5 in the book _Erlang Programming_ by F. Cesarini and S. Thompson (O'Reilly, 2009). The exercise reads

> Complete the coding of the phone FSM example, and then instrument it with logging using an event handler process. This should record enough information to enable billing for the use of the phone.

To the existing four states of the phone FSM (idle, ringing, dial, and connected), two more are added, namely, _waiting_ (for other party to pick up our call) and _disconnected_ (when other party hangs up while we are connected). A _phone ringer FSM_ is also implemented that generates both the "ringing" and "dial tone" effects. The generic event manager and log handler codes from Chapter 5 required minor changes.

The phone FSM includes client code for testing in the shell, which was done successfully with Erlang R16B (erts-5.10.1). The following is a transcript of a typical session.

	1> phone_fsm:start("phone.log").
	ok
	2> phone_fsm:incoming(1234). % incoming call
	ok
	ringing
	ringing
	ringing
	ringing      
	ringing      
	ringing         
	ringing               
	ringing                 
	ringing                 
	3> phone_fsm:off_hook(). % answer incoming call 
	ok
	4> phone_fsm:other_on_hook(1234). % caller hangs up 
	ok
	dial tone
	dial tone
	dial tone
	dial tone    
	dial tone    
	dial tone            
	dial tone             
	dial tone              
	5> phone_fsm:on_hook(). % put receiver back on the hook
	ok
	6> phone_fsm:off_hook(). % pick up receiver to make a call
	ok
	dial tone
	dial tone
	dial tone    
	dial tone             
	dial tone             
	dial tone               
	dial tone                 
	dial tone                   
	7> phone_fsm:outgoing(3456). % wait for other end to answer
	ok
	8> phone_fsm:other_off_hook(3456). % other end answers
	ok
	9> phone_fsm:on_hook(). % hang up
	ok
	10> phone_fsm:stop().
	ok

This is the corresponding contents of the log file _phone.log_.

	1373,746312,180149,no_billing,1234,incoming_call
	1373,746360,359205,stop_billing,1234,other_on_hook
	1373,746410,565402,start_billing,3456,outgoing_call
	1373,746432,651613,stop_billing,3456,on_hook

The `no_billing` action is associated with incoming calls, while `start_billing` is associated with outgoing calls. `stop_billing` at the end of either type of call.
