# heuristics_miner_lossy_counting

An algorithm to mine a Heuristics Net using the Lossy Counting algorithm.


## Parameters

* **model_update_frequency**: `int` default: `10`  
  How often (in number of events) the model should be returned.

* **max_approx_error**: `Float` default: `0.001`
  The maximum approximation error in the Lossy Counting of the ferquencies.

* **dependency_threshold**: `Float` default: `0.5`  
  The Heuristics Miner's dependency threshold.

* **and_threshold**: `Float` default: `0.8`  
  The Heuristics Miner's AND threshold.


## Returned type

The returned output has type `pm4py.objects.heuristics_net.obj.HeuristicsNet`. See <https://processintelligence.solutions/pm4py/api?page=pm4py.objects.heuristics_net.html%23pm4py.objects.heuristics_net.obj.HeuristicsNet>.


## Example

```python
from pybeamline.sources import log_source
from pybeamline.algorithms.discovery.heuristics_miner_lossy_counting import heuristics_miner_lossy_counting
from pybeamline.sinks.print_sink import print_sink

log_source(["ABC","ABC","DEF"]).pipe(
	heuristics_miner_lossy_counting(model_update_frequency=4)
).subscribe(print_sink())
```

Output:

```
{'A': (node:A connections:{B:[0.5]}), 'B': (node:B connections:{C:[0.5]}), 'C': (node:C connections:{})}
{'A': (node:A connections:{B:[0.6666666666666666]}), 'B': (node:B connections:{C:[0.6666666666666666]}), 'C': (node:C connections:{})}
```

## References

The algorithm is describe in publications:

* [Control-flow Discovery from Event Streams](https://andrea.burattin.net/publications/2014-cec)  
  A. Burattin, A. Sperduti, W. M. P. van der Aalst  
  In *Proceedings of the Congress on Evolutionary Computation* (IEEE WCCI CEC 2014); Beijing, China; July 6-11, 2014.
* [Heuristics Miners for Streaming Event Data](https://andrea.burattin.net/publications/2012-corr-stream)  
  A. Burattin, A. Sperduti, W. M. P. van der Aalst  
  In *CoRR abs/1212.6383*, Dec. 2012.