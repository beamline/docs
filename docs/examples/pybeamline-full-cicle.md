In this example we are going to see how to use `pyBeamline` to go all the way from the simulation of an MQTT-XES stream to its mining and the visualization of the results as a Petri net that changes over time.

The picture below depicts the architecture of the example.

<figure>
<div class="mermaid">
classDiagram
  class Emitter
  class MQTTBroker
  class Miner
  class ResultsVisualizer

  MQTTBroker <-- Emitter
  MQTTBroker <--> Miner
  MQTTBroker --> ResultsVisualizer
</div>
</figure>

There is an MQTT Broker at the center. The `Emitter` is in charge of generating the events as MQTT-XES. The `Miner`, which is subscribed to the MQTT-XES, consumes the events and performs the discovery. It also publishes the models (as Graphviz DOR render of a Petri net) back into the MQTT broker. The `ResultVisualizer` is a static webpage that connects to the MQTT Broker and subscribes to the models which are rendered and presented as output.

## The `Emitter` component

<a target="_blank" href="https://colab.research.google.com/github/beamline/examples-pybeamline/blob/main/full-cycle-example/pybeamline_emitter.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>

Here is the complete code of the `Emitter`:

```python
import paho.mqtt.client as mqtt
import time

broker_host = "broker.emqx.io"
base_name = "pybeamline/source"
process_name = "test"

traces = []
traces.append(["A", "B", "C"])
traces.append(["A", "C", "B"])
traces.append(["A", "B", "C", "F", "D"])
traces.append(["A", "C", "B", "F", "E"])
traces.append(["A", "B", "C", "F", "E", "G", "I"])
traces.append(["A", "C", "B", "F", "D", "H", "I"])

c = mqtt.Client()
c.connect(broker_host, 1883, 60)

trace_id = 0
while True:
    for trace in traces:
        trace_id += 1
        for activity in trace:
            c.publish(base_name + "/" + process_name + "/C" + str(trace_id) + "/" + activity, "{}")
            time.sleep(0.5)

input()
```

The code defines different possible traces (referring to a process that contains a sequence, a parallel split/join and an XOR split/join) and continuously emits the corresponding event in a infinite loop. The `inpu()` at the very end ensures that the script does not terminate.


## The `Miner` component

<a target="_blank" href="https://colab.research.google.com/github/beamline/examples-pybeamline/blob/main/full-cycle-example/pybeamline_miner.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>

Here is the complete code of the `Emitter`:

```python
mqtt_source = {
    "broker": 'broker.emqx.io',
    "port": 1883,
    "topic": 'pybeamline/source'
}

mqtt_target = {
    "broker": 'broker.emqx.io',
    "port": 1883,
    "topic": 'pybeamline/output'
}

from pybeamline.sources import mqttxes_source
from pybeamline.algorithms.discovery import heuristics_miner_lossy_counting_budget
from pm4py.objects.conversion.heuristics_net import converter as conversion_factory
from pm4py.visualization.petri_net import visualizer as petri_net_visualizer
import paho.mqtt.client as mqtt


client = mqtt.Client()
client.connect(mqtt_target["broker"], mqtt_target["port"], 60)
client.loop_start()


def conversion_from_HN_to_Graphviz(heuristics_net):
  petri_net, initial_marking, final_marking = conversion_factory.apply(heuristics_net)
  gviz = petri_net_visualizer.apply(petri_net, initial_marking, final_marking)
  return str(gviz)


mqttxes_source(mqtt_source["broker"], mqtt_source["port"], mqtt_source["topic"]).pipe(
    heuristics_miner_lossy_counting_budget(model_update_frequency=4, budget=1000, dependency_threshold=0.75)
).subscribe(lambda x: client.publish(mqtt_target["topic"], conversion_from_HN_to_Graphviz(x)))

input()
```

## The `ResultVisualizer` component

A deployment of such component is available at <https://people.compute.dtu.dk/andbur/mqtt-graphviz/> and source code is available at <https://github.com/beamline/examples-pybeamline/blob/main/full-cycle-example/mqtt-graphviz-visualizer.html>. A screenshot of such page is below:

<figure markdown>
  ![](/img/resultsvisualizer.png)
</figure>

The complete code of this example is available in the GitHub repository <https://github.com/beamline/examples-pybeamline/tree/main/full-cycle-example>.


