# Combining sources

In order to build tests where drifts occur in a controlled setting, it is possible to concatenate or merge different sources together. See the example below:

```python
from pybeamline.sources import xes_log_source_from_file, log_source
from pybeamline.sinks.print_sink import print_sink

src1 = xes_log_source_from_file("tests/log.xes")
src2 = log_source(["ABCD", "ABCD"])
src3 = xes_log_source_from_file("tests/log.xes")

concat = src1.concat(src2).concat(src3)
concat.subscribe(print_sink())
```

The operator `concats` appends one stream to the other.

```python
from pybeamline.sources import xes_log_source_from_file, log_source
from pybeamline.sinks.print_sink import print_sink

src1 = xes_log_source_from_file("tests/log.xes")
src2 = log_source(["ABCD", "ABCD"])
src3 = xes_log_source_from_file("tests/log.xes")

merged = src1.merge(src2).merge(src3)
merged.subscribe(print_sink())
```

The operator `merge` combines the sources, and it may interleaves events.
