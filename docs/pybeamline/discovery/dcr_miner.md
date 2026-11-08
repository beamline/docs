# dcr_miner


`dcr_miner` is a streaming discovery operator that mines a Dynamic Condition Response (DCR) graph from `BEvent` events. It maintains a window of partial traces, derives an extended directly-follows graph (DFG), and periodically discovers DCR relations from that summary.

## Parameters

* **model_update_frequency**: `int` default: `10`  
  Emit a new graph after every this many input events. The count is global across cases and starts with the first event.

* **max_traces**: `int | None` default: `20`  
  Maximum number of cases retained. When the limit is reached, the least recently updated case is evicted. Use `None` for no case limit.

* **max_events_per_trace**: `int | None` default: `10`  
  Maximum number of most recent activities retained for each case. Use `None` to retain each case's full trace.

* **relations_threshold**: `int` default: `0`  
  Minimum DFG edge frequency required for mining. An edge is used only when its frequency is strictly greater than this value.

* **dcr_patterns**: `Iterable[str]` default: `("Condition", "Response", "Exclude", "Include")`  
  Patterns to discover. Supported names are `Condition`, `Response`, `Exclude`, `Include`, and `Sequence` (case insensitive). `Sequence` is used internally to derive `Include` and `Exclude`; it is not a separate relation in the returned DCR graph.

* **transitive_reduction**: `Iterable[str]` default: `("Condition", "Response")`  
  Relation types to transitively reduce after mining. Supported names are `Condition`, `Response`, `Include`, and `Exclude`. Use an empty iterable to disable reduction.

For each retained case, the event's trace name is the case identifier and the event name is the activity. Cases do not need an explicit completion event. `max_traces=None` and `max_events_per_trace=None` together retain all observed
events.





## Returned type

The operator is a `DCRMiner`, a pyBeamline `BaseMap` from `BEvent` to `DCRGraph`. When applied to a stream, it emits a `DCRGraph` every `model_update_frequency` input events. `DCRGraph` contains:

* `activities`: the activities in the current trace window.
* `conditions`, `responses`, `includes`, and `excludes`: sets of
  `(source_activity, target_activity)` pairs.
* `marking`: the initial `DCRMarking`; no activities are executed or pending,
  and every discovered activity starts included.


## Example

```python
from pybeamline.algorithms.discovery import dcr_miner
from pybeamline.sinks import print_sink
from pybeamline.sources import log_source

log_source(["AB", "AB"]).pipe(
    dcr_miner(
        model_update_frequency=4,
        max_traces=5,
        max_events_per_trace=5,
    )
).subscribe(print_sink())

```

Output:

```
DCRGraph(activities=frozenset({'B', 'A'}), conditions=frozenset({('A', 'B')}), responses=frozenset({('A', 'B')}), includes=frozenset({('A', 'B')}), excludes=frozenset({('B', 'B'), ('B', 'A'), ('A', 'A')}), marking=DCRMarking(executed=frozenset(), pending=frozenset(), included=frozenset({'B', 'A'})))

```

## References

The algorithm is described in publication:

* [Uncovering Change: A Streaming Approach for Declarative Processes](https://andrea.burattin.net/publications/2022-sa4pm)  
  A. Burattin, H. A. López, L. Starklit  
  In Proceedings of ICPM Workshop (SA4PM), 2022.
