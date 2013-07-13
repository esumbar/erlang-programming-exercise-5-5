# Exercise 5-5: Phone FSM

This is one possible solution to exercise 5-5 in the book _Erlang Programming_ by F. Cesarini and S. Thompson, which states

> Complete the coding of the phone FSM example, and then instrument it with logging using an event handler process. This should record enough information to enable billing for the use of the phone.

The code adds two states to the phone FSM, namely, waiting and disconnected, and implements a phone ringer FSM. It utilizes the generic event manager and log handler codes (with minor changes) from the same chapter.