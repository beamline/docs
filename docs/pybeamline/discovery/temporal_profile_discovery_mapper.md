# temporal_profile_discovery_mapper

An algorithm to extract a temporal profile.


## Parameters

* *None*


## Returned type

The returned output has type `pm4py.util.typing.TemporalProfile`.


## Example

```python
from pybeamline.sources import log_source
from pybeamline.algorithms.discovery.temporal_profile import temporal_profile_discovery_mapper
from pybeamline.sinks.print_sink import print_sink

log_source(["ABC","ABC","DEF"]).pipe(
	temporal_profile_discovery_mapper()
).subscribe(print_sink())
```

Output:

```
...
```

## References

The algorithm is describe in publications:

* [Temporal Conformance Checking at Runtime Based on Time-infused Process Models](https://arxiv.org/abs/2008.07262)  
  F. Stertz, J/ Mangler, and S. Rinderle-Ma  
  In *arXiv preprint arXiv:2008.07262* (2020).
