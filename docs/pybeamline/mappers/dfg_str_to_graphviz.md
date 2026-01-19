# dfg_str_to_graphviz

Converts a DFG into a Graphviz string.

## Parameters

* *None*


## Example

```python
from pybeamline.sources import log_source
from pybeamline.algorithms.discovery import simple_dfg_miner
from pybeamline.mappers.dfg_str_to_graphviz import dfg_str_to_graphviz
from pybeamline.sinks.print_sink import print_sink

log_source(["ABCD", "ABCD"]).pipe(
    simple_dfg_miner(model_update_frequency=8),
    dfg_str_to_graphviz()
).subscribe(print_sink())
```

Output:

```
digraph G {

    ranksep = 0.5
    fontsize = 9
    remincross = true
    margin = "0.0,0.0"
    outputorder = "edgesfirst"

    node[
        shape = box
        height = 0.23
        width = 1.2
        style = "rounded,filled"
        fontname = "Arial"
    ]
    edge[
        decorate = false
        fontsize = 8
        arrowsize = 0.5
        fontname = Arial
        tailclip = false
    ]
    
    start [
        shape = circle
        style = filled
        fillcolor = "#CED6BD"
        gradientangle = 270
        color = "#595F45"
        height = 0.13
        width = 0.13
        label = ""
    ]
    end [
        shape = circle
        style = filled
        fillcolor = "#D8BBB9"
        gradientangle = 270
        color = "#614847"
        height = 0.13
        width = 0.13
        label = ""
    ]
    "A" -> "B" [penwidth=5.0,label="1.0"];
    "B" -> "C" [penwidth=5.0,label="1.0"];
    "C" -> "D" [penwidth=5.0,label="1.0"];
    start -> "A" [penwidth = 2, style = dashed, color = "#ACB89C"];
    "D" -> end [penwidth = 2, style = dashed, color = "#C2B0AB"];
}
```
