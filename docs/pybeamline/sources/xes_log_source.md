# xes_log_source

Emits all events from an XES event log.

## Parameters

* **raw_log**: `Union[EventLog, pd.DataFrame]`  
  The raw event log from PM4PY.


## Example

```python
import pm4py
from pybeamline.sources import xes_log_source

xes_log_source(pm4py.read_xes("test.xes")) \
    .subscribe(lambda x: print(str(x)))
```
