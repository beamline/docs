# oc_operator

Configures and returns a reactive operator that enables real-time discovery of object-centric process models and activity-entity relationship (AER) diagrams from a stream of `BOEvent` events.


## Parameters

* **inclusion_strategy**: `InclusionStrategy` default: `None`  
  Determines when object types are considered active/inactive (e.g., based on relative frequency or lossy counting).

* **control_flow**: `Dict[str, Callable[[], StreamMiner]]` default: `None`  
  Predefined miners for each object type (static mode).

* **aer_model_update_frequency**: `int` default: `30`  
  Frequency (in #events) for emitting AER model updates.

* **aer_model_max_approx_error**: `Float` default: `0.01`  
  Maximum error tolerance for lossy counting in AER miner (lower = more accurate but higher memory).

* **default_miner**: `Callable[[], StreamMiner]` default: `None`  
  Miner to use in dynamic mode for unseen object types.
   


## Returned type

A callable that takes an `Observable[BOEvent]` as input and returns an `Observable[dict]` containing emitted models, AER diagrams, and control commands such as active/inactive.

## Example

```python
from pybeamline.algorithms.discovery import heuristics_miner_lossy_counting, heuristics_miner_lossy_counting_budget
from pybeamline.algorithms.oc.oc_operator import oc_operator
from pybeamline.sinks.print_sink import print_sink
from pybeamline.sources.dict_ocel_test_source import dict_test_ocel_source

trace_1 = [
    {"activity": "Register Customer", "objects": {"Customer": ["c1"]}},
    {"activity": "Create Order", "objects": {"Customer": ["c1"], "Order": ["o1"]}},
    {"activity": "Add Item", "objects": {"Order": ["o1"], "Item": ["i1"]}},
    {"activity": "Add Item", "objects": {"Order": ["o1"], "Item": ["i2"]}},
    {"activity": "Ship Order", "objects": {"Item": ["i1", "i2"], "Order": ["o1"]}}
]
trace_2 = [
    {"activity": "Register Guest", "objects": {"Guest": ["g1"]}},
    {"activity": "Create Booking", "objects": {"Guest": ["g1"], "Booking": ["b1"]}},
    {"activity": "Reserve Room", "objects": {"Booking": ["b1"]}},
    {"activity": "Check In", "objects": {"Guest": ["g1"], "Booking": ["b1"]}},
    {"activity": "Check Out", "objects": {"Guest": ["g1"], "Booking": ["b1"]}}
]

control_flow = {
    "Customer": lambda : heuristics_miner_lossy_counting(
        model_update_frequency=5,
        max_approx_error=0.2
    ),
    "Order": lambda : heuristics_miner_lossy_counting_budget( # Individual tuning for Order
        model_update_frequency=4,
    ),
    "Item": lambda : heuristics_miner_lossy_counting(
        model_update_frequency=4,
        max_approx_error=0.1
    )
}

test_source = dict_test_ocel_source([(trace_1, 2), (trace_2, 3)]).pipe(
    oc_operator(control_flow=control_flow),
).subscribe(print_sink())
```

Output:

```
{'type': 'command', 'command': <Command.ACTIVE: 'active'>, 'object_type': 'Item'}
{'type': 'dfg', 'object_type': 'Item', 'model': {'Add Item': (node:Add Item connections:{Ship Order:[0.5]}), 'Ship Order': (node:Ship Order connections:{})}}
{'type': 'command', 'command': <Command.ACTIVE: 'active'>, 'object_type': 'Order'}
{'type': 'dfg', 'object_type': 'Order', 'model': {'Create Order': (node:Create Order connections:{Add Item:[0.5]}), 'Add Item': (node:Add Item connections:{Add Item:[0.5], Ship Order:[0.5]}), 'Ship Order': (node:Ship Order connections:{})}}
{'type': 'command', 'command': <Command.ACTIVE: 'active'>, 'object_type': 'Customer'}
{'type': 'dfg', 'object_type': 'Customer', 'model': {'Register Customer': (node:Register Customer connections:{Create Order:[0.6666666666666666]}), 'Create Order': (node:Create Order connections:{})}}
{'type': 'dfg', 'object_type': 'Item', 'model': {'Add Item': (node:Add Item connections:{Ship Order:[0.75]}), 'Ship Order': (node:Ship Order connections:{})}}
{'type': 'dfg', 'object_type': 'Order', 'model': {'Create Order': (node:Create Order connections:{Add Item:[0.6666666666666666]}), 'Add Item': (node:Add Item connections:{Add Item:[0.6666666666666666], Ship Order:[0.6666666666666666]}), 'Ship Order': (node:Ship Order connections:{})}}
```

## References

The algorithm is described in publication:

* [Push your objects into streams! Streaming OCPM, Take 1](#)  
  J.M. Mikkelsen, A. Rivkin and A. Burattin  
  In *Proceedings of the Stream Management & Analytics for Process Mining ICPM Workshop* (SMA4PM 2025); Montevideo, Uruguay; October 20, 2025.