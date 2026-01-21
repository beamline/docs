# ais_source

???+ warning "Extra package required!"
	To use this source you need to install package `pybeamline-real-sources` with:
	```
	pip install pybeamline-real-sources
	```

The automatic identification system (AIS) is an automatic tracking system that uses transceivers on ships and is used by vessel traffic services. This source considers the [MMSI](https://en.wikipedia.org/wiki/Maritime_Mobile_Service_Identity) as the case id and the [navigation status (when available) as the activity](https://en.wikipedia.org/wiki/Automatic_identification_system#Broadcast_information). While it is possible connect to any AIS data provider (by passing `host` and `port` parameters), by default, the source connects to the Norwegian Coastal Administration server, which publishes data for the from vessels within the Norwegian economic zone and the protection zones off Svalbard and Jan Mayen (see <https://www.kystverket.no/en/navigation-and-monitoring/ais/access-to-ais-data/>).

**ATTENTION:** while a lot of events are produced by this source, traces are very short and it can take a long time before two events with the same case id are actually observed.


## Parameters

* **host** `str` default: `'153.44.253.27'`  
  IP Address of the AIS provider.

* **port** `int` default: `5631`   
  Port of the AIS provider.


## Example

```python
from pybeamline.sinks.print_sink import print_sink
from pybeamline_real_sources.ais import ais_source

ais_source().pipe(
	
).subscribe(print_sink())
```

Output:

```
(Undefined, 258007330, AIS, 2020-00-00 14:49:31.101265 - {'mmsi': 258007330, 'second': 29, 'heading': 511, 'lon': 5.312967, 'accuracy': False, 'speed': 0.0, 'course': 326.1, 'lat': 60.392442} - {} - {})
(Moored, 257215400, AIS, 2020-00-00 14:49:31.101265 - {'mmsi': 257215400, 'second': 63, 'heading': 511, 'lon': 181.0, 'accuracy': False, 'speed': 102.3, 'course': 360.0, 'lat': 91.0} - {} - {})
(UnderWayUsingEngine, 257264900, AIS, 2020-00-00 14:49:31.102276 - {'mmsi': 257264900, 'second': 29, 'heading': 511, 'lon': 9.027405, 'accuracy': True, 'speed': 0.0, 'course': 5.1, 'lat': 63.652173} - {} - {})
(UnderWayUsingEngine, 257033030, AIS, 2020-00-00 14:49:31.102276 - {'mmsi': 257033030, 'second': 29, 'heading': 335, 'lon': 17.335573, 'accuracy': False, 'speed': 0.0, 'course': 215.0, 'lat': 68.723927} - {} - {})
(UnderWayUsingEngine, 257153000, AIS, 2020-00-00 14:49:31.102276 - {'mmsi': 257153000, 'second': 29, 'heading': 237, 'lon': 15.819412, 'accuracy': False, 'speed': 2.3, 'course': 245.3, 'lat': 69.479643} - {} - {})
(UnderWayUsingEngine, 257198000, AIS, 2020-00-00 14:49:31.102276 - {'mmsi': 257198000, 'second': 30, 'heading': 279, 'lon': 5.076527, 'accuracy': False, 'speed': 0.0, 'course': 66.1, 'lat': 60.201458} - {} - {})
(UnderWayUsingEngine, 257076900, AIS, 2020-00-00 14:49:31.102276 - {'mmsi': 257076900, 'second': 30, 'heading': 511, 'lon': 15.11809, 'accuracy': False, 'speed': 0.0, 'course': 171.8, 'lat': 67.657533} - {} - {})
(UnderWayUsingEngine, 259031700, AIS, 2020-00-00 14:49:31.102276 - {'mmsi': 259031700, 'second': 29, 'heading': 68, 'lon': 4.97066, 'accuracy': True, 'speed': 6.7, 'course': 66.8, 'lat': 61.239747} - {} - {})
(Moored, 258364000, AIS, 2020-00-00 14:49:31.102276 - {'mmsi': 258364000, 'second': 29, 'heading': 141, 'lon': 5.259447, 'accuracy': False, 'speed': 0.0, 'course': 244.1, 'lat': 59.411605} - {} - {})
(Moored, 257158400, AIS, 2020-00-00 14:49:31.102276 - {'mmsi': 257158400, 'second': 30, 'heading': 511, 'lon': 10.757402, 'accuracy': True, 'speed': 0.0, 'course': 360.0, 'lat': 59.902088} - {} - {})
(EngagedInFishing, 258247000, AIS, 2020-00-00 14:49:31.103287 - {'mmsi': 258247000, 'second': 31, 'heading': 205, 'lon': 10.121003, 'accuracy': False, 'speed': 8.7, 'course': 209.0, 'lat': 64.159853} - {} - {})

```