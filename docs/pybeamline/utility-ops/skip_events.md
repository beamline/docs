# skip_events

Lets the pipeline skips the provided number of events.

## Parameters

* **events_to_skip**: `int`  
  The number of events to skip before continuing the flow.


## Example

```python
from pybeamline.sources import log_source
from pybeamline.utils.skip_events import skip_events
from pybeamline.sinks.print_sink import print_sink

log_source(["ABC", "DEF"]).pipe(
    skip_events(2)
).subscribe(print_sink())
```

Output:

```
(B, case_1, Process, 2020-00-00 16:33:26.790591 - {} - {} - {})
(D, case_2, Process, 2020-00-00 16:33:26.791592 - {} - {} - {})
(F, case_2, Process, 2020-00-00 16:33:26.791592 - {} - {} - {})
```
