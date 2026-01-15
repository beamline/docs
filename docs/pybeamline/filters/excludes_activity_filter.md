# excludes_activity_filter

Excludes activities base on their name (`concept:name`).

## Parameters

* **activity_names**: `Iterable[str]`  
  Activity names to filter.


## Example

```python
from pybeamline.sources import log_source
from pybeamline.sinks.print_sink import print_sink
from pybeamline.filters import excludes_activity_filter

log_source(["ABC", "ACB", "EFG"]).pipe(
    excludes_activity_filter("A"),
).subscribe(print_sink())
```
