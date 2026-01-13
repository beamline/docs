# xes_log_source_from_file

Emits all events from an XES event log.

## Parameters

* **log**: `str`  
  The file containing the log.


## Example

```python
import pm4py
from pybeamline.sources import xes_log_source_from_file

xes_log_source_from_file("test.xes") \
    .subscribe(lambda x: print(str(x)))
```
