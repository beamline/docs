# oc_merge

Operator that sits downstream of the [`oc_operator`](oc_operator.md) in the streaming pipeline. It merges the output from multiple miners -- per-object-type control-flow models (DFGs), activity-object relations (AERs), and inclusion commands -- into a synchronized and semantically coherent object-centric process model.

See also [`oc_operator`](oc_operator.md) and [`oc_visualizer_sink`](../sinks/oc_visualizer_sink.md).


## Parameters

* *None*


## Returned type

A stream of synchronized models in the following format:

```python
{
  "ocdfg": OCDFG(...),
  "aer": AER(...)
}
```

These models represent a current snapshot of the object-centric behavior in the system, respecting only the *currently active* object types.


## Example

```python
from pybeamline.algorithms.oc.oc_merge_operator import oc_merge_operator
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

test_source = dict_test_ocel_source([(trace_1, 10)]).pipe(
    oc_operator(),
    oc_merge_operator(),
).subscribe(print_sink())
```

Output:

```
{'ocdfg': OCDFG(activities=['Add Item', 'Create Order', 'Ship Order'], object_types=['Order'], edges={'Order': {('Add Item', 'Ship Order'): 4, ('Create Order', 'Add Item'): 5, ('Add Item', 'Add Item'): 5}}, start_activities={'Order': {'Create Order'}}, end_activities={'Order': {'Ship Order'}}), 'aer': ActivityER(activities=[], object_types={}, relations={})}
{'ocdfg': OCDFG(activities=['Add Item', 'Create Order', 'Ship Order'], object_types=['Item', 'Order'], edges={'Order': {('Add Item', 'Ship Order'): 4, ('Create Order', 'Add Item'): 5, ('Add Item', 'Add Item'): 5}, 'Item': {('Add Item', 'Ship Order'): 9}}, start_activities={'Order': {'Create Order'}, 'Item': {'Add Item'}}, end_activities={'Order': {'Ship Order'}, 'Item': {'Ship Order'}}), 'aer': ActivityER(activities=[], object_types={}, relations={})}
{'ocdfg': OCDFG(activities=['Add Item', 'Create Order', 'Ship Order'], object_types=['Item', 'Order'], edges={'Order': {('Add Item', 'Ship Order'): 4, ('Create Order', 'Add Item'): 5, ('Add Item', 'Add Item'): 5}, 'Item': {('Add Item', 'Ship Order'): 9}}, start_activities={'Order': {'Create Order'}, 'Item': {'Add Item'}}, end_activities={'Order': {'Ship Order'}, 'Item': {'Ship Order'}}), 'aer': ActivityER(activities=['Add Item', 'Create Order', 'Ship Order'], object_types={'Create Order': {'Order'}, 'Add Item': {'Item', 'Order'}, 'Ship Order': {'Item', 'Order'}}, relations={'Add Item': {('Item', 'Order'): <Cardinality.ONE_TO_ONE: '1..1'>}, 'Ship Order': {('Item', 'Order'): <Cardinality.MANY_TO_ONE: 'N..1'>}})}
{'ocdfg': OCDFG(activities=['Add Item', 'Create Order', 'Ship Order'], object_types=['Item', 'Order'], edges={'Order': {('Add Item', 'Ship Order'): 4, ('Create Order', 'Add Item'): 5, ('Add Item', 'Add Item'): 5}, 'Item': {('Add Item', 'Ship Order'): 9}}, start_activities={'Order': {'Create Order'}, 'Item': {'Add Item'}}, end_activities={'Order': {'Ship Order'}, 'Item': {'Ship Order'}}), 'aer': ActivityER(activities=['Add Item', 'Create Order', 'Ship Order'], object_types={'Create Order': {'Order'}, 'Add Item': {'Item', 'Order'}, 'Ship Order': {'Item', 'Order'}}, relations={'Add Item': {('Item', 'Order'): <Cardinality.ONE_TO_ONE: '1..1'>}, 'Ship Order': {('Item', 'Order'): <Cardinality.MANY_TO_ONE: 'N..1'>}})}
{'ocdfg': OCDFG(activities=['Add Item', 'Create Order', 'Ship Order'], object_types=['Item', 'Order'], edges={'Order': {('Add Item', 'Ship Order'): 4, ('Create Order', 'Add Item'): 5, ('Add Item', 'Add Item'): 5}, 'Item': {('Add Item', 'Ship Order'): 9}}, start_activities={'Order': {'Create Order'}, 'Item': {'Add Item'}}, end_activities={'Order': {'Ship Order'}, 'Item': {'Ship Order'}}), 'aer': ActivityER(activities=['Add Item', 'Create Order', 'Ship Order'], object_types={'Create Order': {'Order'}, 'Add Item': {'Item', 'Order'}, 'Ship Order': {'Item', 'Order'}}, relations={'Add Item': {('Item', 'Order'): <Cardinality.ONE_TO_ONE: '1..1'>}, 'Ship Order': {('Item', 'Order'): <Cardinality.MANY_TO_ONE: 'N..1'>}})}
{'ocdfg': OCDFG(activities=['Add Item', 'Create Order', 'Register Customer', 'Ship Order'], object_types=['Customer', 'Item', 'Order'], edges={'Order': {('Add Item', 'Ship Order'): 4, ('Create Order', 'Add Item'): 5, ('Add Item', 'Add Item'): 5}, 'Item': {('Add Item', 'Ship Order'): 9}, 'Customer': {('Register Customer', 'Create Order'): 9}}, start_activities={'Order': {'Create Order'}, 'Item': {'Add Item'}, 'Customer': {'Register Customer'}}, end_activities={'Order': {'Ship Order'}, 'Item': {'Ship Order'}, 'Customer': {'Create Order'}}), 'aer': ActivityER(activities=['Add Item', 'Create Order', 'Register Customer', 'Ship Order'], object_types={'Register Customer': {'Customer'}, 'Create Order': {'Customer', 'Order'}, 'Add Item': {'Item', 'Order'}, 'Ship Order': {'Item', 'Order'}}, relations={'Create Order': {('Customer', 'Order'): <Cardinality.ONE_TO_ONE: '1..1'>}, 'Add Item': {('Item', 'Order'): <Cardinality.ONE_TO_ONE: '1..1'>}, 'Ship Order': {('Item', 'Order'): <Cardinality.MANY_TO_ONE: 'N..1'>}})}
{'ocdfg': OCDFG(activities=['Add Item', 'Create Order', 'Register Customer', 'Ship Order'], object_types=['Customer', 'Item', 'Order'], edges={'Order': {('Add Item', 'Ship Order'): 9, ('Create Order', 'Add Item'): 10, ('Add Item', 'Add Item'): 10}, 'Item': {('Add Item', 'Ship Order'): 9}, 'Customer': {('Register Customer', 'Create Order'): 9}}, start_activities={'Order': {'Create Order'}, 'Item': {'Add Item'}, 'Customer': {'Register Customer'}}, end_activities={'Order': {'Ship Order'}, 'Item': {'Ship Order'}, 'Customer': {'Create Order'}}), 'aer': ActivityER(activities=['Add Item', 'Create Order', 'Register Customer', 'Ship Order'], object_types={'Register Customer': {'Customer'}, 'Create Order': {'Customer', 'Order'}, 'Add Item': {'Item', 'Order'}, 'Ship Order': {'Item', 'Order'}}, relations={'Create Order': {('Customer', 'Order'): <Cardinality.ONE_TO_ONE: '1..1'>}, 'Add Item': {('Item', 'Order'): <Cardinality.ONE_TO_ONE: '1..1'>}, 'Ship Order': {('Item', 'Order'): <Cardinality.MANY_TO_ONE: 'N..1'>}})}
{'ocdfg': OCDFG(activities=['Add Item', 'Create Order', 'Register Customer', 'Ship Order'], object_types=['Customer', 'Item', 'Order'], edges={'Order': {('Add Item', 'Ship Order'): 9, ('Create Order', 'Add Item'): 10, ('Add Item', 'Add Item'): 10}, 'Item': {('Add Item', 'Ship Order'): 19}, 'Customer': {('Register Customer', 'Create Order'): 9}}, start_activities={'Order': {'Create Order'}, 'Item': {'Add Item'}, 'Customer': {'Register Customer'}}, end_activities={'Order': {'Ship Order'}, 'Item': {'Ship Order'}, 'Customer': {'Create Order'}}), 'aer': ActivityER(activities=['Add Item', 'Create Order', 'Register Customer', 'Ship Order'], object_types={'Register Customer': {'Customer'}, 'Create Order': {'Customer', 'Order'}, 'Add Item': {'Item', 'Order'}, 'Ship Order': {'Item', 'Order'}}, relations={'Create Order': {('Customer', 'Order'): <Cardinality.ONE_TO_ONE: '1..1'>}, 'Add Item': {('Item', 'Order'): <Cardinality.ONE_TO_ONE: '1..1'>}, 'Ship Order': {('Item', 'Order'): <Cardinality.MANY_TO_ONE: 'N..1'>}})}
```

## References

The algorithm is described in publication:

* [Push your objects into streams! Streaming OCPM, Take 1](#)  
  J.M. Mikkelsen, A. Rivkin and A. Burattin  
  In *Proceedings of the Stream Management & Analytics for Process Mining ICPM Workshop* (SMA4PM 2025); Montevideo, Uruguay; October 20, 2025.