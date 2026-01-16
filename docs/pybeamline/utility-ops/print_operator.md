# print_operator

Allows the print the results during the computation. This is useful for debugging pipelines.

## Parameters

* **format_string**: `str` default: `None`  
  String format.


## Example

```python
from pybeamline.sources import log_source
from pybeamline.mappers.print_operator import print_operator
from pybeamline.sinks.print_sink import print_sink

log_source(["ABC", "ABD"]).pipe(
    print_operator("DEBUG> {0}"),
    skip_events(3)
).subscribe(print_sink())
```

Output:

```
DEBUG> (A, case_1, Process, 2020-00-00 17:00:57.197822 - {} - {} - {})
DEBUG> (B, case_1, Process, 2020-00-00 17:00:57.197822 - {} - {} - {})
DEBUG> (C, case_1, Process, 2020-00-00 17:00:57.197822 - {} - {} - {})
(C, case_1, Process, 2020-00-00 17:00:57.197822 - {} - {} - {})
DEBUG> (A, case_2, Process, 2020-00-00 17:00:57.197822 - {} - {} - {})
DEBUG> (B, case_2, Process, 2020-00-00 17:00:57.197822 - {} - {} - {})
DEBUG> (D, case_2, Process, 2020-00-00 17:00:57.197822 - {} - {} - {})
(D, case_2, Process, 2020-00-00 17:00:57.197822 - {} - {} - {})
```
