This page lists the streaming process mining techniques currently implemented in the Beamline Framework.
To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the package repository:
```xml
<repositories>
    <repository>
        <id>jitpack.io</id>
        <url>https://jitpack.io</url>
    </repository>
</repositories>
```
See <https://jitpack.io/#beamline/discovery-algorithms> for further details (e.g., using it with Gradle).


## Control flow discovery

Then you can include the dependency to the version you are interested, for example:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>discovery-algorithms</artifactId>
    <version>0.0.1</version>
</dependency>
```


### Imperative models

TBA


### Declarative models

Discovery of Declare models, using the techniques described in:

- [Online Discovery of Declarative Process Models from Event Streams](https://andrea.burattin.net/publications/2015-tsc)  
A. Burattin, M. Cimitile, F. Maggi, A. Sperduti  
In IEEE Transactions on Services Computing, vol. 8 (2015), no. 6, pp. 833-846.

Specifically, it is possible to call the two miners `beamline.miners.declare.DeclareMinerLossyCounting` and `beamline.miners.declare.DeclareMinerBudgetLossyCounting` using the following:

```java
new DeclareMinerLossyCounting(
	0.001, // the maximal approximation error
	10 // the number of declare constraints to show
);
```
```java
new DeclareMinerBudgetLossyCounting(
	1000, // the available budget
	10 // the number of declare constraints to show
);
```


## Conformance checking

To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the package the dependency to the version you are interested, for example:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>conformance-algorithms</artifactId>
    <version>0.0.1</version>
</dependency>
```

The conformance checking currently implemented in Beamline is described in:

- [Online Conformance Checking Using Behavioural Patterns](https://andrea.burattin.net/publications/2018-bpm)  
A. Burattin, S. van Zelst, A. Armas-Cervantes, B. van Dongen, J. Carmona  
In Proceedings of BPM 2018; Sydney, Australia; September 2018.

To use the technique you need to create the conformance checker object using:

```java
SimpleConformance conformance = new SimpleConformance();
conformance.loadModel(new File("reference-model.tpn"));

conformance.setOnAfterEvent(new HookEventProcessing() {
	@Override
	public void trigger() {
		System.out.println(miner.getLatestResponse());
	}
});
```

In the current version, the reference model must be expressed as a Petri Net stored in TPN format. Additionally, in this version, the response is expressed as a `Pair<Integer, String>` object, where the first component is the cost of the execution of the current event (0 means the event was compliant, > 0 means the process was not compliant). The code above will print, after each event, the cost of the corresponding replay.

In order to properly pre-process the Petri net, it is necessary to set up a [property file](https://en.wikipedia.org/wiki/.properties) called `javaOfflinePreProcessor.properties` with the following content:

```properties
JAVA_BIN = FULL_PATH_OF_THE_JAVA_EXECUTABLE
OFFLINE_PREPROCESSOR_JAR = FULL_PATH_OF_THE_PREPROCESSOR
```