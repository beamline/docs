## Dependency [![](https://jitpack.io/v/beamline/simulation-plg.svg)](https://jitpack.io/#beamline/simulation-plg)

To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the dependency:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>simulation-plg</artifactId>
    <version>master-SNAPSHOT</version>
</dependency>
```
See the [introduction page](index.md) for further instructions.


## Usage


This wrapper of the [PLG library](https://github.com/delas/plg) allows the generation of random processes as well as their simulation. Processes can also be imported and exported. The following snipped of code generates a random process and streams it:

```java linenums="1"
Process p = new Process("");
// randomization of the process with defatult parameters
ProcessGenerator.randomizeProcess(p, RandomizationConfiguration.BASIC_VALUES);

LogGenerator logGenerator = new LogGenerator(
	p, // simulate process p
	new SimulationConfiguration(100), // default simulation configuration to generte 100 traces
	new ProgressAdapter());
XLog log = logGenerator.generateLog();

// default xes log source generator
XesSource source = new XesLogSource(log);
source.prepare();
source.getObservable()
	.subscribe((t) -> { // simple consumer that just prints case id and activity name
		System.out.println(
			XConceptExtension.instance().extractName(t) + " - " +
			XConceptExtension.instance().extractName(t.get(0)));
	});	
```

## Scientific literature

The technique implemented in this package is described in:

* [PLG2: Multiperspective Process Randomization with Online and Offline Simulations](https://andrea.burattin.net/publications/2016-bpm-demo)  
Andrea Burattin  
In *Online Proceedings of the BPM Demo Track* 2016; Rio de Janeiro, Brasil; September, 18 2016; CEUR-WS.org 2016.

Other relevant publications:

* [PLG2: Multiperspective Processes Randomization and Simulation for Online and Offline Settings](http://arxiv.org/abs/1506.08415)  
Andrea Burattin  
In *CoRR* abs/1506.08415, Jun. 2015.
* [PLG: a Framework for the Generation of Business Process Models and their Execution Logs](http://andrea.burattin.net/publications/2010-bpi)  
Andrea Burattin and Alessandro Sperduti  
In *Proceedings of the 6th International Workshop on Business Process Intelligence* (BPI 2010); Stevens Institute of Technology; Hoboken, New Jersey, USA; September 13, [2010.10.1007/978-3-642-20511-8_20](http://dx.doi.org/10.1007/978-3-642-20511-8_20).

Further information are also availalbe at the [Wiki of the PLG project](https://github.com/delas/plg/wiki).
