# retains_on_trace_attribute_equal_filter

Retains events based on the equality of a trace-level attribute.

## Parameters

* **attribute_name**: `str`  
  Name of the trace attribute to filter.

* **attribute_values**: `Iterable`   
  Values to look for in the attribute.


## Example

```python
from pybeamline.sources import log_source
from pybeamline.sinks.print_sink import print_sink
from pybeamline.filters import retains_on_trace_attribute_equal_filter

log_source("test.xes").pipe(
	retains_on_trace_attribute_equal_filter("event-attrib", ["ev", "ab"]),
).subscribe(print_sink())
```
