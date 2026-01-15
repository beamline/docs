# temporal_profile_conformance

An algorithm to compute the temporal profile conformance.


## Parameters

* **temporal_profile**: `TemporalProfile`  
  The reference temporal profile for the conformance.

* **parameters**: `Dict` default: `None`
  Set of additional parameters as specified in `pm4py.streaming.algo.conformance.temporal.variants.classic.TemporalProfileStreamingConformance`.


## Returned type

The returned output has type `pm4py.util.typing.TemporalProfileStreamingConfResults`.


## Example

```python
from pybeamline.algorithms.conformance.temporal_profile.temporal_profile_conformance import temporal_profile_conformance
from pybeamline.sinks.print_sink import print_sink
from pybeamline.sources import log_source
from pybeamline.algorithms.discovery.temporal_profile import temporal_profile_discovery_mapper
from pybeamline.stream.base_sink import BaseSink

class model_store(BaseSink):
	model = None
	def consume(self, item):
		self.model = item
sink = model_store()

# construction of the temporal profile
log_source(["ABC","ABC","DEF"]).pipe(
	temporal_profile_discovery_mapper()
).subscribe(sink)

# conformance with the constructed temporal profile
log_source(["ABC","ABC","DEF"]).pipe(
	temporal_profile_conformance(temporal_profile=sink.model)
).subscribe(print_sink())
```

Output:

```
{}
{}
{'case_1': [['case_1', 'A', 'C', 0.0, 10.772515040758183], ['case_1', 'B', 'C', 0.0, 19.209437368002256]]}
{'case_1': [['case_1', 'A', 'C', 0.0, 10.772515040758183], ['case_1', 'B', 'C', 0.0, 19.209437368002256]]}
{'case_1': [['case_1', 'A', 'C', 0.0, 10.772515040758183], ['case_1', 'B', 'C', 0.0, 19.209437368002256]]}
{'case_1': [['case_1', 'A', 'C', 0.0, 10.772515040758183], ['case_1', 'B', 'C', 0.0, 19.209437368002256]], 'case_2': [['case_2', 'A', 'C', 0.0, 10.772515040758183], ['case_2', 'B', 'C', 0.0, 19.209437368002256]]}
{'case_1': [['case_1', 'A', 'C', 0.0, 10.772515040758183], ['case_1', 'B', 'C', 0.0, 19.209437368002256]], 'case_2': [['case_2', 'A', 'C', 0.0, 10.772515040758183], ['case_2', 'B', 'C', 0.0, 19.209437368002256]]}
{'case_1': [['case_1', 'A', 'C', 0.0, 10.772515040758183], ['case_1', 'B', 'C', 0.0, 19.209437368002256]], 'case_2': [['case_2', 'A', 'C', 0.0, 10.772515040758183], ['case_2', 'B', 'C', 0.0, 19.209437368002256]], 'case_3': [['case_3', 'D', 'E', 0.0, 9223372036854775807]]}
{'case_1': [['case_1', 'A', 'C', 0.0, 10.772515040758183], ['case_1', 'B', 'C', 0.0, 19.209437368002256]], 'case_2': [['case_2', 'A', 'C', 0.0, 10.772515040758183], ['case_2', 'B', 'C', 0.0, 19.209437368002256]], 'case_3': [['case_3', 'D', 'E', 0.0, 9223372036854775807], ['case_3', 'D', 'F', 0.0, 9223372036854775807], ['case_3', 'E', 'F', 0.0, 9223372036854775807]]}
```

## References

The algorithm is describe in publications:

* [Temporal Conformance Checking at Runtime Based on Time-infused Process Models](https://arxiv.org/abs/2008.07262)  
  F. Stertz, J/ Mangler, and S. Rinderle-Ma  
  In *arXiv preprint arXiv:2008.07262* (2020).
