# dict_test_ocel_source

Loads an OCEL 2.0 log from a file path and returns it as a stream of `BOEvent`s.

## Parameters

* **flows**: `List[Tuple[List[dict], int]]`  
  A list of tuples, where each tuple is of the form `(flow_template, repetitions)` where `flow_template` is a list of event dictionaries with keys "`activity`" and "`objects`" and `repetitions` is the number of traces to generate from that template.  
  Example:
  ```
  [
    (
      [
        {"activity": "Register Customer", "objects": {"Customer": ["c1"]}},
        {"activity": "Create Order", "objects": {"Customer": ["c1"], "Order": ["o1"]}}
      ],
      20
    )
  ]
  ```
  This means: generate 20 traces with those two events.
* **shuffle**: `bool` default: `False`  
  Whether to shuffle the events from different traces in the final output.
* **scheduler**: `Optional[abc.SchedulerBase]` default: `None`  
  A ReactiveX scheduler to control event emission timing.


## Example

```python
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

test_source = dict_test_ocel_source(
    [
        (trace_1, 2),  # Repeat trace_1 twice
        (trace_2, 3)   # Repeat trace_2 three times
    ]
).subscribe(print_sink())
```

Output:

```
{'ocel:eid': 'e0', 'ocel:activity': 'Register Customer', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 490891), 'ocel:omap': {'Customer': {'c1_0'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e1', 'ocel:activity': 'Create Order', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Customer': {'c1_0'}, 'Order': {'o1_0'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e2', 'ocel:activity': 'Add Item', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Order': {'o1_0'}, 'Item': {'i1_0'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e3', 'ocel:activity': 'Add Item', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Order': {'o1_0'}, 'Item': {'i2_0'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e4', 'ocel:activity': 'Ship Order', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Item': {'i1_0', 'i2_0'}, 'Order': {'o1_0'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e5', 'ocel:activity': 'Register Customer', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Customer': {'c1_1'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e6', 'ocel:activity': 'Create Order', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Customer': {'c1_1'}, 'Order': {'o1_1'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e7', 'ocel:activity': 'Add Item', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Order': {'o1_1'}, 'Item': {'i1_1'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e8', 'ocel:activity': 'Add Item', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Order': {'o1_1'}, 'Item': {'i2_1'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e9', 'ocel:activity': 'Ship Order', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Item': {'i1_1', 'i2_1'}, 'Order': {'o1_1'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e10', 'ocel:activity': 'Register Guest', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Guest': {'g1_2'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e11', 'ocel:activity': 'Create Booking', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Guest': {'g1_2'}, 'Booking': {'b1_2'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e12', 'ocel:activity': 'Reserve Room', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Booking': {'b1_2'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e13', 'ocel:activity': 'Check In', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Guest': {'g1_2'}, 'Booking': {'b1_2'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e14', 'ocel:activity': 'Check Out', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Guest': {'g1_2'}, 'Booking': {'b1_2'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e15', 'ocel:activity': 'Register Guest', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Guest': {'g1_3'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e16', 'ocel:activity': 'Create Booking', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Guest': {'g1_3'}, 'Booking': {'b1_3'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e17', 'ocel:activity': 'Reserve Room', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Booking': {'b1_3'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e18', 'ocel:activity': 'Check In', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Guest': {'g1_3'}, 'Booking': {'b1_3'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e19', 'ocel:activity': 'Check Out', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Guest': {'g1_3'}, 'Booking': {'b1_3'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e20', 'ocel:activity': 'Register Guest', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Guest': {'g1_4'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e21', 'ocel:activity': 'Create Booking', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 491870), 'ocel:omap': {'Guest': {'g1_4'}, 'Booking': {'b1_4'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e22', 'ocel:activity': 'Reserve Room', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 493911), 'ocel:omap': {'Booking': {'b1_4'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e23', 'ocel:activity': 'Check In', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 493911), 'ocel:omap': {'Guest': {'g1_4'}, 'Booking': {'b1_4'}}, 'ocel:vmap': {}}
{'ocel:eid': 'e24', 'ocel:activity': 'Check Out', 'ocel:timestamp': datetime.datetime(2020, 0, 0, 9, 45, 19, 493911), 'ocel:omap': {'Guest': {'g1_4'}, 'Booking': {'b1_4'}}, 'ocel:vmap': {}}
```
