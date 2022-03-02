
## Installing the library

To use the Beamline framework in your Java Maven project it is necessary to include, in the `pom.xml` file, the package repository:
```xml
<repositories>
    <repository>
        <id>jitpack.io</id>
        <url>https://jitpack.io</url>
    </repository>
</repositories>
```
Then you can include the dependency to the version you are interested, for example:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>framework</artifactId>
    <version>x.y.z</version>
</dependency>
```
See <https://jitpack.io/#beamline/framework> for further details (e.g., using it with Gradle).


## Hello world stream mining

The following code represents a minimum running example that, once implemented in the `main` method of a Java class should provide some basic understanding of the concepts:

```java linenums="1"
// step 1: configuration of the data source (in this case a static file, for reproducibility)
XesSource source = new XesLogSource("log-file.xes");
source.prepare();

// step 2: configuration of the algorithm
DiscoveryMiner miner = new DiscoveryMiner();
miner.setMinDependency(0.3);

// step 3: processing of all events
Observable<XTrace> obs = source.getObservable();
obs
   .filter(new RetainActivitiesFilter("A", "B", "C", "D"))
   .filter(new ExcludeActivitiesFilter("noisy1", "noisy2"))
   .subscribe(miner);

// step 4: consumption of the results
GraphvizResponse response = (GraphvizResponse) miner.getLatestResponse();
response.generateDot().exportToSvg(new File("result.svg"));
```

In step 1 the stream source is configured and, in this specific case, the stream is defined as coming from a static IEEE XES file. The stream is then `prepare`d (i.e., all events are serialized and sorted by their time). In step 2, an hypothetical miner is created and configured, using custom methods (such as the `setMinDependency` method). Step 3 consists of the definition of the chain of operations to be performed on each event of the stream. In this case, each event is filtered using the `RetainActivitiesFilter` and the `ExcludeActivitiesFilter` before being sent to the miner. Since this stream will finish (since it comes from a static file, as opposed to never-ending streams), the code above will continue to step 4, where the latest output computed from the miner will be extracted and, since it is a graphical response, it will be stored as an SVG file.



## Basic concepts

In this section the basic concepts of the Beamline framework are presented.

### Observables

> An *observer* subscribes to an *Observable*. Then that observer reacts to whatever item or sequence of items the Observable *emits*. This pattern facilitates concurrent operations because it does not need to block while waiting for the Observable to emit objects, but instead it creates a sentry in the form of an observer that stands ready to react appropriately at whatever future time the Observable does so.
> -- <cite>Text from <https://reactivex.io/documentation/observable.html>.</cite>

In the context of Beamline it is possible to define observables of any type. The framework comes with some observables already defined. The generic interface `Source<T>` defines the basic contract that the source of an observable (with type `T`) must implement. Sources already implemented are `XesLogSource` and `MQTTXesSource`. A `XesLogSource` creates an observable from a static log (useful for testing purposes). An `MQTTXesSource` generates and observable from an [MQTT-XES](mqtt-xes.md) stream. all `XesLogSource`s generate a stream of `XTrace`s (as defined in [OpenXES](https://www.xes-standard.org/openxes/start)) where each trace contains one event.

Before using any stream generator, it is **necessary** to `prepare` it, using the following syntax:
```java
XesSource source = new XesLogSource("log.xes"); // construct the source
source.prepare(); // prepare the source, by parsing the static log
Observable<XTrace> obs = source.getObservable(); // gather the observable
```

The class diagram of the observable sources available in Beamline Framework is reported below:

<div class="mermaid">
classDiagram
Source~T~ <|-- XesSource : &laquo;bind&raquo; T&#42889;&#42889;XTrace
XesSource <|.. XesLogSource
XesSource <|.. CSVLogSource
XesSource <|.. MQTTXesSource
Source : +getObservable() Observable~T~

<< interface >> Source
<< interface >> XesSource
</div>



### Hot and Cold Observables

In the ReactiveX world, there is a distinction between two types of observables: hot and cold. Cold observables create a data producer for each subscriber whereas hot observables create data irrespectively from whether there is any subscriber or not. To reuse an example already mentioned in [the literature](https://www.manning.com/books/angular-development-with-typescript-second-edition), it is like watching a movie: you can decide to watch it at home using an on-deamnd service (which streams the movie only when someone asks for it, i.e., cold observable) or by going to the movie theater (which has the movie started at a given hour, independently from whether there are spectators or not, i.e., hot observable).

In Beamline Framework, the following observable are available:

#### `XesLogSource`, cold observable

Observes all events from an XES event log. Example usage:
```java linenums="1"
XLog l = ...
XesSource source = new XesLogSource(l);
source.prepare();
```


#### `CSVLogSource`, cold observable

Observes all events from a CSV file, column numbers for case id and activity name must be provided in the constructor. Example usage:
```java linenums="1"
int caseIdColumn = 0;
int activityColumn = 1;
XesSource source = new CSVLogSource("filename.csv", caseIdColumn, activityColumn);
source.prepare();
```


#### `MQTTXesSource`, hot observable

Observes all events on an MQTT broker respecting the MQTT-XES protocol. Example usage:
```java linenums="1"
XesSource source = new MQTTXesSource("tcp://broker.hivemq.com:1883", "root", "processName");
source.prepare();
```




### Filters

The [filter operator, in ReactiveX,](https://reactivex.io/documentation/operators/filter.html) does not change the stream, but filters the events so that only those passing a predicate test can pass. In Beamline there are some filters already implemented that can be used as follows:

```java linenums="1" hl_lines="5"
XesSource source = ...
source.prepare();
Observable<XTrace> obs = source.getObservable();
obs
   .filter(new RetainActivitiesFilter("A", "B", "C")
   .subscribe(...);
```

In line 3 a filter is specified so that only events referring to activities `A`, `B`, and `C` are maintained (while all others are discarded).

Filters can operate on event attributes or trace attributes and the following are currently available:

| Filter name | Description |
| --- | --- |
| `RetainOnEventAttributeEqualityFilter` | Retains events based on the equality of an event attribute. |
| `ExcludeOnEventAttributeEqualityFilter` | Exclude events based on the equality of an event attribute. |
| `RetainOnCaseAttributeEqualityFilter` | Retains events based on the equality of a trace attribute. |
| `ExcludeOnCaseAttributeEqualityFilter` | Excludes events based on the equality of a trace attribute. |
| `RetainActivitiesFilter` | Retains activities base on their name (`concept:name`). |
| `ExcludeActivitiesFilter` | Excludes activities base on their name (`concept:name`). |

Please note that filters can be chained together in order to achieve the desired result.


### Mappers

The current version of Beamline supports some mappers too, which allow to change the shape of the stream in order to consume different events. In ReactiveX there are two main types of map operators: [`map`](https://reactivex.io/documentation/operators/map.html) and [`flatMap`](https://reactivex.io/documentation/operators/flatmap.html). The former maps all events into new events, the latter can also merge some of the events together.

Currently these mappers are supported:

| Filter name | Operator | Description |
|---|---|---|
| `InfiniteSizeDirectlyFollowsMapper` | `flatMap` | A mapper that transforms each pair of consequent event appearing in the same case as a directly follows operator (generating an object with type `DirectlyFollowsRelation`). This mapper is called *infinite* because it's memory footprint will grow as the case ids grow. |

An example of how mappers can be used is the following:

```java
XesSource source = ...
source.prepare();
Observable<XTrace> obs = source.getObservable();
obs
   .flatMap(new InfiniteSizeDirectlyFollowsMapper())
   .subscribe(new Consumer<DirectlyFollowsRelation>() {
        @Override
        public void accept(@NonNull DirectlyFollowsRelation t) throws Throwable {
            System.out.println(
                    XConceptExtension.instance().extractName(t.getFirst()) +  " -> " +
                    XConceptExtension.instance().extractName(t.getSecond()) + 
                    " for case " + t.getCaseId());
        }
    });
```


### Mining algorithms

A mining algorithm is a subscriber consuming the generated `Observable`s. All mining algorithms must extend the abstract class `StreamMiningAlgorithm`. This class is structured as:

<div class="mermaid">
classDiagram
class StreamMiningAlgorithm~T,K extends Response~
<< abstract >> StreamMiningAlgorithm
StreamMiningAlgorithm:+ingest(T)* K
StreamMiningAlgorithm:+getLatestResponse() K
StreamMiningAlgorithm:+getProcessedEvents() int
StreamMiningAlgorithm:+setOnBeforeEvent(HookEventProcessing)
StreamMiningAlgorithm:+setOnAfterEvent(HookEventProcessing)
</div>

The [generic types](https://en.wikipedia.org/wiki/Generics_in_Java) `T` and `K` refer, respectively to the type of the event and the type of the generated output (i.e., the result of the mining algorithm). The only abstract method that needs to be implemented by a mining algorithm is `ingest(T) : K` which receives an event as actual parameter and returns the result of the ingestion of the event as value. Other useful methods are `getLatestResponse() : K` and `getProcessedEvents() : int` that return, respectively, the latest response generated and the number of events processed up to now. Finally, there is the possibility to setup hooks to be executed before and after the processing of each event using the methods `setOnBeforeEvent()` and `setOnAfterEvent` both of which take as parameter an instance of the class `HookEventProcessing`:

<div class="mermaid">
classDiagram
class HookEventProcessing
<< interface >> HookEventProcessing
HookEventProcessing:+trigger()
</div>

The `trigger()` must implement the action required.

A simple example of a mining algorithm configuration is reported below:

```java linenums="1"
XesSource source = ...
source.prepare();
Observable<XTrace> obs = source.getObservable();

DiscoveryMiner miner = new DiscoveryMiner();
miner.setMinDependency(0.3);

obs.subscribe(miner);
```

Bear in mind that miners can also be defined as normal consumers as in RXJava. Here is what such a consumer may look like, assuming that the expected behavior consists just of printing the case id, the activity name, and the time of the event:

```java linenums="1"
XesSource source = ...
source.prepare();
Observable<XTrace> obs = source.getObservable();

obs.subscribe(new Consumer<XTrace>() {
	@Override
	public void accept(@NonNull XTrace t) throws Throwable {
		System.out.println(
			XConceptExtension.instance().extractName(t) + " - " +
			XConceptExtension.instance().extractName(t.get(0)) +  " - " +
			XTimeExtension.instance().extractTimestamp(t.get(0))
		);
	}
});
```

### Results

Results are produced by miners as events are processed. Currently, Beamline supports an empty `Response` interface which might be implemented to custom behavior as well as a Graphviz graphical representation in a `GraphvizResponse` interface. Hence this is the hierarchy of results:

<div class="mermaid">
classDiagram
class Response
class GraphvizResponse
<< interface >> Response
<< interface >> GraphvizResponse
GraphvizResponse : generateDot() Dot
Response <|-- GraphvizResponse
</div>

An example of a way to consume these results is reported in the following code:

```java linenums="1"
DiscoveryMiner miner = new DiscoveryMiner();
miner.setOnAfterEvent(new HookEventProcessing() {
    @Override
    public void trigger() {
        int events = miner.getProcessedEvents();
        if (events % 100 == 0) {
            try {
                GraphvizResponse resp = miner.getLatestResponse();
                resp.generateDot().exportToSvg(new File("output-" + events + ".svg"));
            } catch (IOException e) { }
        }
    }
});

XesSource source = ...
source.prepare();
Observable<XTrace> obs = source.getObservable();
obs.subscribe(miner);
```

In this code, we assume the existence of a miner called `DiscoveryMiner` which produces output as an object with (sub)type `GraphvizResponse`. In line 2 there is new hook registered to be processed after each event and, every 100 events (line 6), the code extracts the last result of the mining (line 8), converts to SVG and dumps it to a file (line 9). The miner if then registered to consume events from the stream (line 19).
