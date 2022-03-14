All edits actions happening on Wikipedia are recorded and available as a stream of data (see <https://wikitech.wikimedia.org/wiki/Event_Platform/EventStreams> for further details). A possible way of process mine the stream of edits happening is by considering the page being edited as the instance of the editing process and the edit "action" as the actual activity name.

To achieve this goal we can write a new `XesSource` that consumes the stream of edits and produces a stream of `XTrace`s that can then be forwarded to one of the miners. So we can first define our source as well as the set of websites we want to filter (in this case we will focus on edits happening on the English version of Wikipedia, i.e., `enwiki`):

```java
Subject<XTrace> ps = PublishSubject.create();
List<String> processesToStream = Arrays.asList("enwiki");
```

After then we can write the code to transform the JSON produced by the Wikipedia stream into a stream of `XTrace`s. 

```java
Client client = ClientBuilder.newClient();
WebTarget target = client.target("https://stream.wikimedia.org/v2/stream/recentchange");
SseEventSource source = SseEventSource.target(target).reconnectingEvery(5, TimeUnit.SECONDS).build();
source.register(new Consumer<InboundSseEvent>() {
	@Override
	public void accept(InboundSseEvent t) {
		String data = t.readData();
		if (data != null) {
			JSONObject obj = new JSONObject(data);
			
			String processName = obj.getString("wiki");
			String caseId = DigestUtils.md5Hex(obj.getString("title"));
			String activityName = obj.getString("type");
			
			if (processesToStream.contains(processName)) {
				// prepare the actual event
				XEvent event = xesFactory.createEvent();
				XConceptExtension.instance().assignName(event, activityName);
				XTimeExtension.instance().assignTimestamp(event, new Date());
				XTrace eventWrapper = xesFactory.createTrace();
				XConceptExtension.instance().assignName(eventWrapper, caseId);
				eventWrapper.add(event);
				ps.onNext(eventWrapper);
			}
		}
	}
});
source.open();
```

This code can be wrapped in a thread that executes all the time, as soon as the source is `prepare`d. Also, the code can be added 

```java
public class WikipediaEditSource implements XesSource {

	private static final XFactory xesFactory = new XFactoryNaiveImpl();
	private static List<String> processesToStream = Arrays.asList("enwiki");
	private Subject<XTrace> ps;
	
	public WikipediaEditSource() {
		this.ps = PublishSubject.create();
	}
	
	@Override
	public Observable<XTrace> getObservable() {
		return ps;
	}

	@Override
	public void prepare() throws Exception {
		new Thread(new Runnable() {
			@Override
			public void run() {
				// code from previous listing
				// ...
			}
		}).start();
	}
}
```

A simple consumer, in this case the [Trivial discovery miner](../implemented-techniques/discovery-trivial.md), can then be attached to the source with:
```java
TrivialDiscoveryMiner miner = new TrivialDiscoveryMiner();
miner.setModelRefreshRate(1);
miner.setMinDependency(0);

miner.setOnAfterEvent(() -> {
	if (miner.getProcessedEvents() % 50 == 0) {
		try {
			File f = new File("src/main/resources/output/output.svg");
			miner.getLatestResponse().generateDot().exportToSvg(f);
		} catch (IOException e) { }
	}
});

// connects the miner to the actual source
XesSource source = new WikipediaEditSource();
source.prepare();
source.getObservable().subscribe(miner);
```

After running the system for about 10 minutes, the following map was produced:

<figure>
	<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="421px"
   height="196px"
   viewBox="0.00 0.00 421.00 196.00"
   version="1.1"
   id="svg150"
   sodipodi:docname="output.svg"
   inkscape:version="0.92.1 r15371">
  <metadata
     id="metadata156">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <defs
     id="defs154" />
  <sodipodi:namedview
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1"
     objecttolerance="10"
     gridtolerance="10"
     guidetolerance="10"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:window-width="1920"
     inkscape:window-height="1147"
     id="namedview152"
     showgrid="false"
     inkscape:zoom="1.4916865"
     inkscape:cx="125.58106"
     inkscape:cy="164.23777"
     inkscape:window-x="-8"
     inkscape:window-y="-8"
     inkscape:window-maximized="1"
     inkscape:current-layer="svg150" />
  <path
     d="m 214,27 c 20.333,-8.5 61,-8.5 61,0 0,3.052 -5.243,5.008 -12.906,5.869"
     id="path8"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#838587;stroke-width:1.27039003" />
  <polygon
     points="253.036,-158.737 257.885,-160.871 258.157,-157.381 "
     id="polygon10"
     style="fill:#838587;stroke:#838587;stroke-width:1.27039003"
     transform="translate(4,192)" />
  <text
     x="286.5"
     y="28.899994"
     font-size="8.00"
     id="text12"
     style="font-size:8px;font-family:Arial;text-anchor:middle">0.034</text>
  <path
     d="m 214,28 c 0,0 -58.724,11.024 -102,30 -9.0506,3.969 -18.3844,8.965 -27.0566,14.044"
     id="path17"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#86888a;stroke-width:1.00437999" />
  <polygon
     points="76.1996,-117.132 79.6005,-121.193 81.3911,-118.186 "
     id="polygon19"
     style="fill:#86888a;stroke:#86888a;stroke-width:1.00437999"
     transform="translate(4,192)" />
  <text
     x="128"
     y="64.400002"
     font-size="8.00"
     id="text21"
     style="font-size:8px;font-family:Arial;text-anchor:middle">0.00055</text>
  <path
     d="m 214,28 c 0,0 -31.228,22.021 -47,47 -12.792,20.2592 -21.456,46.1382 -26.684,65.4507"
     id="path26"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#86888a;stroke-width:1.00117004" />
  <polygon
     points="134.931,-46.2865 134.511,-51.5672 137.896,-50.6768 "
     id="polygon28"
     style="fill:#86888a;stroke:#86888a;stroke-width:1.00117004"
     transform="translate(4,192)" />
  <text
     x="183"
     y="99.900002"
     font-size="8.00"
     id="text30"
     style="font-size:8px;font-family:Arial;text-anchor:middle">0.00015</text>
  <path
     d="m 230,28 c 0,0 -12.038,24.15 -3,39 0.884,1.453 1.864,2.838 2.925,4.159"
     id="path35"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#86888a;stroke-width:1.00088" />
  <polygon
     points="211.281,-121.95 213.337,-117.068 208.685,-119.602 "
     id="polygon37"
     style="fill:#86888a;stroke:#86888a;stroke-width:1.00088"
     transform="translate(20,192)" />
  <text
     x="243"
     y="64.400002"
     font-size="8.00"
     id="text39"
     style="font-size:8px;font-family:Arial;text-anchor:middle">0.00011</text>
  <path
     d="m 47,98 c 20.3333,-8.5 61,-8.5 61,0 0,3.0521 -5.2432,5.0083 -12.9056,5.8685"
     id="path44"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#252526;stroke-width:9" />
  <polygon
     points="86.0361,-87.7374 90.7152,-92.0514 91.3269,-84.2002 "
     id="polygon46"
     style="fill:#252526;stroke:#252526;stroke-width:9"
     transform="translate(4,192)" />
  <text
     x="115"
     y="99.900002"
     font-size="8.00"
     id="text48"
     style="font-size:8px;font-family:Arial;text-anchor:middle">1.0</text>
  <path
     d="m 47,99 c 0,0 -4.2748,25.4722 7,39 8.2163,9.8581 20.0161,16.4794 32.0389,20.9258"
     id="path53"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#86888a;stroke-width:1.00934005" />
  <polygon
     points="86.8306,-31.416 81.5332,-31.3974 82.6779,-34.705 "
     id="polygon55"
     style="fill:#86888a;stroke:#86888a;stroke-width:1.00934005"
     transform="translate(4,192)" />
  <text
     x="68"
     y="135.39999"
     font-size="8.00"
     id="text57"
     style="font-size:8px;font-family:Arial;text-anchor:middle">0.0012</text>
  <path
     d="m 134,168 c 0,0 207.151,-4.7312 242,-47 13.006,-15.7744 12.278,-29.653 0,-46 C 362.268,56.718 305.014,43.252 262.441,35.529"
     id="path62"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#86888a;stroke-width:1.00292003" />
  <polygon
     points="253.326,-157.384 258.556,-158.228 257.941,-154.783 "
     id="polygon64"
     style="fill:#86888a;stroke:#86888a;stroke-width:1.00292003"
     transform="translate(4,192)" />
  <text
     x="401"
     y="99.900002"
     font-size="8.00"
     id="text66"
     style="font-size:8px;font-family:Arial;text-anchor:middle">0.00037</text>
  <path
     d="m 134,168 c 0,0 -30.2389,-23.9826 -55.0618,-43.6697"
     id="path71"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#86888a;stroke-width:1.01810002" />
  <polygon
     points="71.0062,-70.7882 76.0112,-69.0523 73.8363,-66.31 "
     id="polygon73"
     style="fill:#86888a;stroke:#86888a;stroke-width:1.01810002"
     transform="translate(4,192)" />
  <text
     x="110"
     y="135.39999"
     font-size="8.00"
     id="text75"
     style="font-size:8px;font-family:Arial;text-anchor:middle">0.0023</text>
  <path
     d="m 134,169 c 20.333,-8.5 61,-8.5 61,0 0,3.0521 -5.243,5.0083 -12.906,5.8685"
     id="path80"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#7e8082;stroke-width:1.65992999" />
  <polygon
     points="173.036,-16.7374 177.885,-18.8706 178.157,-15.3811 "
     id="polygon82"
     style="fill:#7e8082;stroke:#7e8082;stroke-width:1.65992999"
     transform="translate(4,192)" />
  <text
     x="206.5"
     y="170.89999"
     font-size="8.00"
     id="text84"
     style="font-size:8px;font-family:Arial;text-anchor:middle">0.082</text>
  <path
     d="m 269,98 c 26.167,-8.5 78.5,-8.5 78.5,0 0,2.6396 -5.047,4.4596 -12.79,5.4597"
     id="path98"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#444546;stroke-width:6.42278004" />
  <polygon
     points="325.562,-88.0234 330.256,-91.3188 330.817,-85.727 "
     id="polygon100"
     style="fill:#444546;stroke:#444546;stroke-width:6.42278004"
     transform="translate(4,192)" />
  <text
     x="357"
     y="99.900002"
     font-size="8.00"
     id="text102"
     style="font-size:8px;font-family:Arial;text-anchor:middle">0.68</text>
  <path
     d="m 245,4 c 0,0 -62,0 -62,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 62,0 62,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12"
     id="path107"
     inkscape:connector-curvature="0"
     style="fill:#c8e7f6;stroke:#000000" />
  <text
     x="192"
     y="24.600006"
     font-size="22.00"
     id="text109"
     style="font-size:22px;font-family:Arial;text-anchor:start;fill:#000000">new</text>
  <text
     x="232"
     y="24.600006"
     font-size="14.00"
     id="text111"
     style="font-size:14px;font-family:Arial;text-anchor:start;fill:#000000" />
  <text
     x="193.5"
     y="41.800003"
     font-size="16.00"
     id="text113"
     style="font-size:16px;font-family:Arial;text-anchor:start;fill:#000000">0.034</text>
  <path
     d="m 78,75 c 0,0 -62,0 -62,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 62,0 62,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12"
     id="path118"
     inkscape:connector-curvature="0"
     style="fill:#0b4971;stroke:#000000" />
  <text
     x="27"
     y="95.599998"
     font-size="22.00"
     id="text120"
     style="font-size:22px;font-family:Arial;text-anchor:start;fill:#ffffff">edit</text>
  <text
     x="63"
     y="95.599998"
     font-size="14.00"
     id="text122"
     style="font-size:14px;font-family:Arial;text-anchor:start;fill:#ffffff" />
  <text
     x="35.5"
     y="112.8"
     font-size="16.00"
     id="text124"
     style="font-size:16px;font-family:Arial;text-anchor:start;fill:#ffffff">1.0</text>
  <path
     d="m 165,146 c 0,0 -62,0 -62,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 62,0 62,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12"
     id="path129"
     inkscape:connector-curvature="0"
     style="fill:#bfdff0;stroke:#000000" />
  <text
     x="117"
     y="166.60001"
     font-size="22.00"
     id="text131"
     style="font-size:22px;font-family:Arial;text-anchor:start;fill:#000000">log</text>
  <text
     x="147"
     y="166.60001"
     font-size="14.00"
     id="text133"
     style="font-size:14px;font-family:Arial;text-anchor:start;fill:#000000" />
  <text
     x="113.5"
     y="183.8"
     font-size="16.00"
     id="text135"
     style="font-size:16px;font-family:Arial;text-anchor:start;fill:#000000">0.083</text>
  <path
     d="m 317.5,75 c 0,0 -97,0 -97,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 97,0 97,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12"
     id="path140"
     inkscape:connector-curvature="0"
     style="fill:#5083a2;stroke:#000000" />
  <text
     x="216.5"
     y="95.599998"
     font-size="22.00"
     id="text142"
     style="font-size:22px;font-family:Arial;text-anchor:start;fill:#ffffff">categorize</text>
  <text
     x="317.5"
     y="95.599998"
     font-size="14.00"
     id="text144"
     style="font-size:14px;font-family:Arial;text-anchor:start;fill:#ffffff" />
  <text
     x="253"
     y="112.8"
     font-size="16.00"
     id="text146"
     style="font-size:16px;font-family:Arial;text-anchor:start;fill:#ffffff">0.65</text>
	</svg>
</figure>

The complete code of this example is available in the GitHub repository <https://github.com/beamline/examples/tree/master/src/main/java/beamline/examples/wikipedia>.
