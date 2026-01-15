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

TBA
