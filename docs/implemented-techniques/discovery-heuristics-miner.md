## Dependency [![](https://jitpack.io/v/beamline/discovery-heuristics.svg)](https://jitpack.io/#beamline/discovery-heuristics)

To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the dependency:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>discovery-heuristics</artifactId>
    <version>master-SNAPSHOT</version>
</dependency>
```
See the [introduction page](index.md) for further instructions.


## Usage


This miner contains two version of the streaming Heuristics miner. One is based on the Lossy Counting algorithm, the other is based on the Lossy Counting with Budget. These can be accessed with the following parameters:

```java linenums="1"
HeuristicsMinerLossyCounting miner = new HeuristicsMinerLossyCounting(
	0.0001, // the maximal approximation error
	0.8, // the minimum dependency threshold
	10, // the positive observation threshold
	0.1 // the and threshold
);
```

```java linenums="1"
HeuristicsMinerBudgetLossyCounting miner = new HeuristicsMinerBudgetLossyCounting(
	100000, // the total budget available
	0.8, // the minimum dependency threshold
	10, // the positive observation threshold
	0.1 // the and threshold
);
```

After the miner is configured, both can be used to produce a CNet which can be either exported into a `.cnet` file or visualized (currently the visualization does not support the bindings):

```java linenums="7"
// in the following statement we set a hook to save the map every 1000 events processed
miner.setOnAfterEvent(new HookEventProcessing() {
	@Override
	public void trigger() {
		if (miner.getProcessedEvents() % 1000 == 0) {
			try {
				CNet model = miner.updateModel();
				
				// exports the model as cnet
				ExportCNet e = new ExportCNet();
				e.exportCNetToCNetFile(model, new File("output-" + miner.getProcessedEvents() +".cnet"));

				// export a simplified visualization of the cnet
				Dot dot = new CNetSimplifiedModelView(model);
				dot.exportToSvg(new File("output-" + miner.getProcessedEvents() +".svg"));
			} catch (IOException e) { }
		}
	}
});
		
// connects the miner to the actual source
XesSource source = ...
source.prepare();
source.getObservable().subscribe(miner);
```

## Scientific literature

The techniques implemented in this package are described in:

- [Control-flow Discovery from Event Streams](https://andrea.burattin.net/publications/2014-cec)  
A. Burattin, A. Sperduti, W. M. P. van der Aalst  
In *Proceedings of the Congress on Evolutionary Computation* (IEEE WCCI CEC 2014); Beijing, China; July 6-11, 2014.
- [Heuristics Miners for Streaming Event Data](https://andrea.burattin.net/publications/2012-corr-stream)  
A. Burattin, A. Sperduti, W. M. P. van der Aalst  
In *CoRR* abs/1212.6383, Dec. 2012.