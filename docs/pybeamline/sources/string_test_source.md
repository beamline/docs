# string_test_source

Source that considers each trace as a string provided in the constructor and each event as one character of the string.

## Parameters

* **raw_log**: `Iterable[str]`  
  The collection of traces to be streamed. Each `str` represents a complete trace, where each character is an activity.


## Example

```python
from pybeamline.sources import string_test_source
from pybeamline.sinks.print_sink import print_sink

string_test_source(["ABC", "ACB", "EFG"]) \
    .subscribe(print_sink())
```
