# ocel2_log_source_from_file

Loads an OCEL 2.0 log from a file path and returns it as a stream of `BOEvent`s.

## Parameters

* **log_path**: `str`  
  The path of the OCEL 2.0 file.


## Example

```python
from pybeamline.sources.ocel2_log_source_from_file import ocel2_log_source_from_file
from pybeamline.sinks.print_sink import print_sink

ocel2_log_source_from_file("test.jsonocel") \
    .subscribe(print_sink())
```
