# oc_visualizer_sink

Outputs the events from [`oc_merge`](../discovery/oc_merge.md) as a graph.

See also [`oc_merge`](../discovery/oc_merge.md) and [`oc_operator`](../discoveryoc_operator.md).

## Parameters

* **gif_path**: `str` default: `None`  
  The path where the gif of the stream should be stored. If `None` is specified, then the output is rendered on the notebook directly.
* **fps**: `int` default: `5`  
  The number of frame per seconds, in case the output is stored as a GIF.
* **mode**: `str` default `RGB`  
  The GIF color mode.
* **bg_color**: `tuple` default: `(255, 255, 255)`  
  The background color of the GIF.
* **center**: `boolean` default: `True`  
  Whether the content should be centered.
* **display_in_notebook**: `boolean` default: `True`  
  Whether the result should be shown on the notebook.


## Example

```python
from pybeamline.algorithms.oc.oc_merge_operator import oc_merge_operator
from pybeamline.algorithms.oc.oc_operator import oc_operator
from pybeamline.sinks.oc_visualizer_sink import oc_visualizer_sink
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
).subscribe(oc_visualizer_sink(gif_path='test_oc_visualizer_sink.gif', fps=1))
```

Output:

![](../img/test_oc_visualizer_sink.gif)