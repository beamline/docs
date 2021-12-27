
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
    <version>0.0.1</version>
</dependency>
```
See <https://jitpack.io/#beamline/framework> for further details (e.g., using it with Gradle).


## Hello world stream mining

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
GraphvizResponse response = (GraphvizResponse) discoveryAlgorithm.getLatestResponse();
response.generateDot().exportToSvg(new File("result.svg"));
```

## Basic concepts

In this section the basic concepts of the Beamline framework are presented.

### Observables

> An *observer* subscribes to an *Observable*. Then that observer reacts to whatever item or sequence of items the Observable *emits*. This pattern facilitates concurrent operations because it does not need to block while waiting for the Observable to emit objects, but instead it creates a sentry in the form of an observer that stands ready to react appropriately at whatever future time the Observable does so.
> -- <cite>Text from <https://reactivex.io/documentation/observable.html>.</cite>

In the context of Beamline it is possible to define observables of any type. The framework comes with some observables already defined. The generic interface `Source<T>` defines the basic contract that the source of an observable (with type `T`) must implement. Sources already implemented are `XesLogSource` and `MQTTXesSource`. A `XesLogSource` creates an observable from a static log (useful for testing purposes). An `MQTTXesSource` generates and observable from an [MQTT-XES](mqtt-xes.md) stream. all `XesLogSource`s generate a stream of `XTrace`s (as defined in [OpenXES](https://www.xes-standard.org/openxes/start)) where each trace contains one event.

Before using any stream generator, it is necessary to prepare it, using the following syntax:
```java
XesSource source = new XesLogSource("log.xes"); // construct the source
source.prepare(); // prepare the source, by parsing the static log
Observable<XTrace> obs = source.getObservable(); // gather the observable
```

The class diagram of the observable sources available in Beamline Framework is reported below:

<div class="mermaid">
classDiagram
Source~T~ <|-- XesSource : bind T as XTrace
XesSource <|-- XesLogSource
XesSource <|-- MQTTXesSource
Source : +getObservable() Observable~T~
</div>



### Hot and Cold Observables

In the ReactiveX world, there is a distinction between two types of observables: hot and cold. Cold observables create a data producer for each subscriber whereas hot observables create data irrespectively from whether there is any subscriber or not. To reuse an example already mentioned in [the literature](https://www.manning.com/books/angular-development-with-typescript-second-edition), it is like watching a movie: you can decide to watch it at home using an on-deamnd service (which streams the movie only when someone asks for it, i.e., cold observable) or by going to the movie theater (which has the movie started at a given hour, independently from whether there are spectators or not, i.e., hot observable).

In Beamline Framework, the following are **cold observables**:

- `XesLogSource`: observes all events from an XES event log.

The following are **hot observables**:

- `MQTTXesSource`: observes all events on an MQTT broker respecting the MQTT-XES protocol.



### Filters

The [filter operator, in ReactiveX,](https://reactivex.io/documentation/operators/filter.html) does not change the stream, but filters the events so that only those passing a predicate test can pass. In Beamline there are some filters already implemented that can be used as follows:

```java linenums="1" hl_lines="4"
XesSource source = ...
Observable<XTrace> obs = source.getObservable();
obs
   .filter(new RetainActivitiesFilter("A", "B", "C")
   .subscribe(...);
```

In line 3 a filter is specified so that only events referring to activities `A`, `B`, and `C` are maintained (while all others are discarded).

Filters can operate on event attributes or trace attributes and the following are currently available:

- `RetainOnEventAttributeEqualityFilter` and `ExcludeOnEventAttributeEqualityFilter` which retain or exclude events based on the equality of an event attribute. The filter `RetainActivitiesFilter` is a refined version of `RetainOnEventAttributeEqualityFilter` where the attribute name is the `concept:name`;
- `RetainOnCaseAttributeEqualityFilter` and `ExcludeOnCaseAttributeEqualityFilter` which retain or exclude events based on the equality of a trace attribute.

Filters can be chained together in order to achieve the desired result.


### Results

Results are produced by miners as events are processed.
