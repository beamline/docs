# Combining sources

In order to build tests where drifts occur in a controlled setting, it is possible to concatenate different sources together. See the example below:
```python
from reactivex import concat
from pybeamline.sources import xes_log_source_from_file, log_source

src1 = xes_log_source_from_file("tests/log.xes")
src2 = log_source(["ABCD", "ABCD"])
src3 = xes_log_source_from_file("tests/log.xes")

concat = concat(src1, src2, src3)
concat \
    .subscribe(lambda x: print(str(x)))
```