# RxOperator

Converts any [ReactiveX operator](https://ninmesara.github.io/RxPY/api/operators/index.html) into an operator that can be used in pyBeamline.

## Parameters

* **ops**: `Callable[[Any], Any]`  
  The ReactiveX operator to be converted.


## Example

```python
from pybeamline.sinks.print_sink import print_sink
from pybeamline.sources import log_source
from pybeamline.stream.rx_operator import RxOperator
from reactivex.operators import window_with_count

log_source(["ABC", "ABD"]).pipe(
    RxOperator(window_with_count(3))
).subscribe(print_sink())
```

Output:

```
[<pybeamline.bevent.BEvent object at 0x000001D77EAF0E80>, <pybeamline.bevent.BEvent object at 0x000001D77EAF0F10>, <pybeamline.bevent.BEvent object at 0x000001D77EAF0FA0>]
[<pybeamline.bevent.BEvent object at 0x000001D77EAE9790>, <pybeamline.bevent.BEvent object at 0x000001D77EAE9FA0>, <pybeamline.bevent.BEvent object at 0x000001D77EAF0E50>]
[]
```
