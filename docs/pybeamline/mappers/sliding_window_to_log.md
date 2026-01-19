# sliding_window_to_log

Converts a list of events into a `DataFrame` suitable to be mined using PM4PY.

## Parameters

* *None*


## Example

```python
from pybeamline.sinks.print_sink import print_sink
from pybeamline.sources import log_source
from pybeamline.mappers import sliding_window_to_log
from pybeamline.stream.base_map import BaseMap
from pybeamline.stream.rx_operator import RxOperator
from reactivex.operators import window_with_count
import pm4py

# class to run the offline mining algorithm
class mine_using_offline_pm4py(BaseMap):
    def transform(self, log):
        try:
            return [pm4py.discover_dfg_typed(log)]
        except:
            return None

log_source(["ABC", "ABD"]).pipe(
    RxOperator(window_with_count(3)),
    sliding_window_to_log(),
    mine_using_offline_pm4py()
).subscribe(print_sink())


```

Output:

```
Counter({('A', 'B'): 1, ('B', 'C'): 1})
Counter({('A', 'B'): 1, ('B', 'D'): 1})
```

As can be seen the 2 DFGs are mined from the 2 traces separately (as the tumbling window has size 3, which corresponds to the size of each trace). Using a tumbling window of size 6 (i.e., `window_with_count(6)`) will produce the following:

```
Counter({('A', 'B'): 2, ('B', 'C'): 1, ('B', 'D'): 1})
```

In this case, the only model extracted embeds both traces inside.
