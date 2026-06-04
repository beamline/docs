# prefix_alignments_conformance

An implementation of the algorithm for incrementally compute prefix-alignments presented in <https://doi.org/10.1007/s41060-017-0078-6>.


## Parameters

* **reference_model**: `PetriNet`  
  The reference Petri net (`pm4py` implementation).
* **init_marking**: `Marking`  
  The initial marking for the reference Petri net (`pm4py` implementation).
* **final_marking**: `Marking`  
  The final marking for the reference Petri net (`pm4py` implementation).
* **revert_num**: `int` default: `None`  
  The number of backtracking steps. If `None` then it's infinite.
* **log_cost_fun**: `Dict` default: `None`  
  The cost of log moves. If `None` the standard cost function is assumed.
* **model_cost_fun**: `Dict` default: `None`  
  The cost of model moves. If `None` the standard cost function is assumed.

## Returned type

The returned output has a `pybeamline.algorithms.conformance.prefix_alignments.case_state.CaseState` object which contains the state of the prefix alignment and the current cost.


## Example

In this example we assume the reference model to be stored in `net`, `im` (initial marking), and `fn` (final marking). The code to construct the model is reported below.

We can define our prefix alignment using:
```python
from pybeamline.algorithms.conformance.prefix_alignments import prefix_alignments_conformance
from pybeamline.algorithms.lambda_operator import lambda_operator
from pybeamline.sinks.print_sink import print_sink
from pybeamline.sources import string_test_source

string_test_source(["xy","abcdZ"]).pipe(
	prefix_alignments_conformance(net, im, fm),
	lambda_operator(lambda d: {k: v.alignment[-1].cost for k, v in d.items()})
).subscribe(print_sink())
```

Output:

```
{'case_1': 1.0}
{'case_1': 2.0}
{'case_1': 2.0, 'case_2': 0.0}
{'case_1': 2.0, 'case_2': 0.0}
{'case_1': 2.0, 'case_2': 0.0}
{'case_1': 2.0, 'case_2': 0.0}
{'case_1': 2.0, 'case_2': 1.0}
```

It is also possible to print the incremental alignments

```python
from pybeamline.algorithms.conformance.prefix_alignments import prefix_alignments_conformance
from pybeamline.algorithms.lambda_operator import lambda_operator
from pybeamline.sinks.print_sink import print_sink
from pybeamline.sources import string_test_source

conformance_engine = prefix_alignments_conformance(net, im, fm)

string_test_source(["aZd"]).pipe(
	conformance_engine
).subscribe(on_next=lambda x: print(conformance_engine.get_trace_conformance("case_1").pretty_str()))
```

Output:

```
| a  |
|----|
| t1 |


| a  | Z  |
|----|----|
| t1 | >> |


| a  | Z  | >> | d  |
|----|----|----|----|
| t1 | >> | t3 | t4 |

```


This is the code for constructing the reference model:

```python
from pm4py import PetriNet
from pm4py.objects.bpmn.obj import Marking
from pm4py.objects.petri_net.utils import petri_utils

net = PetriNet("N1")

# Places
pi = PetriNet.Place("pi")
p1 = PetriNet.Place("p1")
p2 = PetriNet.Place("p2")
p3 = PetriNet.Place("p3")
p4 = PetriNet.Place("p4")
p5 = PetriNet.Place("p5")
po = PetriNet.Place("po")
for p in [pi, p1, p2, p3, p4, p5, po]:
	net.places.add(p)

# Transitions
t1 = PetriNet.Transition("t1", "a")
t2 = PetriNet.Transition("t2", "b")
t3 = PetriNet.Transition("t3", "c")
t4 = PetriNet.Transition("t4", "d")
t5 = PetriNet.Transition("t5", "d")
t6 = PetriNet.Transition("t6", None)    # invisible (τ)
t7 = PetriNet.Transition("t7", "e")
t8 = PetriNet.Transition("t8", "f")
for t in [t1, t2, t3, t4, t5, t6, t7, t8]:
	net.transitions.add(t)

# Arcs  (place -> transition and transition -> place)
# t1: pi -> t1 -> p1, p2
petri_utils.add_arc_from_to(pi, t1, net)
petri_utils.add_arc_from_to(t1, p1, net)
petri_utils.add_arc_from_to(t1, p2, net)

# t2: p1 -> t2 -> p3
petri_utils.add_arc_from_to(p1, t2, net)
petri_utils.add_arc_from_to(t2, p3, net)

# t3: p2 -> t3 -> p4
petri_utils.add_arc_from_to(p2, t3, net)
petri_utils.add_arc_from_to(t3, p4, net)

# t4: p1, p4 -> t4 -> p5
petri_utils.add_arc_from_to(p1, t4, net)
petri_utils.add_arc_from_to(p4, t4, net)
petri_utils.add_arc_from_to(t4, p5, net)

# t5: p3, p4 -> t5 -> p5
petri_utils.add_arc_from_to(p3, t5, net)
petri_utils.add_arc_from_to(p4, t5, net)
petri_utils.add_arc_from_to(t5, p5, net)

# t6 (τ): p5 -> t6 -> p1, p2
petri_utils.add_arc_from_to(p5, t6, net)
petri_utils.add_arc_from_to(t6, p1, net)
petri_utils.add_arc_from_to(t6, p2, net)

# t7: p5 -> t7 -> po
petri_utils.add_arc_from_to(p5, t7, net)
petri_utils.add_arc_from_to(t7, po, net)

# t8: p5 -> t8 -> po
petri_utils.add_arc_from_to(p5, t8, net)
petri_utils.add_arc_from_to(t8, po, net)

# Markings
im = Marking()
im[pi] = 1
fm = Marking()
fm[po] = 1
```
It is of course possible to alternatively import a Petri net from a PNML file:

```python
import pm4py

net, im, fm = pm4py.read_pnml("petri.pnml")
```

## References

The algorithm is described in:

* [Online conformance checking: relating event streams to process models using prefix-alignments](https://doi.org/10.1007/s41060-017-0078-6)  
  S.J. van Zelst, A. Bolt, M. Hassani, B.F. van Dongen, W.M.P. van der Aalst 
  In *International Journal of Data Science and Analytics* 8, 269–284 (2019).
