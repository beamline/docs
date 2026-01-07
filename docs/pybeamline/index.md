index


# pyBeamline




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

#### General sources

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

The following sources offer connections to external services:

??? note "Details on `mqttxes_source`"
    Source that connects to an MQTT endpoint and expects events to be published according to the MQTT-XES format (see https://beamline.cloud/mqtt-xes/). Example usage:
    ```python
    from pybeamline.sources import mqttxes_source

    mqttxes_source('broker.mqtt.cool', 1883, 'base/topic/') \
        .subscribe(lambda x: print(str(x)))

    input()
    ```
    Where `broker.mqtt.cool` is the URL of the MQTT broker, 1883 is the broker port, and `base/topic/` is the base topic. Please note the `input()` at the end, which is necessary to avoid that the application terminates thus not receiving any more events.



#### Real-world sources

In addition to the previous sources these are also implemented. The following sources observe **real data** and hence are not controllable and maybe not suitable for testing.

??? note "Details on `wikimedia_source`"
    Source that connects to the stream of recent change operations happening on the Media Wiki websites (see <https://wikitech.wikimedia.org/wiki/Event_Platform/EventStreams_HTTP_Service> and <https://www.mediawiki.org/wiki/Manual:RCFeed>). Example usage:
    ```python
    from pybeamline.sources.real_world_sources import wikimedia_source

    wikimedia_source() \
        .subscribe(lambda x: print(str(x)))

    input()
    ```
    It is advisable to apply a filter operation to consider only events relevant to one of the websites, such as:
    ```python
    from pybeamline.sources.real_world_sources import wikimedia_source
    from pybeamline.filters import retains_on_event_attribute_equal_filter

    wikimedia_source().pipe(
        retains_on_event_attribute_equal_filter("wiki", ["dewiki"]),
    ).subscribe(lambda x: print(str(x)))

    input()
    ```


??? note "Details on `ais_source`"
    The automatic identification system (AIS) is an automatic tracking system that uses transceivers on ships and is used by vessel traffic services. This source considers the MMSI (<https://en.wikipedia.org/wiki/Maritime_Mobile_Service_Identity>) as the case id and the navigation status (when available) as the activity (<https://en.wikipedia.org/wiki/Automatic_identification_system#Broadcast_information>). While it is possible connect to any AIS data provider (by passing `host` and `port` parameters), by default, the source connects to the Norwegian Coastal Administration server, which publishes data for the from vessels within the Norwegian economic zone and the protection zones off Svalbard and Jan Mayen (see <https://www.kystverket.no/en/navigation-and-monitoring/ais/access-to-ais-data/>).

    **ATTENTION:** while a lot of events are produced by this source, traces are very short and it can take a long time before two events with the same case id are actually observed.

    Example usage:
    ```python
    from pybeamline.sources.real_world_sources import ais_source

    ais_source() \
        .subscribe(lambda x: print(str(x)))
    ```

??? note "Details on `rejseplanen_source`"
    This source provides the data from the Danish railway system. Traces are represented as individual trains and events are trains reaching a certain station. The data is continuously generate (updated every 5 seconds, see <https://www.rejseplanen.dk/bin/help.exe/mn?L=vs_dot.vs_livemap&tpl=fullscreenmap>). The current source retrieves information about regional and light train (letbane).

    Example usage:
    ```python
    from pybeamline.sources.real_world_sources import rejseplanen_source

    rejseplanen_source() \
        .subscribe(lambda x: print(str(x)))
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

??? note "Details on `simple_dfg_miner`"
    An algorithm that simply constructs the DFG considering infinite amount of memory available. It has 2 parameters: the `model_update_frequency` that determines how often the model should be updated, and the `min_relative_frequency` that determines the minimum relative frequency that a directly follow relations should have to be generated.

    An example of how the algorithm can be used is the following:
    ```python
    from pybeamline.sources.real_world_sources import wikimedia_source
    from pybeamline.algorithms.discovery.dfg_miner import simple_dfg_miner

    wikimedia_source().pipe(
        simple_dfg_miner()
    ).subscribe(lambda x: print(str(x)))
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

## Utilities

There are some utilities functionalities implemented in the library. They are listed below:

??? note "Details on `lambda_operator`"
	This function allows the definition of an operator according to a function defined somewhere else. It is the most flexible operator and, in case a value is return, then the pipeline will continue. If `None` is returned, then the pipeline does not continue.

	The example below shows how this operator can be used to define custom filters and custom miners:
	```python
	from pybeamline.algorithms.lambda_operator import lambda_operator
	from pybeamline.sources.string_test_source import string_test_source


	def my_filter(event):
		return event if (event.get_event_name() == "A") else None


	def my_miner(event):
		return [('Start', event.get_event_name())]


	string_test_source(["ABCDE", "ACBDE"]).pipe(
		lambda_operator(my_filter),
		lambda_operator(my_miner)
	).subscribe(lambda x: print(str(x)))
	```



??? note "Details on `dfg_to_graphviz`"
    This function allows the transformation of the DFG produced with the `simple_dfg_miner` into the corresponding Graphviz string. It can be used for visualization of the model.

    An example is shown in the following:
    ```python
    from pybeamline.sources.real_world_sources import wikimedia_source
    from pybeamline.algorithms.discovery.dfg_miner import simple_dfg_miner
    from pybeamline.utils import dfg_to_graphviz

    def display(graphviz_string):
        print(graphviz_string) # In reality, a more advance processing is expected here :)

    wikimedia_source().pipe(
        simple_dfg_miner()
    ).subscribe(lambda x: display(dfg_to_graphviz(x)))
    ```




## Integration with other libraries

### River

River (<https://riverml.xyz/>) is a library to build online machine learning models. Such models operate on data streams. River includes several online machine learning algorithms that can be used for several tasks, including classification, regression, anomaly detection, time series forecasting, etc. The ideology behind River is to be a generic machine learning which allows to perform these tasks in a streaming manner. Indeed, many batch machine learning algorithms have online equivalents. Note that River also supports some more basic tasks. For instance, you might just want to calculate a running average of a data stream.

It is possible to integrate pyBeamline's result into River to leverage its ML capabilities. For example, let's say we want to use concept drift detection using the [ADWIN algorithm](https://riverml.xyz/0.11.0/api/drift/ADWIN/). In particular, we are interested in computing if the frequency of the directly follows relation `BC` changes over time. To accomplish this task, let's first build a log where we artificially inject two of such drifts:

```python
import random

log_original = ["ABCD"]*10000 + ["ACBD"]*500
random.shuffle(log_original)

log_after_drift = ["ABCD"]*500 + ["ACBD"]*10000
random.shuffle(log_after_drift)

log_with_drift = log_source(log_original + log_after_drift + log_original)
```
In this case, we built two logs (`log_original` and `log_after_drift`) which include the same process variants but that differ in the number of occurrences. Finally, we construct our pyBeamline log source `log_with_drift` by concatenating `log_original + log_after_drift + log_original`.

After that we can use the capabilities of pyBeamline and reactivex to construct a pipeline that produce a sequence of frequencies corresponding to the frequency of directly follows relation `BC` in window with length 40 (which is chosen as all our traces have length 4). Also note that we leverage the fact that in all our events when `B` and `C` appear they are always in the same trace (because of how `log_source` generates the observable). We will later define a function `check_for_drift`:

```python
import reactivex
from reactivex import operators as ops

log_with_drift.pipe(
  ops.buffer_with_count(40),
  ops.flat_map(lambda events: reactivex.from_iterable(events).pipe(
      ops.pairwise(),
      ops.filter(lambda x: x[0].get_trace_name() == x[1].get_trace_name() and x[0].get_event_name() == "B" and x[1].get_event_name() == "C"),
      ops.count()
      )
  )
).subscribe(lambda x: print(x))
```
After this we can define our function for drift detection and collection of points and drift indexes using:
```python
from reactivex import operators as ops
from river import drift

drift_detector = drift.ADWIN()
data = []
drifts = []

def check_for_drift():
  index = 0

  def _process(x):
    nonlocal index
    drift_detector.update(x)
    index = index + 1
    if drift_detector.drift_detected:
      drifts.append(index)

  def _check_for_drift(obs):
    return obs.pipe(ops.do_action(lambda value: _process(value)))

  return _check_for_drift
```
With this function available, `check_for_drift` can now be piped to the previous computation. Plotting the frequencies and the concept drifts will result in the following:

![](https://github.com/beamline/docs/blob/main/site/img/drifts.png?raw=true)

For a complete working example, see <https://github.com/beamline/pybeamline/blob/master/tutorial.ipynb>.

## Citation

Please, cite this work as:

* Andrea Burattin. "[Beamline: A comprehensive toolkit for research and development of streaming process mining](http://dx.doi.org/10.1016/j.simpa.2023.100551)". In *Software Impacts*, vol. 17 (2023).
