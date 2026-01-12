# Integration with Other Libraries

## River

River (<https://riverml.xyz/>) is a library to build online machine learning models. Such models operate on data streams. River includes several online machine learning algorithms that can be used for several tasks, including classification, regression, anomaly detection, time series forecasting, etc. The ideology behind River is to be a generic machine learning which allows to perform these tasks in a streaming manner. Indeed, many batch machine learning algorithms have online equivalents. Note that River also supports some more basic tasks. For instance, you might just want to calculate a running average of a data stream.

It is possible to integrate pyBeamline's result into River to leverage its ML capabilities. For example, let's say we want to use concept drift detection using the [ADWIN algorithm](https://riverml.xyz/0.11.0/api/drift/ADWIN/). In particular, we are interested in computing if the frequency of the directly follows relation `BC` changes over time. To accomplish this task, let's first build a log where we artificially inject two of such drifts:

```python
import random

log_original = ["ABCD"]*10000 + ["ACBD"]*500
random.shuffle(log_original)

log_after_drift = ["ABCD"]*500 + ["ACBD"]*10000
random.shuffle(log_after_drift)

log_with_drift = log_source(log_original + log_after_drift + log_original)
```
In this case, we built two logs (`log_original` and `log_after_drift`) which include the same process variants but that differ in the number of occurrences. Finally, we construct our pyBeamline log source `log_with_drift` by concatenating `log_original + log_after_drift + log_original`.

After that we can use the capabilities of pyBeamline and reactivex to construct a pipeline that produce a sequence of frequencies corresponding to the frequency of directly follows relation `BC` in window with length 40 (which is chosen as all our traces have length 4). Also note that we leverage the fact that in all our events when `B` and `C` appear they are always in the same trace (because of how `log_source` generates the observable). We will later define a function `check_for_drift`:

```python
import reactivex
from reactivex import operators as ops

log_with_drift.pipe(
  ops.buffer_with_count(40),
  ops.flat_map(lambda events: reactivex.from_iterable(events).pipe(
      ops.pairwise(),
      ops.filter(lambda x: x[0].get_trace_name() == x[1].get_trace_name() and x[0].get_event_name() == "B" and x[1].get_event_name() == "C"),
      ops.count()
      )
  )
).subscribe(lambda x: print(x))
```
After this we can define our function for drift detection and collection of points and drift indexes using:
```python
from reactivex import operators as ops
from river import drift

drift_detector = drift.ADWIN()
data = []
drifts = []

def check_for_drift():
  index = 0

  def _process(x):
    nonlocal index
    drift_detector.update(x)
    index = index + 1
    if drift_detector.drift_detected:
      drifts.append(index)

  def _check_for_drift(obs):
    return obs.pipe(ops.do_action(lambda value: _process(value)))

  return _check_for_drift
```
With this function available, `check_for_drift` can now be piped to the previous computation. Plotting the frequencies and the concept drifts will result in the following:

![](https://github.com/beamline/docs/blob/main/site/img/drifts.png?raw=true)

For a complete working example, see <https://github.com/beamline/pybeamline/blob/master/tutorial.ipynb>.
