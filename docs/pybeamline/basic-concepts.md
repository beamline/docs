# Basic Concepts

In this section the basic concepts of pyBeamline are presented.


## Events

The pyBeamline framework comes with its own definition of event, called `BEvent` and `BOEvent`, similarly to what is defined in JBeamline. Here some of the corresponding methods are highlighted:
<figure>
<div class="mermaid">
classDiagram
class BEvent {
    + dict process_attributes
    + dict trace_attributes
    + dict event_attributes
    + get_process_name(): str
    + get_trace_name(): str
    + get_event_name(): str
    + get_event_time(): datetime
}

class BOEvent {
    + int event_id
    + str activity_name
    + time timestamp
    + dict omap
    + dict vmap
}
</div>
</figure>
Essentially, a `BEvent`, consists of 3 maps for attributes referring to the process, to the trace, and to the event itself. While it's possible to set all the attributes individually, some convenience methods are proposed as well, such as `getTraceName` which returns the name of the trace (i.e., the *case id*). Internally, a `BEvent` stores the basic information using as attribute names the same provided by the [standard extension of OpenXES](https://www.xes-standard.org/xesstandardextensions). Additionally, setters for attributes defined in the context of OpenXES are provided too, thus providing some level of interoperability between the platforms.

A `BOEvent`, on the other hand, represents a single event, aligned with OCEL specification. More precisely, it contains a unique event identifier (`ocel:eid`), the name of the activity (`ocel:activity`), the event timestamp (`ocel:timestamp`), a list of associated objects (`ocel:omap`) and additional event attributes (`ocel:vmap`).


## Observables and Sources

> An *observer* subscribes to an *Observable*. Then that observer reacts to whatever item or sequence of items the Observable *emits*. This pattern facilitates concurrent operations because it does not need to block while waiting for the Observable to emit objects, but instead it creates a sentry in the form of an observer that stands ready to react appropriately at whatever future time the Observable does so.
> -- <cite>Text from <https://reactivex.io/documentation/observable.html>.</cite>


### Filters

The [filter operator, in ReactiveX,](https://reactivex.io/documentation/operators/filter.html) does not change the stream, but filters the events so that only those passing a predicate test can pass. In Beamline there are some filters already implemented that can be used as follows:

```python
from pybeamline.sources import log_source
from pybeamline.filters import excludes_activity_filter, retains_activity_filter

log_source(["ABC", "ACB", "EFG"]).pipe(
    excludes_activity_filter("A"),
    retains_activity_filter("G")
).subscribe(lambda x: print(str(x)))
```


Please note that filters can be chained together in order to achieve the desired result.


### Mappers and mining algorithms

pyBeamline comes with some mining algorithms, which are essentially instantiations of [`map`](https://reactivex.io/documentation/operators/map.html) and [`flatMap`](https://reactivex.io/documentation/operators/flatmap.html) operators. This section reports some detail on these.



