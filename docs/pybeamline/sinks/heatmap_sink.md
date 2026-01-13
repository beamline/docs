# heatmap_sink

Outputs the events as a heatmap graph. Each element of the stream to be presented should have the following shape: `((a, b), freq)`.

## Parameters

* **title**: `str` default: `Distribution`  
  The title of the heatmap.
* **value_label**: `str` default: `frequency`  
  The label of the value of the heatmap.
* **gif_path**: `str` default: `None`  
  The path where the gif of the stream should be stored. If `None` is specified, then the output is rendered on the notebook directly.
* **fps**: `int` default: `5`  
  The number of frame per seconds, in case the output is stored as a GIF.


## Example

```python
from pybeamline.sources import string_test_source
from pybeamline.mappers.to_directly_follow_relations import to_directly_follow_relations
from pybeamline.utils.skip_events import skip_events
from pybeamline.sinks.heatmap_sink import heatmap_sink

class count_latest(BaseMap):
	def __init__(self, window_size=5):
		self.observations = dict()
		self.window_size = window_size
		self.window = list()

	def transform(self, value):
		if value not in self.observations.keys():
			self.observations[value] = 0
		self.observations[value] += 1
		self.window.append(value)
		if len(self.window) > self.window_size:
			removed = self.window.pop(0)
			self.observations[removed] -= 1
			if self.observations[removed] == 0:
				del self.observations[removed]
		return [dict(self.observations)]

log_original = ["ABCD"]*50 + ["ACBD"]*50
log_after_drift = ["ABCE"]*100 + ["ACBF"]*100
string_test_source(log_original + log_after_drift).pipe(
  to_directly_follow_relations(),
	count_latest(window_size=200),
	skip_events(events_to_skip=20)
).sink(heatmap_sink(title="Directly-follows relation distribution", gif_path='test_heatmap_sink.gif', fps=3))
```

Output:

![](../img/test_heatmap_sink.gif)