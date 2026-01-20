# Basic Concepts

In this section the basic concepts of pyBeamline are presented.

The main component of a pyBeamline program is its *dataflow*. A dataflow consists of the basic transformations applied to each event, from its origin (called *source*) until the end (called *sink*). In between, different *operators* can be chained together in order to transform the data according to the requirements. 

This is an example of a simple dataflow:

```python linenums="1"
string_test_source(["ABCD", "ACBD"]).pipe(
    simple_dfg_miner(model_update_frequency=1),
    dfg_str_to_graphviz()
).subscribe(graphviz_sink())
```
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/beamline/pybeamline/blob/master/hello_world.ipynb)

In this dataflow, line 1 defines the *source*, in this case a `string_test_source` that generates a stream with 2 process instances (one with activities `A`, `B`, `C`, and `D` and the other with `A`, `C`, `B`, and `D`). Then, on this stream, a pipeline of two operators is applied: first (`simple_dfg_miner`) transforms the stream of events into a stream of DFG models (i.e., it mines the stream); and the other (`dfg_str_to_graphviz`) converts the DFG into a Graphviz string. Finally, a sink (`graphviz_sink`) is provided that will dump the DFG models into a Graphviz representation. Please note that corresponding `import` statements are omitted for simplicity.


## Events

The pyBeamline framework comes with its own definition of event, called `BEvent` and `BOEvent`, similarly to what is defined in JBeamline. Here some of the corresponding methods are highlighted:

<div class="mermaid">
classDiagram

class AbstractEvent {
    &lt;&lt;abstract&gt;&gt;
    + get_event_name() str
    + get_event_time() str
}

class BEvent {
    + dict process_attributes
    + dict trace_attributes
    + dict event_attributes
    + get_process_name(): str
    + get_trace_name(): str
}

class BOEvent {
    + int event_id
    + str activity_name
    + time timestamp
    + dict omap
    + dict vmap
}

AbstractEvent <|-- BEvent
AbstractEvent <|-- BOEvent
</div>

A `BEvent`, consists of 3 maps for attributes referring to the process, to the trace, and to the event itself. While it's possible to set all the attributes individually, some convenience methods are proposed as well, such as `getTraceName` which returns the name of the trace (i.e., the *case id*). Internally, a `BEvent` stores the basic information using as attribute names the same provided by the [standard extension of OpenXES](https://www.xes-standard.org/xesstandardextensions). Additionally, setters for attributes defined in the context of OpenXES are provided too, thus providing some level of interoperability between the platforms.

A `BOEvent`, on the other hand, represents a single event, aligned with [OCEL 2.0 specification](https://www.ocel-standard.org/). More precisely, it contains a unique event identifier (`ocel:eid`), the name of the activity (`ocel:activity`), the event timestamp (`ocel:timestamp`), a list of associated objects (`ocel:omap`) and additional event attributes (`ocel:vmap`).


## Source and Sink

Sources and sink are defined to extend `BaseSource` and `BaseSink` which look like this:

<div class="mermaid">
classDiagram

class BaseSource~T~ {
    &lt;&lt;abstract&gt;&gt;

    + execute(): void*
    + produce(item T): void
    + close(): void
}

class BaseSink~T~ {
    &lt;&lt;abstract&gt;&gt;

    + consume(item T): void*
    + close(): void
}
</div>

Both classes have a parameter type `T` which indicates the type of events being produced and consumed. In the case of `BaseSource`, the abstract method `execute` has to be implemented and, every time an event has to be produced, method `produce` has to be called.

For `BaseSink`, only the abstract method `consume` has to be implemented. The method receives, as parameter, the item to be consumed.


## Operators

In pyBeamline, the structure of operators is the following:


<div class="mermaid">
classDiagram

class BaseOperator~T, K~ {
    &lt;&lt;abstract&gt;&gt;

    + apply(T): K*
}

class BaseFilter~T~ {
    &lt;&lt;abstract&gt;&gt;

    + condition(value T): bool*
    + apply(T): T
}

class BaseMap~T, K~ {
    &lt;&lt;abstract&gt;&gt;

    + transform(value T): list[K]*
    + apply(T): K
}

BaseOperator <|-- BaseFilter
BaseOperator <|-- BaseMap

</div>

The difference between `BaseFilter`s and `BaseMap`s is that the first are meant just to stop some events from moving forward in the dataflow, without changing the type of the events as they continue their journey. `BaseMap`s,  on the other hand, transform the type of events. For example, a stream discovery miner will extend `BaseMap` as it is expected to transform the incoming stream of events into a stream of mined models.