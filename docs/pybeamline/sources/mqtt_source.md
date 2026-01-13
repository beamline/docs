# mqttxes_source

Source that connects to an MQTT endpoint and expects events to be published according to the [MQTT-XES format](../../jbeamline/mqtt-xes.md).

## Parameters

* **broker**: `str`  
  The url of the MQTT broker.
* **port**: `int`  
  The port of the MQTT broker.
* **base_topic**: `str`  
  The base topic for the MQTT-XES source


## Example

```python
from pybeamline.sources import mqttxes_source

mqttxes_source('broker.mqtt.cool', 1883, 'base/topic/') \
    .subscribe(lambda x: print(str(x)))

input()
```

Where `broker.mqtt.cool` is the URL of the MQTT broker, `1883` is the broker port, and `base/topic/` is the base topic. Please note the `input()` at the end, which is necessary to avoid that the application terminates thus not receiving any more events.
