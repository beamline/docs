<center>
    <iframe width="560" height="315" src="https://www.youtube.com/embed/8eagbpJ_hK4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</center>


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

[![](https://jitpack.io/v/beamline/framework.svg)](https://jitpack.io/#beamline/framework)



## Hello world stream mining

The following code represents a minimum running example that, once implemented in the `main` method of a Java class should provide some basic understanding of the concepts:

```java linenums="1"
// step 1: configuration of the event source (in this case a static file, for reproducibility)
XesSource source = new XesLogSource("log-file.xes");

// step 2: configuration of the algorithm
DiscoveryMiner miner = new DiscoveryMiner();
miner.setMinDependency(0.3);

// step 3: construction of the dataflow from the environment
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env.addSource(source)
   .keyBy(BEvent::getProcessName)
   .flatMap(miner)
   .addSink(new SinkFunction<ProcessMap>(){
       public void invoke(ProcessMap value, Context context) throws Exception {
           value.generateDot().exportToSvg(new File("output.svg"));
       };
   });

// step 4: consumption of the results
env.execute();
```

In step 1 the stream source is configured and, in this specific case, the stream is defined as coming from a static IEEE XES file. In step 2, an hypothetical miner is created and configured, using custom methods (such as the `setMinDependency` method). Step 3 consists of the definition of the chain of operations to be performed on each event of the stream. In this case, after the source is connected (`addSource`), we inform Flink that events can be distributed but all those that belong to the same process should be treated together (`keyBy`); then the events are `flatMap`ped - meaning that not all events will result in a mining result - by the miner; and finally a sink is connected to save the SVG map to file (`addSink`). In step 4, the defined pipeline is finally executed.



## Basic concepts

In this section the basic concepts of the Beamline framework are presented.


### Streaming dataflow

Each application based on Apache Flink relies on the concept of *streaming dataflow*. A streaming dataflow consists of the basic transformations applied to each event, from its origin (called *source*) until the end (called *sink*). In between, different *operators* can be chained together in order to transform the data according to the requirements. Once this pipeline of operations is defined, it can be deployed and Apache Flink will take care of the actual execution, including parallelizing possible operations and distributing the data across the network.

<figure markdown>
  ![](img/program_dataflow.svg)
  <figcaption markdown>
Conceptualization of the streaming dataflow as operated by Apache Flink. Picture from <https://nightlies.apache.org/flink/flink-docs-release-1.14/docs/learn-flink/overview>.
  </figcaption>
</figure>


### Events

While Apache Flink can be designed to transmit any type of event, the Beamline framework comes with its own definition of event, called `BEvent`. Here some of the corresponding methods are highlighted:
<figure>
<div class="mermaid">
classDiagram
class BEvent {
    +Map~String, Serializable~ processAttributes
    +Map~String, Serializable~ traceAttributes
    +Map~String, Serializable~ eventAttributes
    +getProcessName(): String
    +getTraceName(): String
    +getEventName(): String
    +getEventTime(): Date
    +setProcessAttribute(String name, XAttribute value)
    +setTraceAttribute(String name, XAttribute value)
    +setEventAttribute(String name, XAttribute value)
}
</div>
</figure>
Essentially, a Beamline event, consists of 3 maps for attributes referring to the process, to the trace, and to the event itself. While it's possible to set all the attributes individually, some convenience methods are proposed as well, such as `getTraceName` which returns the name of the trace (i.e., the *case id*). Internally, a `BEvent` stores the basic information using as attribute names the same provided by the [standard extension of OpenXES](https://www.xes-standard.org/xesstandardextensions). Additionally, setters for attributes defined in the context of OpenXES are provided too, thus providing some level of interoperability between the platforms.

!!! note "Comparison with OpenXES"
    While the usage of OpenXES has been considered, it has been decided that it is better to have a proper definition of event which embeds all information. This is due to the fact that in streaming processing each event is an atomic independent unit, i.e., it is not really possible to have collections of traces or collections of events part of the same happening.


### Sources

In the context of Beamline it is possible to define sources to create any possible type of event. The framework comes with some sources already defined for the generation of `BEvent`s. The base class of all sources is called `BeamlineAbstractSource` which implements a `RichSourceFunction`. In Apache Flink, a "rich" function is a function which can have access to the distributed state and thus become [stateful](https://nightlies.apache.org/flink/flink-docs-release-1.14/docs/concepts/stateful-stream-processing/).
Sources already implemented are `XesLogSource`, `MQTTXesSource`, `CSVLogSource`, and `StringTestSource`. A `XesLogSource` creates a source from a static log (useful for testing purposes). An `MQTTXesSource` generates an source from an [MQTT-XES](mqtt-xes.md) stream. `CSVLogSource` is a source which reads events from a text file, and `StringTestSource` allows the definition of simple log directly in its constructor (useful for testing purposes).
The class diagram of the observable sources available in Beamline Framework is reported below:

<figure>
<div class="mermaid">
classDiagram
RichSourceFunction~OUT~ <|-- BeamlineAbstractSource : &laquo;bind&raquo; OUT&#42889;&#42889;BEvent
BeamlineAbstractSource <|.. XesLogSource
BeamlineAbstractSource <|.. CSVLogSource
BeamlineAbstractSource <|.. MQTTXesSource
BeamlineAbstractSource <|.. StringTestSource
RichSourceFunction : +run(SourceContext~OUT~ ctx) void

<< abstract >> RichSourceFunction
BeamlineAbstractSource
</div>
</figure>

In order to use any source, it is possible to provide it to the `addSource` method:
```java linenums="1"
BeamlineAbstractSource source = ...
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
DataStream<BEvent> stream = env.addSource(source);
// add all other transformation operators here...
env.execute();
```

??? note "Details on `XesLogSource`"
    Emits all events from an XES event log. Example usage:
    ```java
    XLog l = ...
    XesLogSource source = new XesLogSource(l);
    ```
    Or, alternatively, providing directly the path to the log file:
    ```java
    XesLogSource source = new XesLogSource("path/to/log.xes"); // any file format supported by OpenXES can be used
    ```

??? note "Details on `CSVLogSource`"
    Emits all events from a CSV file, column numbers for case id and activity name must be provided in the constructor. Example usage:
    ```java
    int caseIdColumn = 0;
    int activityColumn = 1;
    CSVLogSource source = new CSVLogSource("filename.csv", caseIdColumn, activityColumn);
    ```
    Additional configuration parameters can be provided, like the separator:
    ```java
    CSVLogSource source = new CSVLogSource(
        "filename.csv",
        caseIdColumn,
        activityColumn,
        new CSVLogSource.ParserConfiguration().withSeparator('|'));
    ```

??? note "Details on `MQTTXesSource`"
    Forwards all events on an MQTT broker respecting the MQTT-XES protocol. Example usage:
    ```java
    MQTTXesSource source = new MQTTXesSource("tcp://broker.hivemq.com:1883", "root", "processName");
    source.prepare();
    ```

??? note "Details on `StringTestSource`"
    Source that considers each trace as a string provided in the constructor and each event as one character of the string. Example usage:
    ```java
    StringTestSource s = new StringTestSource("ABC", "ADCE");
    ```
    This source is going to emit 7 events as part of 2 traces.




### Filters

The [filter operators, in Apache Flink,](https://nightlies.apache.org/flink/flink-docs-release-1.14/docs/dev/datastream/operators/overview/#filter) do not change the type of  stream, but filters the events so that only those passing a predicate test can pass. In Beamline there are some filters already implemented that can be used as follows:

```java linenums="1" hl_lines="5"
BeamlineAbstractSource source = ...
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env
    .addSource(source)
    .filter(new RetainActivitiesFilter("A", "B", "C"))
    // add all other transformation operators here...
env.execute();
```

In line 5 a filter is specified so that only events referring to activities `A`, `B`, and `C` are maintained (while all others are discarded).

Filters can operate on event attributes or trace attributes and the following are currently available:

??? note "Details on `RetainOnEventAttributeEqualityFilter`"
    Retains events based on the equality of an event attribute. Example:
    ```java
    FilterFunction filter = new RetainOnEventAttributeEqualityFilter<String>("attribute-name", "v1", "v2");
    ```

??? note "Details on `ExcludeOnEventAttributeEqualityFilter`"
    Exclude events based on the equality of an event attribute.
    ```java
    FilterFunction filter = new ExcludeOnEventAttributeEqualityFilter<String>("attribute-name", "v1", "v2");
    ```

??? note "Details on `RetainOnCaseAttributeEqualityFilter`"
    Retains events based on the equality of a trace attribute.
    ```java
    FilterFunction filter = new RetainOnCaseAttributeEqualityFilter<String>("attribute-name", "v1", "v2");
    ```

??? note "Details on `ExcludeOnCaseAttributeEqualityFilter`"
    Excludes events based on the equality of a trace attribute.
    ```java
    FilterFunction filter = new ExcludeOnCaseAttributeEqualityFilter<String>("attribute-name", "v1", "v2");
    ```

??? note "Details on `RetainActivitiesFilter`"
    Retains activities base on their name (`concept:name`).
    ```java
    FilterFunction filter = new RetainActivitiesFilter("act-1", "act2");
    ```

??? note "Details on `ExcludeActivitiesFilter`"
    Excludes activities base on their name (`concept:name`).
    ```java
    FilterFunction filter = new ExcludeActivitiesFilter("act-1", "act2");
    ```

Please note that filters can be chained together in order to achieve the desired result.


### Mining algorithms

A mining algorithm is a [`flatMap`er](https://nightlies.apache.org/flink/flink-docs-release-1.14/docs/dev/datastream/operators/overview/#flatmap) consuming events generated from a source. All mining algorithms must extend the abstract class `StreamMiningAlgorithm`. This class is structured as:

<figure>
<div class="mermaid">
classDiagram
class RichFlatMapFunction~IN, OUT~
class StreamMiningAlgorithm~T extends Response~
<< abstract >> StreamMiningAlgorithm
StreamMiningAlgorithm:+ingest(BEvent event)* T
StreamMiningAlgorithm:+getProcessedEvents() long

<< abstract >> RichFlatMapFunction

RichFlatMapFunction <|-- StreamMiningAlgorithm : &laquo;bind&raquo; IN&#42889;&#42889;BEvent
</div>
</figure>

The [generic types](https://en.wikipedia.org/wiki/Generics_in_Java) `T` refers to the type of the generated output (i.e., the result of the mining algorithm). The only abstract method that needs to be implemented by a mining algorithm is `ingest(BEvent event) : K` which receives an event as actual parameter and returns the result of the ingestion of the event as value or the special value `null`. If `null` is returned, nothing will be propagated down to the pipeline, for example, it might not be interesting to mine a process for each event observed, but maybe every 100 events (and thus the reason for having a `flatMap`). The other method offered is `getProcessedEvents() : long` that returns the number of events processed up to now.

Since a `StreamMiningAlgorithm` is a "rich" function, it is possible to have access to the status information. Additionally, since this operator might be distributed, it is necessary to apply it on a [keyed stream](https://nightlies.apache.org/flink/flink-docs-release-1.14/docs/dev/datastream/fault-tolerance/state/#keyed-datastream). A key can be used [to split the stream into independent "branches"](https://nightlies.apache.org/flink/flink-docs-release-1.14/docs/dev/datastream/operators/overview/#keyby) that can be processed in parallel by different instances of the operators occurring afterwards. It is therefore extremely important to choose wisely how to key a stream. Instances of the same operator that are applied on different "branches" (obtained by keying the stream) cannot communicate between each other. Examples of keys in different contexts:

* If the goal is to perform control-flow discovery, probably it is necessary to key the stream based on the process name (using `keyBy(BEvent::getProcessName)`): all events that belong to the same process should be considered by the same instance of the mining algorithm to extract the same process;
* If the goal is to perform conformance checking, probably it is enough to key the stream based on the process instance (a.k.a., trace name or case id; using `keyBy(BEvent::getTraceName)`): in a streaming context, each trace is independent from the others with respect to the goal of calculating their conformance, and hence there is no need to share information regarding the whole process.


In the core of the Beamline library there is only one mining algorithm implemented (though [other are available as additional dependencies](/implemented-techniques/)):

??? note "Details on `InfiniteSizeDirectlyFollowsMapper`"
    An algorithm that transforms each pair of consequent event appearing in the same case as a directly follows operator (generating an object with type `DirectlyFollowsRelation`). This mapper is called *infinite* because it's memory footprint will grow as the case ids grow. The mapper produces results as `DirectlyFollowsRelation`s.

    An example of how the algorithm can be used is the following:

    ```java
    BeamlineAbstractSource source = ...
    StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
    env
        .addSource(source)
        .keyBy(BEvent::getProcessName)
        .flatMap(new InfiniteSizeDirectlyFollowsMapper())
        .addSink(new SinkFunction<DirectlyFollowsRelation>() {
            public void invoke(ProcessMap value, Context context) throws Exception {
                System.out.println(value.getFrom() + " -> " + value.getTo());
            };
        });
    env.execute();
    ```


### Responses

Responses are produced by miners as events are processed. Currently, Beamline supports an empty `Response` class which might be extended to custom behavior as well as a Graphviz graphical representation in a `GraphvizResponse` abstract class and some others. On all `Response` objects it is possible to invoke the `getProcessedEvents()` method, which indicates how many events that response has processed. Hence this is the hierarchy of results:

<figure>
<div class="mermaid">
classDiagram
class Response
<< abstract >> Response
Response : getProcessedEvents() long

class StringResponse
StringResponse : get() String

class GraphvizResponse
<< abstract >> GraphvizResponse
GraphvizResponse : generateDot()* Dot

class DirectlyFollowsRelation
DirectlyFollowsRelation : getCaseId() String
DirectlyFollowsRelation : getFrom() BEvent
DirectlyFollowsRelation : getTo() BEvent

Response <|-- StringResponse
Response <|-- DirectlyFollowsRelation
Response <|-- GraphvizResponse
</div>
</figure>

An example of a way to consume these results is reported in the following code:

```java linenums="1"
BeamlineAbstractSource source = ...
DiscoveryMiner miner = new DiscoveryMiner();
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env
    .addSource(source)
    .keyBy(BEvent::getProcessName)
    .flatMap(miner)
    .addSink(new SinkFunction<GraphvizResponse>() {
        public void invoke(GraphvizResponse value, Context context) throws Exception {
            value.generateDot().exportToSvg(new File("output-" + value.getProcessedEvents() + ".svg"));
        };
    });
env.execute();
```

In this code, we assume the existence of a miner called `DiscoveryMiner` which produces output as an object with (sub)type `GraphvizResponse`.
