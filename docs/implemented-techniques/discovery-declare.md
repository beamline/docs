## Dependency

To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the dependency:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>discovery-declare</artifactId>
    <version>master-SNAPSHOT</version>
</dependency>
```
See the [introduction page](index.md) for further instructions.

[![](https://jitpack.io/v/beamline/discovery-declare.svg)](https://jitpack.io/#beamline/discovery-declare)


## Usage

It is possible to call the two miners `beamline.miners.declare.DeclareMinerLossyCounting` and `beamline.miners.declare.DeclareMinerBudgetLossyCounting` using the following:

```java linenums="1"
DeclareMinerLossyCounting miner = new DeclareMinerLossyCounting(
	0.001, // the maximal approximation error
	10 // the number of declare constraints to show
);
```
```java linenums="1"
DeclareMinerBudgetLossyCounting miner = new DeclareMinerBudgetLossyCounting(
	1000, // the available budget
	10 // the number of declare constraints to show
);
```

After the miner is configured, both can be used to produce a CNet which can be either exported into a `.cnet` file or visualized (currently the visualization does not support the bindings):

```java linenums="5"
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env
	.addSource(source)
	.keyBy(BEvent::getProcessName)
	.flatMap(miner.setModelRefreshRate(100))
	.addSink(new SinkFunction<DeclareModelView>(){
		public void invoke(DeclareModelView value, Context context) throws Exception {
			value.generateDot().exportToSvg(new File("output.svg"));
		};
	});
env.execute();
```

## Scientific literature

The techniques implemented in this package are described in:

- [Online Discovery of Declarative Process Models from Event Streams](https://andrea.burattin.net/publications/2015-tsc)  
A. Burattin, M. Cimitile, F. Maggi, A. Sperduti  
In IEEE Transactions on Services Computing, vol. 8 (2015), no. 6, pp. 833-846.