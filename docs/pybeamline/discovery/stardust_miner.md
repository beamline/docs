# stardust_miner

A streaming process discovery operator that implements STARDUST. It tracks completed trace variants, samples the most frequent variants, and discovers a new process model when the sampled behavior changes.

The input stream must contain `BEvent` events. By default, an event with activity name `?` marks a case as complete. That marker is not included in the trace. You can set a different marker with `completion_activity`.


## Parameters

* **initialization_traces**: `int` default: `100`  
  Number of completed traces to collect before discovering the initial model.

* **sampling_rate**: `float` default: `0.8`  
  Fraction of active trace occurrences to cover by selecting the most frequent variants. Must be greater than 0 and at most 1.

* **forgetting_size**: `int` default: `100`  
  Number of completed traces after which a variant is removed if it has not occurred again.

* **completion_activity**: `str` default: `?`  
  Activity name that marks the end of a case. The completion event is not part of the trace variant.

* **max_consecutive_repetitions**: `Optional[int]` default: `2`  
  Maximum number of consecutive identical activities retained in a trace. Set to None to preserve all repetitions.

* **discovery_algorithm**: `Callable` default: `None`  
  Optional function that receives a mapping of trace variants to frequencies and returns a model. If omitted, the PM4Py Inductive Miner is used.

* **conformance_evaluator**: `Callable` default: `None`  
  Optional function called as conformance_evaluator(model, trace_variant) for each completed trace after initialization. Its result is stored in the emitted update’s conformance field.


The discovery callback receives a mapping like `{("A", "B"): 3, ("A", "C"): 1}`. A trace variant is a tuple of activity names, and its value is the number of occurrences in the active trace data.





## Returned type

`stardust_miner` returns a `StardustMapper`, a `BaseMap` that transforms a stream of `BEvent` values into a stream of `StardustUpdate` values.

An update contains:
* `completed_traces`: number of completed traces seen so far
* `case_id`: case that just completed
* `initial_model`: whether this is the initial model
* `drift_detected`: whether the sampled behavior changed
* `model_updated`: whether a new model was discovered
* `active_variants`: active trace variants and their frequencies
* `sampled_variants`: sampled trace variants and their frequencies
* `model`: discovered process model
* `conformance`: value from the optional conformance evaluator, or None

The miner emits an update after initial discovery and after each detected drift. When `conformance_evaluator` is provided, it also emits an observation for each later completed trace, even when the model stays unchanged. The evaluator runs against the current model before the completed trace can trigger a model update.

If the source does not provide completion events, call `miner.complete_case(case_id)` directly to complete a case.


## Example

```python
from pybeamline.algorithms.discovery import stardust_miner
from pybeamline.sinks import print_sink
from pybeamline.sources import log_source

def discover(sampled_variants):
    return dict(sampled_variants)

log_source(["AB?", "AB?", "AC?"]).pipe(
    stardust_miner(
        initialization_traces=2,
        sampling_rate=1.0,
        forgetting_size=10,
        discovery_algorithm=discover,
    )
).subscribe(print_sink())

```

Output:

```
StardustUpdate(completed_traces=2, case_id='case_2', initial_model=True, drift_detected=False, model_updated=True, active_variants={('A', 'B'): 2}, sampled_variants={('A', 'B'): 2}, model={('A', 'B'): 2}, conformance=None)
StardustUpdate(completed_traces=3, case_id='case_3', initial_model=False, drift_detected=True, model_updated=True, active_variants={('A', 'B'): 2, ('A', 'C'): 1}, sampled_variants={('A', 'B'): 2, ('A', 'C'): 1}, model={('A', 'B'): 2, ('A', 'C'): 1}, conformance=None)
```

## References

The algorithm is described in publication:

* [STARDUST: A Novel Process Mining Approach to Discover Evolving Models From Trace Streams](https://dx.doi.org/10.1109/TSC.2022.3215502)  
  V. Pasquadibisceglie, A. Appice, G. Castellano, N. Fiorentino, D. Malerba
  In *IEEE Transactions on Services Computing* - 2023, Volume 16, Issue 4, pp. 2970-2984.
