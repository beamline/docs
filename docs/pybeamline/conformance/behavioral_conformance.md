# behavioral_conformance

An algorithm to compute the conformance using behavioral patterns.


## Parameters

* **model**: `tuple`  
  The reference behavioral model.


## Returned type

The returned output has type `(float, float, float, int)` with: conformance, confidence, completeness, and number of observed events.


## Example

In this example, the reference model is extracted by a (finite) stream:

```python
from pybeamline.algorithms.conformance import mine_behavioral_model_from_stream, behavioral_conformance
from pybeamline.sinks.print_sink import print_sink
from pybeamline.sources import log_source

source = log_source(["ABCD", "ABCD"])
reference_model = mine_behavioral_model_from_stream(source)

log_source(["ABCD", "ABEFG"]).pipe(
    behavioral_conformance(reference_model)
).subscribe(print_sink())
```

Output:

```
(1.0, 0.0, 1, 2)
(1.0, 0.5, 1, 3)
(1.0, 1.0, 1, 4)
(1.0, 0.0, 1, 6)
(0.5, -1, -1, 7)
(0.3333333333333333, -1, -1, 8)
(0.25, -1, -1, 9)
```

The reference model can also be obtained converting a Petri net (from PM4PY) into a behavioral model:

```python
from pm4py.objects.petri_net.obj import PetriNet, Marking
from pm4py.objects.petri_net.utils.petri_utils import add_arc_from_to

from pybeamline.algorithms.conformance import behavioral_conformance
from pybeamline.algorithms.conformance.behavioral.behavioral_conformance import petri_net_2_behavioral_model
from pybeamline.sinks.print_sink import print_sink
from pybeamline.sources import log_source

# code definition of the petri net. it is also possible to import it
p0 = PetriNet.Place("p0")
p1 = PetriNet.Place("p1")
p2 = PetriNet.Place("p2")
p3 = PetriNet.Place("p3")
p4 = PetriNet.Place("p4")
tA = PetriNet.Transition("tA", "A")
tB = PetriNet.Transition("tB", "B")
tC = PetriNet.Transition("tC", "C")
tD = PetriNet.Transition("tD", "D")
net = PetriNet("seq_net")
net.places.update({p0, p1, p2, p3, p4})
net.transitions.update({tA, tB, tC, tD})
add_arc_from_to(p0, tA, net)
add_arc_from_to(tA, p1, net)
add_arc_from_to(p1, tB, net)
add_arc_from_to(tB, p2, net)
add_arc_from_to(p2, tC, net)
add_arc_from_to(tC, p3, net)
add_arc_from_to(p3, tD, net)
add_arc_from_to(tD, p4, net)
im = Marking({p0: 1})
fm = Marking({p4: 0})

# conversion of the reference petri net into behavioral model
reference_model = petri_net_2_behavioral_model(net, im, fm)

log_source(["ABCD", "ABEFG"]).pipe(
    behavioral_conformance(reference_model)
).subscribe(print_sink())
```

Output:

```
(1.0, 0.0, 1, 2)
(1.0, 0.5, 1, 3)
(1.0, 1.0, 1, 4)
(1.0, 0.0, 1, 6)
(0.5, -1, -1, 7)
(0.3333333333333333, -1, -1, 8)
(0.25, -1, -1, 9)
```

## References

The algorithm is describe in:

* [Online Conformance Checking Using Behavioural Patterns](https://andrea.burattin.net/publications/2018-bpm)  
  A. Burattin, S. van Zelst, A. Armas-Cervantes, B. van Dongen, J. Carmona  
  In *Proceedings of BPM 2018*; Sydney, Australia; September 2018.
