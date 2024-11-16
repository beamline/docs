In this example we are going to see how to use `pyBeamline` to go all the way from the simulation of an MQTT-XES stream to its mining and the visualization of the results as a Petri net that changes over time.

The picture below depicts the architecture of the example.

<figure>
<div class="mermaid">
classDiagram
  class Emitter
  class `MQTT Broker`
  class Miner
  class `Results Visualizer`

  `MQTT Broker` <-- Emitter : publishes events
  `MQTT Broker` --> Miner : notifies events
  `MQTT Broker` <-- Miner : publishes models
  `MQTT Broker` --> `Results Visualizer` : notifies models
</div>
</figure>

There is an MQTT Broker at the center. The `Emitter` is in charge of generating the events as MQTT-XES. The `Miner`, which is subscribed to the MQTT-XES, consumes the events and performs the discovery. It also publishes the models (as Graphviz DOR render of a Petri net) back into the MQTT broker. The `ResultVisualizer` is a static webpage that connects to the MQTT Broker and subscribes to the models which are rendered and presented as output.

All these components can be tested without the need to install anything: it is possible to use a public MQTT broker, the `Emitter` and the `Miner` can be hosted on Google Colab (see links below in each section), and a deployment of `ResultVisualizer` is also available (see link below).

## The `Emitter` component

<a target="_blank" href="https://colab.research.google.com/github/beamline/examples-pybeamline/blob/main/full-cycle-example/pybeamline_emitter.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>

The `Emitter` first defines the destination of the MQTT messages, after that a list of all possible traces (referring to a process that contains a sequence, a parallel split/join and an XOR split/join) is reported and finally the system connects to the MQTT broker and starts an infinite loop that publishes one event after the other according to the MQTT-XES specification.

Here is the complete code of the `Emitter`:

```python linenums="1"
import paho.mqtt.client as mqtt
import time

mqtt_source = {
    "broker": 'broker.emqx.io',
    "port": 1883,
    "topic": 'pybeamline/source'
}

traces = []
traces.append(["A", "B", "C"])
traces.append(["A", "C", "B"])
traces.append(["A", "B", "C", "F", "D"])
traces.append(["A", "C", "B", "F", "E"])
traces.append(["A", "B", "C", "F", "E", "G", "I"])
traces.append(["A", "C", "B", "F", "D", "H", "I"])

c = mqtt.Client()
c.connect(mqtt_source["broker"], mqtt_source["port"], 60)

process_name = "test"
trace_id = 0
while True:
    for trace in traces:
        trace_id += 1
        for activity in trace:
            c.publish(mqtt_source["topic"] + "/" + process_name + "/C" + str(trace_id) + "/" + activity, "{}")
            time.sleep(0.5)
            

```

Currently, between each event, the scripts waits for 0.5 seconds.

Please note that this code is not terminating on purpose: the goal is that events are continuously generated and the generation stops when the script is forced to terminate.


## The `Miner` component

<a target="_blank" href="https://colab.research.google.com/github/beamline/examples-pybeamline/blob/main/full-cycle-example/pybeamline_miner.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>

In order to configure the `Miner` component it is necessary to specify the two MQTT endpoints referring to where the event messages are sent and where the model updates should be published.

```python linenums="1"
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
```

The script ensures a connection to the MQTT endpoint, then it defines a function to transform the Heuristics Net (produced by `heuristics_miner_lossy_counting_budget` into the Graphviz DOT representation of the translated Petri net) leveraging the PM4PY functions. At the very end, the `pyBeamline` pipeline is defined: it connects to the `mqttxes_source` and defines a pipeline that only contains `heuristics_miner_lossy_counting_budget`. The results are then processes in a `lambda` function that converts it to Petri net and publishes them to the MQTT broker.

Here is the complete code of the `Miner`:

```python linenums="12"
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

Please note that the `input()` at the very end ensures that the script does not terminate.


## The `Result Visualizer` component

This component is just a static HTML page that connects to the MQTT broker (via web sockets, which must be enabled on the MQTT broker) and subscribes to messages on a certain topics. The payload of the message is assumed to be a Graphviz DOT string (as produced by the `Miner`) and is then converted into and SVG picture which is displayed and updated with each message.

A deployment of such component is available at <https://people.compute.dtu.dk/andbur/mqtt-graphviz/> and source code is available at <https://github.com/beamline/examples-pybeamline/blob/main/full-cycle-example/mqtt-graphviz-visualizer.html>. A screenshot of such page is below:

<figure markdown>
  ![](/img/resultsvisualizer.png)
</figure>

The complete code of this example is available in the GitHub repository <https://github.com/beamline/examples-pybeamline/tree/main/full-cycle-example>.


