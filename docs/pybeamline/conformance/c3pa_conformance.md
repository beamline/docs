# c3pa_conformance

`c3pa_conformance` is a streaming conformance operator based on C-3PA. It compares each `BEvent` with a finite trie of model traces and emits a prefix alignment with conformance cost, completeness, and confidence for each active case. The case identifier comes from `BEvent.get_trace_name()` and the activity from `BEvent.get_event_name()`.

The trie can be built by sampling complete traces from a PM4Py Petri net, or provided directly as `proxy_traces`. Since the trie represents only those finite traces, behavior missing from the proxy traces cannot be matched.


## Parameters

* **reference_model**: `pm4py.objects.petri_net.obj.PetriNet | None` default: `None`  
  Petri net to sample for the proxy trie. Required with both markings when `proxy_traces` is omitted.

* **initial_marking**: `pm4py.objects.petri_net.obj.Marking | None` default: `None`  
  Starting marking used to sample traces from `reference_model`. Provide together with `final_marking`.

* **final_marking**: `pm4py.objects.petri_net.obj.Marking | None` default: `None`  
  Marking at which a sampled model trace is considered complete. Provide together with `initial_marking`.

* **proxy_traces**: `Iterable[Iterable[str]] | None` default: `None`  
  Optional finite sample of model traces. Each inner iterable contains activity labels. When supplied, a Petri net and markings are not required.

* **num_model_traces**: `int` default: `2000`  
  Maximum number of complete traces to sample from the Petri net when `proxy_traces` is omitted.

* **max_model_steps**: `int` default: `100`  
  Maximum transition firings in one sampling attempt, including silent transitions.

* **random_seed**: `int` default: `0`  
  Seed for reproducible model-trace sampling.

* **warm_start**: `bool` default: `True`  
  Allow an event to align with matching trie nodes after an unobserved model prefix. The skipped prefix is recorded as completeness.

* **state_decay_time**: `int | None` default: `100`  
  Maximum number of stream events without model progress before a candidate state expires. Use `None` to disable state decay.

* **max_states_per_case**: `int` default: `1000`  
  Maximum number of candidate alignment states retained for one case. The lowest guiding-cost states are retained.

* **max_cases**: `int` default: `10000`  
  Maximum number of active cases. On overflow, the least recently updated case and its states are evicted.

All numeric limits must be positive integers. If no complete trace can be sampled within the configured model-step bound, construction raises `ValueError`; provide `proxy_traces` or increase `max_model_steps` in that case.


## Returned type

It emits a new snapshot of `C3PAResult` after every input event. Each `C3PAResult` has:

* `alignment`: a tuple of `(log_activity, model_activity)` pairs. `None` on
  either side represents a skip (`>>`).
* `cost`: the number of log and model moves in the selected prefix alignment.
* `completeness`: the number of model activities estimated to have occurred
  before the observed prefix began.
* `confidence`: the average shortest remaining distance from the selected trie
  node to a trie leaf. This is a distance measure, not a probability; larger
  values indicate more average model behavior remaining in the proxy trie.
* `guiding_cost`: `cost + completeness`, used to compare candidate states.



## Example

In this example, the reference model is extracted by a (finite) stream:

```python
from pm4py.objects.petri_net.obj import Marking, PetriNet
from pm4py.objects.petri_net.utils import petri_utils

from pybeamline.algorithms.conformance import c3pa_conformance
from pybeamline.mappers import skip_events
from pybeamline.sinks import print_sink
from pybeamline.sources import log_source

net = PetriNet("A then B")
start = PetriNet.Place("start")
middle = PetriNet.Place("middle")
end = PetriNet.Place("end")
net.places.update((start, middle, end))

activity_a = PetriNet.Transition("t_a", "A")
activity_b = PetriNet.Transition("t_b", "B")
net.transitions.update((activity_a, activity_b))
petri_utils.add_arc_from_to(start, activity_a, net)
petri_utils.add_arc_from_to(activity_a, middle, net)
petri_utils.add_arc_from_to(middle, activity_b, net)
petri_utils.add_arc_from_to(activity_b, end, net)

initial_marking = Marking({start: 1})
final_marking = Marking({end: 1})

checker = c3pa_conformance(
    net,
    initial_marking,
    final_marking,
    num_model_traces=5,
    max_model_steps=2,
    random_seed=0,
    warm_start=False,
)

log_source(["AB", "AC", "CB"]).pipe(
  checker,
  skip_events(2)
).subscribe(print_sink())
```

Output:

```
{'case_1': C3PAResult(alignment=(('A', 'A'), ('B', 'B')), cost=0, completeness=0, confidence=0.0)}
{'case_1': C3PAResult(alignment=(('A', 'A'), ('B', 'B')), cost=0, completeness=0, confidence=0.0), 'case_2': C3PAResult(alignment=(('A', 'A'), ('C', None)), cost=1, completeness=0, confidence=1.0)}
{'case_1': C3PAResult(alignment=(('A', 'A'), ('B', 'B')), cost=0, completeness=0, confidence=0.0), 'case_2': C3PAResult(alignment=(('A', 'A'), ('C', None)), cost=1, completeness=0, confidence=1.0), 'case_3': C3PAResult(alignment=(('C', None), (None, 'A'), ('B', 'B')), cost=2, completeness=0, confidence=0.0)}
```


## References

The algorithm is described in:

* [C-3PA: Streaming Conformance, Confidence and Completeness in Prefix-Alignments](https://andrea.burattin.net/publications/2023-caise-2)  
  K. Raun, M. Nielsen, A. Burattin, A. Awad  
  In *Proceedings of CAiSE 2023*; Zaragoza, Spain; June 2023.
