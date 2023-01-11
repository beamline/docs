# pyBeamline

pyBeamline is a Python version of Beamline. While the same set of ideas and principles of Beamline have been ported into pyBeamline, the underlying goal and technology is very different

## Goals and differences with Beamline

TODO

## Differences with PM4PY

TODO


## Technology used in pyBeamline

pyBeamline is based on ReactiveX technology and its Python binding [RxPY](https://rxpy.readthedocs.io/en/latest/).

### Events

The pyBeamline framework comes with its own definition of event, called `BEvent`, similarly to what is defined in Beamline. Here some of the corresponding methods are highlighted:
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


### Observables and Sources

> An *observer* subscribes to an *Observable*. Then that observer reacts to whatever item or sequence of items the Observable *emits*. This pattern facilitates concurrent operations because it does not need to block while waiting for the Observable to emit objects, but instead it creates a sentry in the form of an observer that stands ready to react appropriately at whatever future time the Observable does so.
> -- <cite>Text from <https://reactivex.io/documentation/observable.html>.</cite>

In the context of Beamline it is possible to define observables of any type. The framework comes with some observables already defined. Sources already implemented are `xes_log_source`, and `string_test_source`. A `xes_log_source` creates a source from a static log (useful for testing purposes), and `string_test_source` allows the definition of simple log directly in its constructor (useful for testing purposes).

??? note "Details on `xes_log_source`"
    Emits all events from an XES event log. Example usage:
    ```python
    import pm4py
    from pybeamline.sources import xes_log_source

    xes_log_source(pm4py.read_xes("test.xes")) \
        .subscribe(lambda x: print(str(x)))
    ```

??? note "Details on `string_test_source`"
    Source that considers each trace as a string provided in the constructor and each event as one character of the string. Example usage:
    ```python
    from pybeamline.sources import string_test_source

    string_test_source(["ABC", "ACB", "EFG"]) \
        .subscribe(lambda x: print(str(x)))
    ```


### Filters

The [filter operator, in ReactiveX,](https://reactivex.io/documentation/operators/filter.html) does not change the stream, but filters the events so that only those passing a predicate test can pass. In Beamline there are some filters already implemented that can be used as follows:

```python
from pybeamline.sources import string_test_source
from pybeamline.filters import excludes_activity_filter, retains_activity_filter

string_test_source(["ABC", "ACB", "EFG"]).pipe(
    excludes_activity_filter("A"),
    retains_activity_filter("G")
).subscribe(lambda x: print(str(x)))
```

Filters can operate on event attributes or trace attributes and the following are currently available:

??? note "Details on `retains_on_event_attribute_equal_filter`"
    Retains events based on the equality of an event attribute. Example:
    ```python
    from pybeamline.sources import xes_log_source
    from pybeamline.filters import retains_on_event_attribute_equal_filter

    xes_log_source(pm4py.read_xes("test.xes")).pipe(
        retains_on_event_attribute_equal_filter("event-attrib", ["ev", "ab"]),
    ).subscribe(lambda x: print(str(x)))
    ```

??? note "Details on `excludes_on_event_attribute_equal_filter`"
    Exclude events based on the equality of an event attribute.
    ```python
    from pybeamline.sources import xes_log_source
    from pybeamline.filters import excludes_on_event_attribute_equal_filter
    
    xes_log_source(pm4py.read_xes("test.xes")).pipe(
        excludes_on_event_attribute_equal_filter("event-attrib", ["ev", "ab"]),
    ).subscribe(lambda x: print(str(x)))
    ```

??? note "Details on `retains_on_trace_attribute_equal_filter`"
    Retains events based on the equality of a trace attribute.
    ```python
    from pybeamline.sources import xes_log_source
    from pybeamline.filters import retains_on_trace_attribute_equal_filter
    
    xes_log_source(pm4py.read_xes("test.xes")).pipe(
        retains_on_trace_attribute_equal_filter("trace-attrib", ["tv", "ab"]),
    ).subscribe(lambda x: print(str(x)))

    ```

??? note "Details on `excludes_on_trace_attribute_equal_filter`"
    Excludes events based on the equality of a trace attribute.
    ```python
    from pybeamline.sources import xes_log_source
    from pybeamline.filters import excludes_on_trace_attribute_equal_filter
    
    xes_log_source(pm4py.read_xes("test.xes")).pipe(
        excludes_on_trace_attribute_equal_filter("trace-attrib", ["tv", "ab"]),
    ).subscribe(lambda x: print(str(x)))

    ```

??? note "Details on `retains_activity_filter`"
    Retains activities base on their name (`concept:name`).
    ```python
    from pybeamline.sources import string_test_source
    from pybeamline.filters import retains_activity_filter
    
    string_test_source(["ABC", "ACB", "EFG"]).pipe(
        retains_activity_filter("G")
    ).subscribe(lambda x: print(str(x)))
    ```

??? note "Details on `excludes_activity_filter`"
    Excludes activities base on their name (`concept:name`).
    ```python
    from pybeamline.sources import string_test_source
    from pybeamline.filters import excludes_activity_filter
    
    string_test_source(["ABC", "ACB", "EFG"]).pipe(
        excludes_activity_filter("A"),
    ).subscribe(lambda x: print(str(x)))
    ```

Please note that filters can be chained together in order to achieve the desired result.


### Mappers and mining algorithms

pyBeamline comes with some mining algorithms, which are essentially instantiations of [`map`](https://reactivex.io/documentation/operators/map.html) and [`flatMap`](https://reactivex.io/documentation/operators/flatmap.html) operators. This section reports some detail on these.

#### Mining techniques

In the core of the pyBeamline library, currently, there is only one mining algorithm implemented:

??? note "Details on `infinite_size_directly_follows_mapper`"
    An algorithm that transforms each pair of consequent event appearing in the same case as a directly follows operator (generating a tuple with the two event names). This mapper is called *infinite* because it's memory footprint will grow as the case ids grow.

    An example of how the algorithm can be used is the following:

    ```python
    from pybeamline.sources import string_test_source
    from pybeamline.mappers import infinite_size_directly_follows_mapper

    string_test_source(["ABC", "ACB"]).pipe(
        infinite_size_directly_follows_mapper()
    ).subscribe(lambda x: print(str(x)))
    ```
    This code will print:
    ```
    ('A', 'B')
    ('B', 'C')
    ('A', 'C')
    ('C', 'B')
    ```

#### Windowing techniques

ReactiveX comes with a very rich set of [windowing operators](https://ninmesara.github.io/RxPY/api/operators/window.html) that can be fully reused in pyBeamline. Applying a windowing techniques allows the reusage of offline algorithms (for example implemented in PM4PY) as each window is converted into a Pandas DataFrame.

To transform the window into a DataFrame, the `sliding_window_to_log` operators need to be piped to the source.

??? note "Details on `sliding_window_to_log`"
    Let's assume, that we want to apply the [DFG discovery implemented on PM4PY](https://pm4py.fit.fraunhofer.de/static/assets/api/2.3.0/pm4py.html#pm4py.discovery.discover_dfg_typed) on a stream usind a tumbling window of size 3. We can pipe the window operator to the `sliding_window_to_log` so that we can subscribe to `EventLog`s objects.

    An example is shown in the following:
    ```python
    from pybeamline.sources import string_test_source
    from pybeamline.mappers import sliding_window_to_log
    from reactivex import operators as ops
    import pm4py

    string_test_source(["ABC", "ABD"]).pipe(
        ops.window_with_count(3),
        sliding_window_to_log()
    ).subscribe(lambda x: print(pm4py.discover_dfg_typed(x)))
    ```
    This code will print:
    ```
    Counter({('A', 'B'): 1, ('B', 'C'): 1})
    Counter({('A', 'B'): 1, ('B', 'D'): 1})
    ```
    As can be seen the 2 DFGs are mined from the 2 traces separately (as the tumbling window has size 3, which corresponds to the size of each trace). Using a tumbling window of size 6 (i.e., `ops.window_with_count(6)`) will produce the following:
    ```
    Counter({('A', 'B'): 2, ('B', 'C'): 1, ('B', 'D'): 1})
    ```
    In this case, the only model extracted embeds both traces inside.