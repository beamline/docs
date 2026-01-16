# soft_conformance

This conformance approach uses a descriptive model (i.e., a pattern of the observed behavior over a certain amount of time) which is not necessarily referring to the control-flow (e.g., it can be based on the social network of handover of work). To create such a model you need to specify the states and the probability of transitioning.

## Parameters

* **model**: `Pdfa`  
  The reference PDFA model.

* **alpha**: `float`  
  Likelihood of a random walk (i.e., the parameter α).

* **max_cases_to_store**: `int` default `1000`  
  Maximum number of cases to store.

* **result_refresh_rate**: `int` default `10`  
  How often the results should be propagated.


## Returned type

The returned output has type `SoftConformanceReport` which is `Dict[str, SoftConformanceStatus]`, where the key is the case id and the `SoftConformanceStatus` has the following methods:

* `get_last_probability()`
* `get_sequence_probability()`
* `get_sequence_log_probability()`
* `get_mean_probabilities()`
* `get_soft_conformance()`
* `get_last_update()`


## Example

```python
from pybeamline.algorithms.conformance.soft.pdfa_conformance import soft_conformance
from pybeamline.algorithms.lambda_operator import lambda_operator
from pybeamline.models.pdfa.pdfa import Pdfa
from pybeamline.sinks.print_sink import print_sink
from pybeamline.sources import log_source

pdfa = Pdfa()
pdfa.add_node("A")
pdfa.add_node("B")
pdfa.add_node("C")
pdfa.add_edge("A", "A", 0.2)
pdfa.add_edge("A", "B", 0.8)
pdfa.add_edge("B", "C", 1.0)

log_source(["ABC", "ACBDE"]).pipe(
    soft_conformance(pdfa, 0.5, 100, 1),
    lambda_operator(lambda x: sum(c.get_soft_conformance() for c in x.values()) / len(x))
).subscribe(print_sink())
```

Output:

```
0.0
0.85
0.925
0.4625
0.5875
0.5875
0.5458333333333334
0.525
```

## References

The algorithm is describe in:

* [Online Soft Conformance Checking: Any Perspective Can Indicate Deviations](https://andrea.burattin.net/publications/2022-arxiv)  
  A. Burattin  
  In *arXiv:2201.09222*, Jan. 2022.
