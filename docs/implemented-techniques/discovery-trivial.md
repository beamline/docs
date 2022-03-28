## Dependency [![](https://jitpack.io/v/beamline/discovery-trivial.svg)](https://jitpack.io/#beamline/discovery-trivial)

To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the dependency:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>discovery-trivial</artifactId>
    <version>master-SNAPSHOT</version>
</dependency>
```
See the [introduction page](index.md) for further instructions.


## Usage


This miner extracts just a dependency map leveraging the directly follows relations observed in the stream. Once a `XesSource` is available, the miner can be configured and used as follows:

```java linenums="1"

DirectlyFollowsDependencyDiscoveryMiner miner = new DirectlyFollowsDependencyDiscoveryMiner();
miner.setModelRefreshRate(1); // configure how ofter the mining algorithm should emit a new model
miner.setMinDependency(0.8); // configure the dependency threshold

StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env
	.addSource(new StringTestSource("ABCDF", "ABCEF"))
	.keyBy(BEvent::getProcessName)
	.flatMap(miner)
	.addSink(new SinkFunction<ProcessMap>(){
		public void invoke(ProcessMap value, Context context) throws Exception {
			value.generateDot().exportToSvg(new File("output.svg"));
		};
	});
env.execute();
```

## Scientific literature

The techniques implemented in this package are described in:

- [Process Mining Techniques in Business Environments](https://andrea.burattin.net/publications/monograph)  
A. Burattin  
Springer, 2015.