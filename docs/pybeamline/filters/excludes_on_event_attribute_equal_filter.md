# excludes_on_event_attribute_equal_filter

Excludes events based on the equality of an event attribute.

## Parameters

* **attribute_name**: `str`  
  Name of the event attribute to filter.

* **attribute_values**: `Iterable`   
  Values to look for in the attribute.


## Example

```python
from pybeamline.sources import log_source
from pybeamline.sinks.print_sink import print_sink
from pybeamline.filters import excludes_on_event_attribute_equal_filter

log_source("test.xes").pipe(
	excludes_on_event_attribute_equal_filter("event-attrib", ["ev", "ab"]),
).subscribe(print_sink())
```
