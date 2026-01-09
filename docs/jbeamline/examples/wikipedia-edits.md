# Wikipedia edits

All edits actions happening on Wikipedia are recorded and available as a stream of data (see <https://wikitech.wikimedia.org/wiki/Event_Platform/EventStreams> for further details). A possible way of process mine the stream of edits happening is by considering the page being edited as the instance of the editing process and the edit "action" as the actual activity name.

To achieve this goal we can write a new `BeamlineAbstractSource` that consumes the stream of edits and produces a stream of `BEvent`s that can then be forwarded to one of the miners. So we can first define our source as well as the set of websites we want to filter (in this case we will focus on edits happening on the English version of Wikipedia, i.e., `enwiki`):

```java
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
         String caseId = obj.getString("title");
         String activityName = obj.getString("type");
         
         if (processesToStream.contains(processName)) {
            // prepare the actual event
            try {
               buffer.add(BEvent.create(processName, caseId, activityName));
            } catch (EventException e) {
               e.printStackTrace();
            }
         }
      }
   }
});
source.open();
```

This code can be wrapped in a thread that executes all the time, and stores each event in a buffer for further dispatching:

```java
public class WikipediaEditSource extends BeamlineAbstractSource {

   private static final long serialVersionUID = 608025607423103621L;
   private static List<String> processesToStream = Arrays.asList("enwiki");

   public void run(SourceContext<BEvent> ctx) throws Exception {
      Queue<BEvent> buffer = new LinkedList<>();
      
      new Thread(new Runnable() {
         @Override
         public void run() {
            // code from previous listing
            // ...
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
```java
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env
   .addSource(new WikipediaEditSource())
   .keyBy(BEvent::getProcessName)
   .flatMap(new DirectlyFollowsDependencyDiscoveryMiner().setModelRefreshRate(10).setMinDependency(0))
   .addSink(new SinkFunction<ProcessMap>(){
      public void invoke(ProcessMap value, Context context) throws Exception {
         value.generateDot().exportToSvg(new File("src/main/resources/output/output.svg"));
      };
   });
env.execute();
```

After running the system for about a couple of minutes, the following map was produced:

<figure>
	
<svg width="347px" height="281px"
 viewBox="0.00 0.00 346.61 281.00" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<g id="graph0" class="graph" transform="scale(1.0 1.0) rotate(0.0) translate(4.0 277.0)">
<title>G</title>
<polygon fill="white" stroke="none" points="-4,4 -4,-277 342.612,-277 342.612,4 -4,4"/>
<!-- e9f086037&#45;f263&#45;4023&#45;a09a&#45;65194c88011b&#45;&gt;e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9 -->
<g id="e8f92521a&#45;e8ac&#45;46e8&#45;8224&#45;2d53af5a0b4e" class="edge"><title>e9f086037&#45;f263&#45;4023&#45;a09a&#45;65194c88011b&#45;&gt;e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9</title>
<path fill="none" stroke="#848688" stroke-width="1.14035" d="M83.612,-217.5C83.612,-217.5 50.9186,-198.498 40.612,-173 33.7832,-156.106 30.5244,-147.175 40.612,-132 53.606,-112.452 77.032,-101.473 98.5628,-95.3158"/>
<polygon fill="#848688" stroke="#848688" stroke-width="1.14035" points="99.0433,-96.9987 103.41,-93.9998 98.1262,-93.621 99.0433,-96.9987"/>
<text text-anchor="middle" x="58.612" y="-150.6" font-family="Arial" font-size="8.00"> 0.018 (3)</text>
</g>
<!-- e9f086037&#45;f263&#45;4023&#45;a09a&#45;65194c88011b&#45;&gt;eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce -->
<g id="ed987db2c&#45;2603&#45;403d&#45;a848&#45;66ccfc9e1557" class="edge"><title>e9f086037&#45;f263&#45;4023&#45;a09a&#45;65194c88011b&#45;&gt;eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce</title>
<path fill="none" stroke="#858789" stroke-width="1.04678" d="M83.612,-217.5C83.612,-217.5 71.5832,-194.543 80.612,-181 81.5759,-179.554 82.6319,-178.184 83.7668,-176.886"/>
<polygon fill="#858789" stroke="#858789" stroke-width="1.04678" points="85.1327,-177.993 87.3958,-173.203 82.6398,-175.536 85.1327,-177.993"/>
<text text-anchor="middle" x="100.612" y="-183.6" font-family="Arial" font-size="8.00"> 0.0058 (1)</text>
</g>
<!-- ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826&#45;&gt;e9f086037&#45;f263&#45;4023&#45;a09a&#45;65194c88011b -->
<g id="e0590e795&#45;48b7&#45;4755&#45;a73f&#45;06ad5de85bce" class="edge"><title>ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826&#45;&gt;e9f086037&#45;f263&#45;4023&#45;a09a&#45;65194c88011b</title>
<path fill="none" stroke="#858789" stroke-width="1.04678" d="M145.612,-21.5C145.612,-21.5 40.1738,-48.748 4.61196,-115 -11.3745,-144.783 18.7154,-174.962 46.2451,-194.784"/>
<polygon fill="#858789" stroke="#858789" stroke-width="1.04678" points="45.5384,-196.427 50.6341,-197.875 47.5537,-193.565 45.5384,-196.427"/>
<text text-anchor="middle" x="24.612" y="-117.6" font-family="Arial" font-size="8.00"> 0.0058 (1)</text>
</g>
<!-- ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826&#45;&gt;ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826 -->
<g id="e3af7cd2f&#45;ee0b&#45;4edc&#45;8ccf&#45;e87cb93316d8" class="edge"><title>ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826&#45;&gt;ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826</title>
<path fill="none" stroke="#727375" stroke-width="2.68421" d="M145.612,-20.5C165.945,-28.5 206.612,-28.5 206.612,-20.5 206.612,-17.6274 201.369,-15.7863 193.706,-14.9767"/>
<polygon fill="#727375" stroke="#727375" stroke-width="2.68421" points="193.763,-13.2262 188.648,-14.6058 193.507,-16.7168 193.763,-13.2262"/>
<text text-anchor="middle" x="224.612" y="-18.6" font-family="Arial" font-size="8.00"> 0.21 (36)</text>
</g>
<!-- ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826&#45;&gt;e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9 -->
<g id="e7023d429&#45;3b1b&#45;48b5&#45;a150&#45;b708eb371e2a" class="edge"><title>ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826&#45;&gt;e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9</title>
<path fill="none" stroke="#7c7e80" stroke-width="1.79532" d="M145.612,-21.5C145.612,-21.5 151.816,-36.3984 153.612,-49 154.162,-52.8626 154.062,-56.9369 153.588,-60.9074"/>
<polygon fill="#7c7e80" stroke="#7c7e80" stroke-width="1.79532" points="151.858,-60.646 152.808,-65.8575 155.315,-61.1907 151.858,-60.646"/>
<text text-anchor="middle" x="174.612" y="-51.6" font-family="Arial" font-size="8.00"> 0.099 (17)</text>
</g>
<!-- e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9&#45;&gt;ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826 -->
<g id="e5dd47088&#45;5df3&#45;49e6&#45;8c3f&#45;c907cd948c9c" class="edge"><title>e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9&#45;&gt;ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826</title>
<path fill="none" stroke="#818385" stroke-width="1.42105" d="M146.612,-85.5C146.612,-85.5 121.71,-75.2893 113.612,-58 111.608,-53.7215 112.016,-49.5664 113.877,-45.686"/>
<polygon fill="#818385" stroke="#818385" stroke-width="1.42105" points="115.478,-46.4275 116.67,-41.2658 112.52,-44.5577 115.478,-46.4275"/>
<text text-anchor="middle" x="131.612" y="-51.6" font-family="Arial" font-size="8.00"> 0.053 (9)</text>
</g>
<!-- e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9&#45;&gt;e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9 -->
<g id="e992962b7&#45;89cd&#45;4897&#45;82a7&#45;b935cb498248" class="edge"><title>e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9&#45;&gt;e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9</title>
<path fill="none" stroke="#313233" stroke-width="7.97076" d="M146.612,-86.5C166.945,-94.5 207.612,-94.5 207.612,-86.5 207.612,-83.6274 202.369,-81.7863 194.706,-80.9767"/>
<polygon fill="#313233" stroke="#313233" stroke-width="7.97076" points="194.89,-77.4936 189.648,-80.6058 194.38,-84.4494 194.89,-77.4936"/>
<text text-anchor="middle" x="227.612" y="-84.6" font-family="Arial" font-size="8.00"> 0.87 (149)</text>
</g>
<!-- eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce&#45;&gt;e9f086037&#45;f263&#45;4023&#45;a09a&#45;65194c88011b -->
<g id="ed2ee42a2&#45;4f99&#45;40ae&#45;83fd&#45;858b661044b8" class="edge"><title>eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce&#45;&gt;e9f086037&#45;f263&#45;4023&#45;a09a&#45;65194c88011b</title>
<path fill="none" stroke="#858789" stroke-width="1.04678" d="M146.612,-153.5C146.612,-153.5 137.677,-176.287 124.612,-190 123.149,-191.536 121.585,-193.032 119.954,-194.481"/>
<polygon fill="#858789" stroke="#858789" stroke-width="1.04678" points="118.74,-193.216 116.043,-197.775 120.995,-195.893 118.74,-193.216"/>
<text text-anchor="middle" x="151.612" y="-183.6" font-family="Arial" font-size="8.00"> 0.0058 (1)</text>
</g>
<!-- eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce&#45;&gt;e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9 -->
<g id="ef9820d3c&#45;5b53&#45;4baa&#45;af69&#45;79b8ba0a9b59" class="edge"><title>eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce&#45;&gt;e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9</title>
<path fill="none" stroke="#858789" stroke-width="1.04678" d="M146.612,-151.5C146.612,-151.5 146.612,-130.451 146.612,-112.496"/>
<polygon fill="#858789" stroke="#858789" stroke-width="1.04678" points="148.362,-112.05 146.612,-107.05 144.862,-112.05 148.362,-112.05"/>
<text text-anchor="middle" x="166.612" y="-117.6" font-family="Arial" font-size="8.00"> 0.0058 (1)</text>
</g>
<!-- eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce&#45;&gt;eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce -->
<g id="e5bea5029&#45;153b&#45;42ca&#45;8ef2&#45;f96d63c93ea5" class="edge"><title>eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce&#45;&gt;eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce</title>
<path fill="none" stroke="#252526" stroke-width="9" d="M146.612,-152.5C172.779,-160.5 225.112,-160.5 225.112,-152.5 225.112,-150.016 220.065,-148.303 212.322,-147.361"/>
<polygon fill="#252526" stroke="#252526" stroke-width="9" points="212.522,-143.425 207.173,-146.875 211.781,-151.265 212.522,-143.425"/>
<text text-anchor="middle" x="243.112" y="-150.6" font-family="Arial" font-size="8.00"> 1.0 (171)</text>
</g>
<!-- e5c219b19&#45;76ba&#45;4a89&#45;81e8&#45;472c2f157271&#45;&gt;e9f086037&#45;f263&#45;4023&#45;a09a&#45;65194c88011b -->
<g id="e4ac9e20c&#45;cfeb&#45;446f&#45;8126&#45;69be3c2e15f7" class="edge"><title>e5c219b19&#45;76ba&#45;4a89&#45;81e8&#45;472c2f157271&#45;&gt;e9f086037&#45;f263&#45;4023&#45;a09a&#45;65194c88011b</title>
<path fill="none" stroke="#acb89c" stroke-width="2" stroke-dasharray="5,2" d="M259.612,-267.5C259.612,-267.5 233.406,-261.484 212.612,-256 185.823,-248.935 156.056,-240.549 131.873,-233.598"/>
<polygon fill="#acb89c" stroke="#acb89c" stroke-width="2" points="132.089,-231.839 126.8,-232.137 131.121,-235.202 132.089,-231.839"/>
<text text-anchor="middle" x="214.112" y="-249.6" font-family="Arial" font-size="8.00"> </text>
</g>
<!-- e5c219b19&#45;76ba&#45;4a89&#45;81e8&#45;472c2f157271&#45;&gt;ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826 -->
<g id="ef14974f0&#45;6a88&#45;4e4c&#45;9c1c&#45;0f5327645ca4" class="edge"><title>e5c219b19&#45;76ba&#45;4a89&#45;81e8&#45;472c2f157271&#45;&gt;ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826</title>
<path fill="none" stroke="#acb89c" stroke-width="2" stroke-dasharray="5,2" d="M259.612,-267.5C259.612,-267.5 335.612,-259.451 335.612,-219.5 335.612,-219.5 335.612,-219.5 335.612,-85.5 335.612,-55.5981 250.028,-37.0052 193.739,-28.0103"/>
<polygon fill="#acb89c" stroke="#acb89c" stroke-width="2" points="193.937,-26.27 188.726,-27.2221 193.393,-29.7275 193.937,-26.27"/>
<text text-anchor="middle" x="337.112" y="-150.6" font-family="Arial" font-size="8.00"> </text>
</g>
<!-- e5c219b19&#45;76ba&#45;4a89&#45;81e8&#45;472c2f157271&#45;&gt;e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9 -->
<g id="ee95bf413&#45;0f3b&#45;42e1&#45;9904&#45;a75d0422b09d" class="edge"><title>e5c219b19&#45;76ba&#45;4a89&#45;81e8&#45;472c2f157271&#45;&gt;e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9</title>
<path fill="none" stroke="#acb89c" stroke-width="2" stroke-dasharray="5,2" d="M259.612,-267.5C259.612,-267.5 305.379,-181.415 270.612,-132 253.514,-107.698 221.835,-96.6014 194.778,-91.5656"/>
<polygon fill="#acb89c" stroke="#acb89c" stroke-width="2" points="195.011,-89.8298 189.785,-90.6941 194.409,-93.2777 195.011,-89.8298"/>
<text text-anchor="middle" x="284.112" y="-183.6" font-family="Arial" font-size="8.00"> </text>
</g>
<!-- e5c219b19&#45;76ba&#45;4a89&#45;81e8&#45;472c2f157271&#45;&gt;eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce -->
<g id="e5e2fbe2d&#45;0460&#45;4277&#45;a498&#45;1e6478a65845" class="edge"><title>e5c219b19&#45;76ba&#45;4a89&#45;81e8&#45;472c2f157271&#45;&gt;eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce</title>
<path fill="none" stroke="#acb89c" stroke-width="2" stroke-dasharray="5,2" d="M259.612,-267.5C259.612,-267.5 213.729,-218.667 175.612,-181 174.249,-179.653 172.842,-178.276 171.417,-176.892"/>
<polygon fill="#acb89c" stroke="#acb89c" stroke-width="2" points="172.432,-175.44 167.619,-173.226 170.001,-177.958 172.432,-175.44"/>
<text text-anchor="middle" x="234.112" y="-216.6" font-family="Arial" font-size="8.00"> </text>
</g>
<!-- e9f086037&#45;f263&#45;4023&#45;a09a&#45;65194c88011b -->
<g id="e9f086037&#45;f263&#45;4023&#45;a09a&#45;65194c88011b" class="node"><title>e9f086037&#45;f263&#45;4023&#45;a09a&#45;65194c88011b</title>
<path fill="#c8e7f6" stroke="black" d="M114.612,-239C114.612,-239 52.612,-239 52.612,-239 46.612,-239 40.612,-233 40.612,-227 40.612,-227 40.612,-210 40.612,-210 40.612,-204 46.612,-198 52.612,-198 52.612,-198 114.612,-198 114.612,-198 120.612,-198 126.612,-204 126.612,-210 126.612,-210 126.612,-227 126.612,-227 126.612,-233 120.612,-239 114.612,-239"/>
<text text-anchor="start" x="61.612" y="-218.4" font-family="Arial" font-size="22.00" fill="#000000">new</text>
<text text-anchor="start" x="101.612" y="-218.4" font-family="Arial" font-size="14.00" fill="#000000"> </text>
<text text-anchor="start" x="58.612" y="-205.2" font-family="Arial" font-size="11.00" fill="#000000">0.035 (34)</text>
</g>
<!-- ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826 -->
<g id="ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826" class="node"><title>ecdf5f385&#45;1425&#45;4bad&#45;8feb&#45;175f435d6826</title>
<path fill="#b6d8ea" stroke="black" d="M176.612,-41C176.612,-41 114.612,-41 114.612,-41 108.612,-41 102.612,-35 102.612,-29 102.612,-29 102.612,-12 102.612,-12 102.612,-6 108.612,-0 114.612,-0 114.612,-0 176.612,-0 176.612,-0 182.612,-0 188.612,-6 188.612,-12 188.612,-12 188.612,-29 188.612,-29 188.612,-35 182.612,-41 176.612,-41"/>
<text text-anchor="start" x="128.612" y="-20.4" font-family="Arial" font-size="22.00" fill="#000000">log</text>
<text text-anchor="start" x="158.612" y="-20.4" font-family="Arial" font-size="14.00" fill="#000000"> </text>
<text text-anchor="start" x="120.612" y="-7.2" font-family="Arial" font-size="11.00" fill="#000000">0.13 (121)</text>
</g>
<!-- e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9 -->
<g id="e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9" class="node"><title>e0615c600&#45;1e15&#45;47f0&#45;94f6&#45;9ce57be6cab9</title>
<path fill="#0b4971" stroke="black" d="M177.612,-107C177.612,-107 115.612,-107 115.612,-107 109.612,-107 103.612,-101 103.612,-95 103.612,-95 103.612,-78 103.612,-78 103.612,-72 109.612,-66 115.612,-66 115.612,-66 177.612,-66 177.612,-66 183.612,-66 189.612,-72 189.612,-78 189.612,-78 189.612,-95 189.612,-95 189.612,-101 183.612,-107 177.612,-107"/>
<text text-anchor="start" x="126.612" y="-86.4" font-family="Arial" font-size="22.00" fill="#ffffff">edit</text>
<text text-anchor="start" x="162.612" y="-86.4" font-family="Arial" font-size="14.00" fill="#ffffff"> </text>
<text text-anchor="start" x="124.612" y="-73.2" font-family="Arial" font-size="11.00" fill="#ffffff">1.0 (963)</text>
</g>
<!-- eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce -->
<g id="eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce" class="node"><title>eb542aaf4&#45;fda2&#45;48c0&#45;96c2&#45;b404ab6e59ce</title>
<path fill="#7ba7c0" stroke="black" d="M195.112,-173C195.112,-173 98.112,-173 98.112,-173 92.112,-173 86.112,-167 86.112,-161 86.112,-161 86.112,-144 86.112,-144 86.112,-138 92.112,-132 98.112,-132 98.112,-132 195.112,-132 195.112,-132 201.112,-132 207.112,-138 207.112,-144 207.112,-144 207.112,-161 207.112,-161 207.112,-167 201.112,-173 195.112,-173"/>
<text text-anchor="start" x="94.112" y="-152.4" font-family="Arial" font-size="22.00" fill="#000000">categorize</text>
<text text-anchor="start" x="195.112" y="-152.4" font-family="Arial" font-size="14.00" fill="#000000"> </text>
<text text-anchor="start" x="121.612" y="-139.2" font-family="Arial" font-size="11.00" fill="#000000">0.43 (412)</text>
</g>
<!-- e5c219b19&#45;76ba&#45;4a89&#45;81e8&#45;472c2f157271 -->
<g id="e5c219b19&#45;76ba&#45;4a89&#45;81e8&#45;472c2f157271" class="node"><title>e5c219b19&#45;76ba&#45;4a89&#45;81e8&#45;472c2f157271</title>
<ellipse fill="#ced6bd" stroke="#595f45" cx="259.612" cy="-268.5" rx="4.5" ry="4.5"/>
</g>
</g>
</svg>

</figure>

The complete code of this example is available in the GitHub repository <https://github.com/beamline/examples/tree/master/src/main/java/beamline/examples/wikipedia>.
