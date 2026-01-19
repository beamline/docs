# simple_dfg_miner

An algorithm that simply constructs the DFG considering infinite amount of memory available.

## Parameters

* **model_update_frequency**: `int` default: `10`  
  How often (in number of events) the model should be returned.

* **min_relative_frequency**: `Float` default: `0.75`   
  Minimum relative frequency that a directly follow relations should have to be generated.

## Returned type

The returned output has type `Tuple[int, Dict]]`. The first component is the number of observed events, the second is a dictionary where the key is the directly follow relation, the value is the frequency of such relation.

## Example

```python
from pybeamline.sources import log_source
from pybeamline.sources import log_source
from pybeamline.algorithms.discovery.dfg_miner import simple_dfg_miner
from pybeamline.sinks.print_sink import print_sink

log_source(["ABC","ABC","DEF"]).pipe(
	simple_dfg_miner(model_update_frequency=3, min_relative_frequency=0.4)
).subscribe(print_sink())
```

Output:

```
(3, {('A', 'B'): 1.0, ('B', 'C'): 1.0})
(6, {('A', 'B'): 1.0, ('B', 'C'): 1.0})
(9, {('A', 'B'): 1.0, ('B', 'C'): 1.0, ('D', 'E'): 0.5, ('E', 'F'): 0.5})
```