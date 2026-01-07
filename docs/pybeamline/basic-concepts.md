# Basic concepts

In this section the basic concepts of pyBeamline are presented.


## Events

The pyBeamline framework comes with its own definition of event, called `BEvent`, similarly to what is defined in JBeamline. Here some of the corresponding methods are highlighted:
<figure>
<div class="mermaid">
classDiagram
class BEvent {
    +dict process_attributes
    +dict trace_attributes
    +dict event_attributes
    +get_process_name(): str
    +get_trace_name(): str
    +get_event_name(): str
    +get_event_time(): datetime
}
</div>
</figure>
Essentially, a Beamline event, consists of 3 maps for attributes referring to the process, to the trace, and to the event itself. While it's possible to set all the attributes individually, some convenience methods are proposed as well, such as `getTraceName` which returns the name of the trace (i.e., the *case id*). Internally, a `BEvent` stores the basic information using as attribute names the same provided by the [standard extension of OpenXES](https://www.xes-standard.org/xesstandardextensions). Additionally, setters for attributes defined in the context of OpenXES are provided too, thus providing some level of interoperability between the platforms.


## Observables and Sources

> An *observer* subscribes to an *Observable*. Then that observer reacts to whatever item or sequence of items the Observable *emits*. This pattern facilitates concurrent operations because it does not need to block while waiting for the Observable to emit objects, but instead it creates a sentry in the form of an observer that stands ready to react appropriately at whatever future time the Observable does so.
> -- <cite>Text from <https://reactivex.io/documentation/observable.html>.</cite>
