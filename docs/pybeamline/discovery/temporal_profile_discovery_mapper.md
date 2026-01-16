# temporal_profile_discovery_mapper

An algorithm to extract a temporal profile.


## Parameters

* *None*


## Returned type

The returned output has type `pm4py.util.typing.TemporalProfile`. See [`temporal_profile_conformance`](../conformance/temporal_profile_conformance.md).


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
{}
{('A', 'B'): (0.088598, 0.0)}
{('A', 'B'): (0.088598, 0.0), ('A', 'C'): (0.14812, 0.0), ('B', 'C'): (0.059522, 0.0)}
{('A', 'B'): (0.088598, 0.0), ('A', 'C'): (0.14812, 0.0), ('B', 'C'): (0.059522, 0.0)}
{('A', 'B'): (0.061631, 0.03813709713651525), ('A', 'C'): (0.14812, 0.0), ('B', 'C'): (0.059522, 0.0)}
{('A', 'B'): (0.061631, 0.03813709713651525), ('A', 'C'): (0.1078875, 0.05689734714817555), ('B', 'C'): (0.0462565, 0.018760250011660293)}
{('A', 'B'): (0.061631, 0.03813709713651525), ('A', 'C'): (0.1078875, 0.05689734714817555), ('B', 'C'): (0.0462565, 0.018760250011660293)}
{('A', 'B'): (0.061631, 0.03813709713651525), ('A', 'C'): (0.1078875, 0.05689734714817555), ('B', 'C'): (0.0462565, 0.018760250011660293), ('D', 'E'): (0.029873, 0.0)}
{('A', 'B'): (0.061631, 0.03813709713651525), ('A', 'C'): (0.1078875, 0.05689734714817555), ('B', 'C'): (0.0462565, 0.018760250011660293), ('D', 'E'): (0.029873, 0.0), ('D', 'F'): (0.060462999999999996, 0.0), ('E', 'F'): (0.03059, 0.0)}
```

## References

The algorithm is describe in publications:

* [Temporal Conformance Checking at Runtime Based on Time-infused Process Models](https://arxiv.org/abs/2008.07262)  
  F. Stertz, J/ Mangler, and S. Rinderle-Ma  
  In *arXiv preprint arXiv:2008.07262* (2020).
