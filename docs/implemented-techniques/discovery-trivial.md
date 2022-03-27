!!! bug "Old documentation - Content valid only for Beamline v. 0.1.0"
    The content of this page refers an old version of the library (0.1.0). The current version of Beamline uses completely different technology and thus the content migh be invalid.


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
TrivialDiscoveryMiner miner = new TrivialDiscoveryMiner();
miner.setMinDependency(0.99); // configures the dependency threshold for the miner

// in the following statement we set a hook to save the map every 1000 events processed
miner.setOnAfterEvent(new HookEventProcessing() {
	@Override
	public void trigger() {
		if (miner.getProcessedEvents() % 1000 == 0) {
			try {
				File f = new File("output_" + miner.getProcessedEvents() + ".svg");
				GraphvizResponse resp = miner.getLatestResponse();
				resp.generateDot().exportToSvg(f);
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

- [Process Mining Techniques in Business Environments](https://andrea.burattin.net/publications/monograph)  
A. Burattin  
Springer, 2015.