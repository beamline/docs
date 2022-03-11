## Dependency [![](https://jitpack.io/v/beamline/discovery-dcr.svg)](https://jitpack.io/#beamline/discovery-dcr)

To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the dependency:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>discovery-dcr</artifactId>
    <version>master-SNAPSHOT</version>
</dependency>
```
See the [introduction page](index.md) for further instructions.


## Usage

To construct a DCR miner it is possible to construct it with the following code:

```java linenums="1"
DFGBasedMiner miner = new DFGBasedMiner();
```

It is possible (though not necessary) to configure the miner with the following parameters:

```java linenums="2"
// configuration of list of patters
miner.setDcrPatternsForMining("Response", "Condition", "Include", "Exclude");

// configuration of the miner type
miner.setStreamMinerType(new UnlimitedStreamMiner());
//miner.setStreamMinerType(new SlidingWindowStreamMiner(15, 500));

// configure which constraints to visualize
miner.setDcrConstraintsForVisualization(RELATION.CONDITION, RELATION.RESPONSE);

// configure the threshold
miner.setRelationsThreshold(1);

// configure the transitive reduction
miner.setTransitiveReductionList(RELATION.CONDITION, RELATION.RESPONSE);
```

Once the miner is properly configured, it can be used as any other consumer. For example, using the following code:
```java linenums="17"
XesSource source = ...
source.prepare();
source
	.getObservable()
	.subscribe(miner);

```

It is also possible to attach hooks to the miner, for example to export the model every so often:
```java
miner.setOnAfterEvent(() -> {
	if (miner.getProcessedEvents() % 1000 == 0) {
		try {
			new DcrModelView(miner.getDcrModel()).exportToSvg(new File("out.svg"));
		} catch (IOException e) { }
	}
});
```



## Scientific literature

The techniques implemented in this package are described in:

- TBA