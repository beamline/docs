# pyBeamline

[![PyPI version](https://badge.fury.io/py/pybeamline.svg)](https://badge.fury.io/py/pybeamline)

pyBeamline is a Python version of Beamline. While the same set of ideas and principles of Beamline have been ported into pyBeamline, the underlying goal and technology are very different.

pyBeamline is based on [ReactiveX](https://reactivex.io/) and its Python binding [RxPY](https://rxpy.readthedocs.io/en/latest/). RxPY is a library for composing asynchronous and event-based programs using observable sequences and pipable query operators in Python. Using pyBeamline it is possible to inject process mining operators into the computation.

A complete Jupyter notebook presenting all implemented techniques is available at <https://github.com/beamline/pybeamline/blob/master/tutorial.ipynb>.

<a target="_blank" href="https://colab.research.google.com/github/beamline/pybeamline/blob/master/tutorial.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>


#### Goals and differences with Beamline

The main difference between Beamline and pyBeamline is the language they are built in (Beamline is written in Java, pyBeamline is written in Python). However, differences do not stop here. In particular, Beamline is built on top of Apache Flink, which makes it suitable for extremely efficient computation due to the distributed and stateful nature of its components. pyBeamline, on the other end, is built on top of ReactiveX which is
> an extension of the observer pattern to support sequences of data and/or events and adds operators that allow you to compose sequences together declaratively while abstracting away concerns about things like low-level threading, synchronization, thread-safety, concurrent data structures, and non-blocking I/O. <cite>(From <https://reactivex.io/intro.html>)</cite>

Therefore, pyBeamline is suited for prototyping algorithm very quickly, without necessarily bothering with performance aspects. In a sense, it simplifies the construction of proof of concepts, before translating the algorithms into Beamline for proper testing and verification. Also, it simplifies collaboration by, for example, leveraging online services (like Google Colab).

To give an example of such simplicity, this is the ***complete code*** to discover a DFG using a sliding window from a stream generated from a `test.xes` file (a file is used instead of a proper stream, as we are in a very controlled setting):

```python
from pybeamline.sources import xes_log_source_from_file
from pybeamline.mappers import sliding_window_to_log
from reactivex.operators import window_with_count
from pm4py import discover_dfg_typed

xes_log_source_from_file("test.xes").pipe(
    window_with_count(6),
    sliding_window_to_log()
).subscribe(lambda log: print(discover_dfg_typed(log)))
```


#### Differences with PM4PY

PM4PY has a [package dedicated to streaming algorithms](https://pm4py.fit.fraunhofer.de/static/assets/api/2.3.0/pm4py.streaming.html). This package, however, does not allow the construction of [the dataflow for the processing of the events](https://en.wikipedia.org/wiki/Dataflow). Instead, it allows the application of a single algorithm on a defined stream. While this might be useful in certain situation, having the ability to construct the dataflow represents a fundamental architecture for stream processing.

??? note "What is a dataflow?"
    Here is the definition from the [corresponding Wikipedia page](https://en.wikipedia.org/wiki/Dataflow):
    > In computing, dataflow is a broad concept, which has various meanings depending on the application and context. In the context of software architecture, data flow relates to stream processing or reactive programming.

    > [...]
    
    > Dataflow computing is a software paradigm based on the idea of representing computations as a directed graph, where nodes are computations and data flow along the edges. Dataflow can also be called stream processing or reactive programming.
    
    > There have been multiple data-flow/stream processing languages of various forms (see Stream processing). Data-flow hardware (see Dataflow architecture) is an alternative to the classic von Neumann architecture. The most obvious example of data-flow programming is the subset known as reactive programming with spreadsheets. As a user enters new values, they are instantly transmitted to the next logical "actor" or formula for calculation.
    
    > Distributed data flows have also been proposed as a programming abstraction that captures the dynamics of distributed multi-protocols. The data-centric perspective characteristic of data flow programming promotes high-level functional specifications and simplifies formal reasoning about system components.





## Installing the library

To use pyBeamline on any OS, install it using `pip`:
```bash
pip install pybeamline
```
More information are available at <https://pypi.org/project/pybeamline/>.


## Basic concepts

In this section the basic concepts of pyBeamline are presented.


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

In the context of Beamline it is possible to define observables of any type. The framework comes with some observables already defined. Sources already implemented are `xes_log_source`, `xes_log_source_from_file`, and `string_test_source`. A `xes_log_source` creates a source from a static log (useful for testing purposes), `xes_log_source_from_file` creates a source from an XES file, and `string_test_source` allows the definition of simple log directly in its constructor (useful for testing purposes).

??? note "Details on `xes_log_source` and `xes_log_source_from_file`"
    Emits all events from an XES event log. Example usage:
    ```python
    import pm4py
    from pybeamline.sources import xes_log_source

    xes_log_source(pm4py.read_xes("test.xes")) \
        .subscribe(lambda x: print(str(x)))
    ```

    A shortcut to load from a file is:
    ```python
    import pm4py
    from pybeamline.sources import xes_log_source_from_file

    xes_log_source_from_file("test.xes") \
        .subscribe(lambda x: print(str(x)))
    ```


??? note "Details on `string_test_source`"
    Source that considers each trace as a string provided in the constructor and each event as one character of the string. Example usage:
    ```python
    from pybeamline.sources import string_test_source

    string_test_source(["ABC", "ACB", "EFG"]) \
        .subscribe(lambda x: print(str(x)))
    ```


??? note "Details on `mqttxes_source`"
    Source that connects to an MQTT endpoint and expects events to be published according to the MQTT-XES format (see https://beamline.cloud/mqtt-xes/). Example usage:
    ```python
    from pybeamline.sources import mqttxes_source

    mqttxes_source('broker.mqtt.cool', 1883, 'base/topic/') \
        .subscribe(lambda x: print(str(x)))

    input()
    ```
    Where `broker.mqtt.cool` is the URL of the MQTT broker, 1883 is the broker port, and `base/topic/` is the base topic. Please note the `input()` at the end, which is necessary to avoid that the application terminates thus not receiving any more events.

For convenience, another source called `log_source` is defined. This just combines dispatches the call to the other sources, based on a match performed on the input type.

??? note "Details on `log_source`"
    Example of usages:
    ```python
    log_source("test.xes") # This is equivalent to xes_log_source_from_file("test.xes")
    ```
    ```python
    log = pm4py.read_xes("test.xes")
    log_source(log) # This is equivalent to xes_log_source(log)
    ```
    ```python
    log_source(["ABC", "ACB", "EFG"]) # This is equivalent to string_test_source(["ABC", "ACB", "EFG"])
    ```

### Combining sources

In order to build tests where drifts occur in a controlled setting, it is possible to concatenate different sources together. See the example below:
```python
from reactivex import concat
from pybeamline.sources import xes_log_source_from_file, log_source

src1 = xes_log_source_from_file("tests/log.xes")
src2 = log_source(["ABCD", "ABCD"])
src3 = xes_log_source_from_file("tests/log.xes")

concat = concat(src1, src2, src3)
concat \
    .subscribe(lambda x: print(str(x)))
```


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

Filters can operate on event attributes or trace attributes and the following are currently available:

??? note "Details on `retains_on_event_attribute_equal_filter`"
    Retains events based on the equality of an event attribute. Example:
    ```python
    from pybeamline.sources import log_source
    from pybeamline.filters import retains_on_event_attribute_equal_filter

    log_source("test.xes").pipe(
        retains_on_event_attribute_equal_filter("event-attrib", ["ev", "ab"]),
    ).subscribe(lambda x: print(str(x)))
    ```

??? note "Details on `excludes_on_event_attribute_equal_filter`"
    Exclude events based on the equality of an event attribute.
    ```python
    from pybeamline.sources import log_source
    from pybeamline.filters import excludes_on_event_attribute_equal_filter
    
    log_source("test.xes").pipe(
        excludes_on_event_attribute_equal_filter("event-attrib", ["ev", "ab"]),
    ).subscribe(lambda x: print(str(x)))
    ```

??? note "Details on `retains_on_trace_attribute_equal_filter`"
    Retains events based on the equality of a trace attribute.
    ```python
    from pybeamline.sources import log_sourcelog_source
    from pybeamline.filters import retains_on_trace_attribute_equal_filter
    
    log_source("test.xes").pipe(
        retains_on_trace_attribute_equal_filter("trace-attrib", ["tv", "ab"]),
    ).subscribe(lambda x: print(str(x)))

    ```

??? note "Details on `excludes_on_trace_attribute_equal_filter`"
    Excludes events based on the equality of a trace attribute.
    ```python
    from pybeamline.sources import log_source
    from pybeamline.filters import excludes_on_trace_attribute_equal_filter
    
    log_source("test.xes").pipe(
        excludes_on_trace_attribute_equal_filter("trace-attrib", ["tv", "ab"]),
    ).subscribe(lambda x: print(str(x)))

    ```

??? note "Details on `retains_activity_filter`"
    Retains activities base on their name (`concept:name`).
    ```python
    from pybeamline.sources import log_source
    from pybeamline.filters import retains_activity_filter
    
    log_source(["ABC", "ACB", "EFG"]).pipe(
        retains_activity_filter("G")
    ).subscribe(lambda x: print(str(x)))
    ```

??? note "Details on `excludes_activity_filter`"
    Excludes activities base on their name (`concept:name`).
    ```python
    from pybeamline.sources import log_source
    from pybeamline.filters import excludes_activity_filter
    
    log_source(["ABC", "ACB", "EFG"]).pipe(
        excludes_activity_filter("A"),
    ).subscribe(lambda x: print(str(x)))
    ```

Please note that filters can be chained together in order to achieve the desired result.


### Mappers and mining algorithms

pyBeamline comes with some mining algorithms, which are essentially instantiations of [`map`](https://reactivex.io/documentation/operators/map.html) and [`flatMap`](https://reactivex.io/documentation/operators/flatmap.html) operators. This section reports some detail on these.

#### Discovery techniques

In the core of the pyBeamline library, currently, there is only one mining algorithm implemented:

??? note "Details on `infinite_size_directly_follows_mapper`"
    An algorithm that transforms each pair of consequent event appearing in the same case as a directly follows operator (generating a tuple with the two event names). This mapper is called *infinite* because it's memory footprint will grow as the case ids grow.

    An example of how the algorithm can be used is the following:

    ```python
    from pybeamline.sources import log_source
    from pybeamline.mappers import infinite_size_directly_follows_mapper

    log_source(["ABC", "ACB"]).pipe(
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

??? note "Details on `heuristics_miner_lossy_counting`"
    An algorithm to mine a Heuristics Net using the Lossy Counting algorithm. The Heuristics Net is the same type as in the PM4PY library (see <https://pm4py.fit.fraunhofer.de/documentation#item-3-3>)

    An example of how the algorithm can be used is the following:

    ```python
    from pybeamline.algorithms.discovery import heuristics_miner_lossy_counting

    log_source(["ABCD", "ABCD"]).pipe(
        heuristics_miner_lossy_counting(model_update_frequency=4)
    ).subscribe(lambda x: print(str(x)))

    ```
    This code will print:
    ```
    {'A': (node:A connections:{B:[0.5]}), 'B': (node:B connections:{C:[0.5]}), 'C': (node:C connections:{})}
    {'C': (node:C connections:{D:[0.5]}), 'D': (node:D connections:{}), 'A': (node:A connections:{B:[0.6666666666666666]}), 'B': (node:B connections:{C:[0.6666666666666666]})}
    ```

    The algorithm is describe in publications:
    
    * [Control-flow Discovery from Event Streams](https://andrea.burattin.net/publications/2014-cec)  
    A. Burattin, A. Sperduti, W. M. P. van der Aalst  
    In *Proceedings of the Congress on Evolutionary Computation* (IEEE WCCI CEC 2014); Beijing, China; July 6-11, 2014.
    * [Heuristics Miners for Streaming Event Data](https://andrea.burattin.net/publications/2012-corr-stream)  
    A. Burattin, A. Sperduti, W. M. P. van der Aalst  
    In *CoRR* abs/1212.6383, Dec. 2012.


??? note "Details on `heuristics_miner_lossy_counting_budget`"
    An algorithm to mine a Heuristics Net using the Lossy Counting with Budget algorithm. The Heuristics Net is the same type as in the PM4PY library (see <https://pm4py.fit.fraunhofer.de/documentation#item-3-3>)

    An example of how the algorithm can be used is the following:

    ```python
    from pybeamline.algorithms.discovery import heuristics_miner_lossy_counting_budget

    log_source(["ABCD", "ABCD"]).pipe(
        heuristics_miner_lossy_counting_budget(model_update_frequency=4)
    ).subscribe(lambda x: print(str(x)))
    ```
    This code will print:
    ```
    {'A': (node:A connections:{B:[0.5]}), 'B': (node:B connections:{C:[0.5]}), 'C': (node:C connections:{D:[0.5]}), 'D': (node:D connections:{})}
    {'A': (node:A connections:{B:[0.6666666666666666]}), 'B': (node:B connections:{C:[0.6666666666666666]}), 'C': (node:C connections:{D:[0.6666666666666666]}), 'D': (node:D connections:{})}
    ```

    The algorithm is describe in publications:
    
    * [Control-flow Discovery from Event Streams](https://andrea.burattin.net/publications/2014-cec)  
    A. Burattin, A. Sperduti, W. M. P. van der Aalst  
    In *Proceedings of the Congress on Evolutionary Computation* (IEEE WCCI CEC 2014); Beijing, China; July 6-11, 2014.
    * [Heuristics Miners for Streaming Event Data](https://andrea.burattin.net/publications/2012-corr-stream)  
    A. Burattin, A. Sperduti, W. M. P. van der Aalst  
    In *CoRR* abs/1212.6383, Dec. 2012.


#### Conformance checking techniques

Currently only conformance checking using behavioral profiles is supported.

??? note "Details on `behavioral_conformance`"
    An algorithm to compute the conformance using behavioral patterns.

    An example of how the algorithm can be used is the following:

    ```python
    from pybeamline.algorithms.conformance import mine_behavioral_model_from_stream, behavioral_conformance

    source = log_source(["ABCD", "ABCD"])
    reference_model = mine_behavioral_model_from_stream(source)
    print(reference_model)

    log_source(["ABCD", "ABCD"]).pipe(
        excludes_activity_filter("A"),
        behavioral_conformance(reference_model)
    ).subscribe(lambda x: print(str(x)))
    ```
    This code will print:
    ```
    ([('A', 'B'), ('B', 'C'), ('C', 'D')], {('A', 'B'): (0, 0), ('B', 'C'): (1, 1), ('C', 'D'): (2, 2)}, {('A', 'B'): 2, ('B', 'C'): 1, ('C', 'D'): 0})
    (1.0, 0.5, 1)
    (1.0, 1.0, 1)
    (1.0, 0.5, 1)
    (1.0, 1.0, 1)
    ```
    The algorithm is describe in the publication:
    
    * [Online Conformance Checking Using Behavioural Patterns](https://andrea.burattin.net/publications/2018-bpm)  
    A. Burattin, S. van Zelst, A. Armas-Cervantes, B. van Dongen, J. Carmona  
    In *Proceedings of BPM 2018*; Sydney, Australia; September 2018.


#### Windowing techniques

ReactiveX comes with a very rich set of [windowing operators](https://ninmesara.github.io/RxPY/api/operators/window.html) that can be fully reused in pyBeamline. Applying a windowing techniques allows the reusage of offline algorithms (for example implemented in PM4PY) as each window is converted into a Pandas DataFrame.

To transform the window into a DataFrame, the `sliding_window_to_log` operators need to be piped to the source.

??? note "Details on `sliding_window_to_log`"
    Let's assume, that we want to apply the [DFG discovery implemented on PM4PY](https://pm4py.fit.fraunhofer.de/static/assets/api/2.3.0/pm4py.html#pm4py.discovery.discover_dfg_typed) on a stream usind a tumbling window of size 3. We can pipe the window operator to the `sliding_window_to_log` so that we can subscribe to `EventLog`s objects.

    An example is shown in the following:
    ```python
    from pybeamline.sources import log_source
    from pybeamline.mappers import sliding_window_to_log
    from reactivex.operators import window_with_count
    import pm4py

    def mine(log):
        print(pm4py.discover_dfg_typed(x))

    log_source(["ABC", "ABD"]).pipe(
        window_with_count(3),
        sliding_window_to_log()
    ).subscribe(mine)
    ```
    This code will print:
    ```
    Counter({('A', 'B'): 1, ('B', 'C'): 1})
    Counter({('A', 'B'): 1, ('B', 'D'): 1})
    ```
    As can be seen the 2 DFGs are mined from the 2 traces separately (as the tumbling window has size 3, which corresponds to the size of each trace). Using a tumbling window of size 6 (i.e., `window_with_count(6)`) will produce the following:
    ```
    Counter({('A', 'B'): 2, ('B', 'C'): 1, ('B', 'D'): 1})
    ```
    In this case, the only model extracted embeds both traces inside.

## Citation

Please, cite this work as:

* Andrea Burattin. "[Beamline: A comprehensive toolkit for research and development of streaming process mining](http://dx.doi.org/10.1016/j.simpa.2023.100551)". In *Software Impacts*, vol. 17 (2023).
