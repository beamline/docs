# split_miner_sliding_window


The Split Miner operators discover a BPMN process model from a stream of `BEvent` objects. They emit a new model after each configured number of input events. This variant retains the most recent events up to a fixed capacity.

This algorithm uses DFG filtering and tha same BPMN discovery pipeline as the other Split Miner variants. The event's trace name identifies its case, and the event name is its activity.

## Parameters

* **model_update_frequency**: `int` default: `10`  
  Emit a BPMN model after every this many input events. The count is global across cases.

* **concurrency_threshold**:  `float` default: `0.4`  
  Threshold in `[0, 1]` for identifying concurrency between activities with directly-follows edges in both directions.

* **frequency_percentile**:  `float` default: `0.6`  
  Percentile in `[0, 1]` used to prune infrequent DFG edges. Best source-to-sink path edges are retained by the filtering step.

* **max_capacity**: `int` default: `100`  
  Maximum number of events in the window. When full, the oldest event is removed before the new event is added.


## Returned type

The return type is a `SlidingWindowSplitMiner`. The operator maps `BEvent` values to
[`pm4py.objects.bpmn.obj.BPMN`](https://pm4py-source.readthedocs.io/en/latest/pm4py.objects.bpmn.html#pm4py.objects.bpmn.obj.BPMN) objects. When applied to a stream, it emits one BPMN object at each `model_update_frequency` boundary.


## Example

```python
from pm4py.objects.bpmn.obj import BPMN

from pybeamline.algorithms.discovery import split_miner_sliding_window
from pybeamline.sources import log_source


def node_label(node):
    if isinstance(node, BPMN.StartEvent):
        return "Start"
    if isinstance(node, BPMN.EndEvent):
        return "End"
    if isinstance(node, BPMN.Task):
        return node.get_name()
    if isinstance(node, BPMN.ParallelGateway):
        return "AND({})".format(node.get_id())
    if isinstance(node, BPMN.ExclusiveGateway):
        return "XOR({})".format(node.get_id())
    if isinstance(node, BPMN.InclusiveGateway):
        return "OR({})".format(node.get_id())
    return type(node).__name__


def print_bpmn(model):
    print("Nodes:")
    for label in sorted(node_label(node) for node in model.get_nodes()):
        print(" - {}".format(label))
    print("Sequence flows:")
    flows = sorted(
        (node_label(flow.get_source()), node_label(flow.get_target()))
        for flow in model.get_flows()
    )
    for source, target in flows:
        print(" - {} -> {}".format(source, target))


log_source(["ABCD", "ACBD"]).pipe(
    split_miner_sliding_window(
        model_update_frequency=8,
        max_capacity=20,
        concurrency_threshold=0.5,
        frequency_percentile=0,
    )
).subscribe(on_next=print_bpmn)
```

Output:

```
Nodes:
 - A
 - AND(gateway_1)
 - AND(gateway_2)
 - B
 - C
 - D
 - End
 - Start
Sequence flows:
 - A -> AND(gateway_1)
 - AND(gateway_1) -> B
 - AND(gateway_1) -> C
 - AND(gateway_2) -> D
 - B -> AND(gateway_2)
 - C -> AND(gateway_2)
 - D -> End
 - Start -> A
```

## References

The techniques implemented in this package are described in:

- [Split Miner process discovery technique in streaming process mining environments](https://findit.dtu.dk/en/catalog/64bc6ffbb3ea963131d70caf)  
A. Jarmolkowicz  
Master Thesis, DTU, Jun. 2023.

The Split Miner algorithm is presented in:

- [Split miner: automated discovery of accurate and simple business process models from event logs](https://doi.org/10.1007/s10115-018-1214-x)  
Augusto, A., Conforti, R., Dumas, M. *et al.*   
In *Knowledge and Information Systems* 59, 251-284 (2019)
