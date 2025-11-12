## Dependency

To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the dependency:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>conformance-behavioural-patterns</artifactId>
    <version>master-SNAPSHOT</version>
</dependency>
```
See the [introduction page](index.md) for further instructions.

[![](https://jitpack.io/v/beamline/conformance-behavioural-patterns.svg)](https://jitpack.io/#beamline/conformance-behavioural-patterns)


## Usage

To use the technique you need to create the conformance checker object using:

```java linenums="1"

Petrinet net = ...;
Marking marking = ...;
int maxCasesToStore = 1000; // max expected number of parallel process instances

BehavioralConformance conformance = new BehavioralConformance(net, marking, maxCasesToStore);
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env
    .addSource(source)
    .keyBy(BEvent::getTraceName)
    .flatMap(conformance)
    .addSink(new SinkFunction<OnlineConformanceScore>(){
        public void invoke(OnlineConformanceScore value) throws Exception {
            System.out.println(
                value.getConformance() + " - " +
                value.getCompleteness() + " - " +
                value.getConfidence());
        };
    });
env.execute();

```

It is worth highlighting that since each trace can be processed independently from the others, it is possible to increase the parallelism by keying the stream based on the case identifier (`BEvent::getTraceName`, line 9).

In the current version, the reference model must be provided as a Petri Net.


!!! note "Importing a Petri net"
    To import a Petri net it is possible to use the [`simple-pnml` library](/simple-pnml):
    ```java linenums="1"
    Object[] i = PnmlImportNet.importFromStream(new FileInputStream(new File("petri-net-model.pnml")));
    Petrinet net = (Petrinet) i[0];
    Marking marking = (Marking) i[1];
    ```


## Scientific literature

The techniques implemented in this package are described in:

- [Online Conformance Checking Using Behavioural Patterns](https://andrea.burattin.net/publications/2018-bpm)  
A. Burattin, S. van Zelst, A. Armas-Cervantes, B. van Dongen, J. Carmona  
In Proceedings of BPM 2018; Sydney, Australia; September 2018.
