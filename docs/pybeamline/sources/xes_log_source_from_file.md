# xes_log_source_from_file

Emits all events from an XES event log.

## Parameters

* **log**: `str`  
  The file containing the log.


## Example

```python
from pybeamline.sources import xes_log_source_from_file
from pybeamline.sinks.print_sink import print_sink

xes_log_source_from_file("test.xes") \
    .subscribe(print_sink())
```
