# Getting Started

In this page JBeamline is presented.

<center>
    <iframe width="560" height="315" src="https://www.youtube.com/embed/8eagbpJ_hK4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</center>


## *Hello world* with JBeamline

The following code represents a minimum running example that, once implemented in the `main` method of a Java class should provide some basic understanding of the concepts:

```java linenums="1"
// step 1: configuration of the event source (in this case a static file, for reproducibility)
XesLogSource source = new XesLogSource("log-file.xes");

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

In step 1 the stream source is configured and, in this specific case, the stream is defined as coming from a static IEEE XES file.

In step 2, an hypothetical miner is created and configured, using custom methods (such as the `setMinDependency` method).

Step 3 consists of the definition of the chain of operations to be performed on each event of the stream. In this case, after the source is connected (`addSource`), we inform Flink that events can be distributed but all those that belong to the same process should be treated together (`keyBy`); then the events are `flatMap`ped - meaning that not all events will result in a mining result - by the miner; and finally a sink is connected to save the SVG map to file (`addSink`).

In step 4, the defined pipeline is finally executed.
