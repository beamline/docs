[OpenSky Network](https://opensky-network.org/) is a non profit project which
> [...] consists of a multitude of sensors connected to the Internet by volunteers, industrial supporters, and academic/governmental organizations. All collected raw data is archived in a large historical database. The database is primarily used by researchers from different areas to analyze and improve air traffic control technologies and processes.

> -- Description from <https://opensky-network.org/about/about-us>

Essentially, each airplane uses a transponder to [transmit data regarding their status (squawk)](https://en.wikipedia.org/wiki/Transponder_(aeronautics)) as well as their [callsign](https://en.wikipedia.org/wiki/Aviation_call_signs) and current position. All this information is collected by OpenSky Network and made available though [their APIs](https://openskynetwork.github.io/opensky-api/).

The underlying idea of this example is that each flight (i.e., an airplane callsign) represents the instance of a flight process. The different squawks a plane goes through indicate the activities involved in the process.

To achieve this goal, it is necessary to write a new source which periodically queries the OpenSky Network APIs to retrieve the live status of airplanes in a certain area. First it's necessary to create the actual source and initialize the `OpenSkyApi` wrapper:
```java linenums="1"
public class OpenSkySource extends BeamlineAbstractSource {
	private OpenSkyApi api;

	@Override
	public void open(Configuration parameters) throws Exception {
		Properties prop = new Properties();
		prop.load(new FileInputStream("./openskyCredentials.properties"));
		api = new OpenSkyApi(prop.getProperty("USERNAME"), prop.getProperty("PASSWORD"));
	}
```
Please note that in this case we use the [Java API](https://openskynetwork.github.io/opensky-api/java.html) (imported from [JitPack](https://jitpack.io/#openskynetwork/opensky-api)) and we assume the presence of a file `openskyCredentials.properties` containing username and password for accessing the APIs.

Once the system is properly connected to the APIs, then in the `run` method it is possible to define a separate thread in charge of querying the APIs every 15 seconds and put the events into a buffer which is then used for dispatching them. In the case highlighted the APIs are queried to retrieve flights over the central Europe (lines 19-20). In addition the squawks are parsed to provide some more understandable interpretation (according to the interpretation reported here <https://www.flightradars.eu/squawkcodes.html>, the actual code of method `squawkToString` is omitted in this page but is available on the GitHub repository).

```java linenums="10"
	@Override
	public void run(SourceContext<BEvent> ctx) throws Exception {
		Queue<BEvent> buffer = new LinkedList<>();
		
		new Thread(() -> {
			while(isRunning()) {
				try {
					OpenSkyStates os = api.getStates(0, null,
						new OpenSkyApi.BoundingBox(
							35.0518857, 62.4097744,
							-5.8468354, 34.3186395));
					if (os != null) {
						for (StateVector sv : os.getStates()) {
							try {
								if (!sv.getCallsign().isBlank()) {
									buffer.add(
										BEvent.create(
											"squawk",
											sv.getCallsign().trim(),
											squawkToString(sv.getSquawk())));
								}
							} catch (EventException e) {
								e.printStackTrace();
							}
						}
					} else {
						System.out.println("No new information...");
					}
					Thread.sleep(15000l);
				} catch (Exception e) {
					// nothing to see here
					e.printStackTrace();
				}
			}
		}).start();
		
		while(isRunning()) {
			while (isRunning() && buffer.isEmpty()) {
				Thread.sleep(100l);
			}
			if (isRunning()) {
				synchronized (ctx.getCheckpointLock()) {
					BEvent e = buffer.poll();
					ctx.collect(e);
				}
			}
		}
	}
}
```

A simple consumer, in this case the [Trivial discovery miner](../implemented-techniques/discovery-trivial.md), can then be attached to the source with:
```java linenums="1"
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env
   .addSource(new OpenSkySource())
   .keyBy(BEvent::getProcessName)
   .flatMap(new DirectlyFollowsDependencyDiscoveryMiner().setModelRefreshRate(10).setMinDependency(0))
   .addSink(new SinkFunction<ProcessMap>(){
      public void invoke(ProcessMap value, Context context) throws Exception {
         value.generateDot().exportToSvg(new File("src/main/resources/output/output.svg"));
      };
   });
env.execute();
```

After running the system for about a few minutes, the following map was produced, where essentially only transit squawks were observed:
<figure>
	<svg width="151px" height="49px"
	 viewBox="0.00 0.00 151.00 49.00" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
	<g id="graph0" class="graph" transform="scale(1.0 1.0) rotate(0.0) translate(4.0 45.0)">
	<title>G</title>
	<polygon fill="white" stroke="none" points="-4,4 -4,-45 147,-45 147,4 -4,4"/>
	<!-- eec7010c0&#45;450a&#45;418f&#45;b0be&#45;fa2d42391974&#45;&gt;eec7010c0&#45;450a&#45;418f&#45;b0be&#45;fa2d42391974 -->
	<g id="edf895cb3&#45;0f3c&#45;498f&#45;8d20&#45;eecc3a555b0a" class="edge"><title>eec7010c0&#45;450a&#45;418f&#45;b0be&#45;fa2d42391974&#45;&gt;eec7010c0&#45;450a&#45;418f&#45;b0be&#45;fa2d42391974</title>
	<path fill="none" stroke="#252526" stroke-width="9" d="M44.5,-20.5C65.3333,-30.5 107,-30.5 107,-20.5 107,-16.974 101.82,-14.6913 94.199,-13.6518"/>
	<polygon fill="#252526" stroke="#252526" stroke-width="9" points="94.5187,-9.72694 89.1631,-13.1653 93.7612,-17.5654 94.5187,-9.72694"/>
	<text text-anchor="middle" x="125" y="-18.6" font-family="Arial" font-size="8.00"> 1.0 (334)</text>
	</g>
	<!-- eec7010c0&#45;450a&#45;418f&#45;b0be&#45;fa2d42391974 -->
	<g id="eec7010c0&#45;450a&#45;418f&#45;b0be&#45;fa2d42391974" class="node"><title>eec7010c0&#45;450a&#45;418f&#45;b0be&#45;fa2d42391974</title>
	<path fill="#0b4971" stroke="black" d="M77,-41C77,-41 12,-41 12,-41 6,-41 0,-35 0,-29 0,-29 0,-12 0,-12 0,-6 6,-0 12,-0 12,-0 77,-0 77,-0 83,-0 89,-6 89,-12 89,-12 89,-29 89,-29 89,-35 83,-41 77,-41"/>
	<text text-anchor="start" x="8" y="-20.4" font-family="Arial" font-size="22.00" fill="#ffffff">Transit</text>
	<text text-anchor="start" x="77" y="-20.4" font-family="Arial" font-size="14.00" fill="#ffffff"> </text>
	<text text-anchor="start" x="22.5" y="-7.2" font-family="Arial" font-size="11.00" fill="#ffffff">1.0 (359)</text>
	</g>
	</g>
	</svg>
</figure>

The complete code of this example is available in the GitHub repository <https://github.com/beamline/examples/tree/master/src/main/java/beamline/examples/opensky>.

## Scientific literature

- [Bringing Up OpenSky: A Large-scale ADS-B Sensor Network for Research](https://doi.org/10.1109/IPSN.2014.6846743).   
Matthias Schäfer, Martin Strohmeier, Vincent Lenders, Ivan Martinovic and Matthias Wilhelm.   
In *Proceedings of the 13th IEEE/ACM International Symposium on Information Processing in Sensor Networks* (IPSN), pages 83-94, April 2014.
