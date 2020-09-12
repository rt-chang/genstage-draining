# Genstage Draining

## Background
This project demonstrates an approach to draining buffered events at shutdown in a GenStage pipeline.
This particular pipeline handles the processing of numbers. The Consumer will demand a number from the Producer in order to output it to console.

There is the ability to drain buffered events with [Broadway](https://hexdocs.pm/broadway/Broadway.html), but I wanted to explore a way of doing it with just GenStage itself
 
## About the Code
The Producer features the use of the Erlang queue and keeps track of accumulated demand via a counter. This was modelled after the examples given in the [GenStage documentation](https://hexdocs.pm/gen_stage/GenStage.html#module-buffering-demand) and this [tutorial by Johanna Larsson](https://blog.jola.dev/push-based-genstage). 

The Consumer traps exits in order to execute the `terminate` callback. In `terminate`, the Consumer requests the event buffer queue from the Producer and proceeds to drain the events in order. 

It should be noted that the Consumer is given 10 seconds to complete the draining of any buffered events. After the 10 seconds has elapsed, the application is forcefully shutdown. The 10 seconds is set in the Application module

## To Run
1. Run `iex -S mix` in console
2. Run the helper function to load _n_ events into the Producer. This is done by calling `GenStageDraining.Helper.enqueue_n_events(n)` with a sufficiently large number
3. Arbitrarily call `:init.stop()` to shutdown the application and trigger the draining of events from the buffer queue. This can be done by copy/pasting the command into console as typing it out may be too slow
4. You will observe that the console will output which event number is being drained

*Note: There is an edge case where 1 event may be dropped -- and thus not processed/drained -- when invoking `:init_stop()`. I have yet to solve this issue*




