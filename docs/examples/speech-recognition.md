In this example, we are going to explore a possible usage of streaming process mining in the context of speech recognition: each word a person is saying can be recognized as an activity and the sentences these words belong to can be the process instances. Every time a person waits a considerable amount of time between words, we can assume a new sentence is being said and thus a new case should be generated.

To accomplish our goal we need to define a new `XesStream` which can listen to the microphone, perform the speech recognition, and generate corresponding events. For the speech recognition we are going to use the [Vosk speech recognition toolkit](https://alphacephei.com/vosk/). We also going to use the [`vosk-model-small-en-us-0.15` model](https://alphacephei.com/vosk/models) which is available on the library website.

First we need to setup the Maven dependencies by setting them in the `pom.xml` file:
```xml
<dependency>
   <groupId>com.alphacephei</groupId>
   <artifactId>vosk</artifactId>
   <version>0.3.33</version>
</dependency>
<dependency>
   <groupId>org.json</groupId>
   <artifactId>json</artifactId>
   <version>20211205</version>
</dependency>
```

Then, once the model folder is properly set, we can configure the source `SpeechRecognizerSource`. The main idea is to construct a new thread which remains listening for speech and translates it to a string. this has to be inserted into a (potentially never-ending) loop. Within the loop, we can extract the array of all words said until now with:

```java
// getPartialResult returns a json object that we convert into its only string object
String text = (String) new JSONObject(recognizer.getPartialResult()).get("partial");
if (text.isEmpty()) {
   // if the text is empty we can skip this round
   continue;
}
// split the sentence into the individual words
String[] words = text.split(" ");
```

After the new words being said are identified (code not reported here), it is possible to construct the event with:
```java
// processing new case ids
if (lastWordMillisecs + MILLISECS_FOR_NEW_CASE < System.currentTimeMillis()) {
   caseId++;
}
lastWordMillisecs = System.currentTimeMillis();

// prepare the actual event
XEvent event = xesFactory.createEvent();
XConceptExtension.instance().assignName(event, word);
XTimeExtension.instance().assignTimestamp(event, new Date());
XTrace eventWrapper = xesFactory.createTrace();
XConceptExtension.instance().assignName(eventWrapper, "case-" + caseId);
eventWrapper.add(event);
ps.onNext(eventWrapper);
```

Where `ps` is a subject created with :
```java
Subject<XTrace> ps = PublishSubject.create();
```
and `MILLISECS_FOR_NEW_CASE` is a `long` indicating how many milliseconds separate each sentence (and hence creates a new case identifier).

A simple consumer, in this case the [Trivial discovery miner](../implemented-techniques/discovery-trivial.md), can then be attached to the source with:
```java
TrivialDiscoveryMiner miner = new TrivialDiscoveryMiner();
miner.setModelRefreshRate(1);
miner.setMinDependency(0);

// in the following statement we set a hook to save the map every 1000 events processed
miner.setOnAfterEvent(() -> {
   if (miner.getProcessedEvents() % 5 == 0) {
      try {
         File f = new File("src/main/resources/output/output.svg");
         miner.getLatestResponse().generateDot().exportToSvg(f);
      } catch (IOException e) { }
   }
});

// connects the miner to the actual source
XesSource source = new SpeechRecognizerSource();
source.prepare();
source.getObservable().subscribe(miner);
```

In the following example, I tested the system saying two sentences: 

- *"hello my name is peter"*
- *"good morning my name is bob"*

The result of the processing is shown below:
<figure>
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="266px"
   height="390px"
   viewBox="0.00 0.00 266.00 390.00"
   version="1.1"
   id="svg176"
   sodipodi:docname="output.svg"
   inkscape:version="0.92.1 r15371">
  <metadata
     id="metadata182">
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
     id="defs180" />
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
     id="namedview178"
     showgrid="false"
     inkscape:zoom="1.711561"
     inkscape:cx="16.097986"
     inkscape:cy="205.43612"
     inkscape:window-x="1912"
     inkscape:window-y="-8"
     inkscape:window-maximized="1"
     inkscape:current-layer="svg176" />
  <g
     class="edge"
     id="eb2e4d85d-eae2-4ccf-a5f4-ad7c010370ff"
     transform="translate(4,386)">
    <title
       id="title6">ed02a384a-6632-421f-a0d3-f285208ad433-&gt;ed5e65ef0-3332-49ef-a154-dcc56b4bb259</title>
    <path
       style="fill:none;stroke:#c2b0ab;stroke-width:2;stroke-dasharray:5, 2"
       inkscape:connector-curvature="0"
       id="path8"
       d="m 86,-48 c 0,0 36.999,25.7781 53.367,37.1818" />
    <polygon
       style="fill:#c2b0ab;stroke:#c2b0ab;stroke-width:2"
       id="polygon10"
       points="138.617,-9.20743 140.618,-12.0792 143.72,-7.78498 " />
  </g>
  <g
     class="edge"
     id="e7d9f6164-e823-4e02-ae8d-6826267f9391"
     transform="translate(4,386)">
    <title
       id="title13">e42f106f3-0f3a-4c6d-badb-a136c2804361-&gt;ed5e65ef0-3332-49ef-a154-dcc56b4bb259</title>
    <path
       style="fill:none;stroke:#c2b0ab;stroke-width:2;stroke-dasharray:5, 2"
       inkscape:connector-curvature="0"
       id="path15"
       d="m 190,-48 c 0,0 -24.282,23.9997 -36.352,35.9293" />
    <polygon
       style="fill:#c2b0ab;stroke:#c2b0ab;stroke-width:2"
       id="polygon17"
       points="152.147,-13.048 154.608,-10.5587 149.821,-8.28854 " />
  </g>
  <g
     class="edge"
     id="ec9a00112-afc7-40dc-bed4-aa76274d4e54"
     transform="translate(4,386)">
    <title
       id="title20">e87219b72-6a16-4a85-95d7-9490a133978d-&gt;eb23e774d-b7bb-4a99-9442-5dd0552282dc</title>
    <path
       style="fill:none;stroke:#565758;stroke-width:5"
       inkscape:connector-curvature="0"
       id="path22"
       d="m 77,-332 c 0,0 15.0038,23.006 27.684,42.449" />
    <polygon
       style="fill:#565758;stroke:#565758;stroke-width:5"
       id="polygon24"
       points="102.95,-288.205 106.615,-290.595 107.514,-285.212 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text26"
       font-size="8.00"
       y="-295.60001"
       x="112.5">0.50</text>
  </g>
  <g
     class="edge"
     id="e7df3cdae-88a6-4124-9bcb-20b3f1b8d328"
     transform="translate(4,386)">
    <title
       id="title29">ed2c17168-7e10-4975-a1f3-58afe71e03e1-&gt;e1f5b79b5-767d-45c9-a8ff-8e0a7d51e778</title>
    <path
       style="fill:none;stroke:#252526;stroke-width:9"
       inkscape:connector-curvature="0"
       id="path31"
       d="m 122,-190 c 0,0 0,22.239 0,41.466" />
    <polygon
       style="fill:#252526;stroke:#252526;stroke-width:9"
       id="polygon33"
       points="118.063,-148.212 125.938,-148.212 122,-143.212 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text35"
       font-size="8.00"
       y="-153.60001"
       x="129">1.0</text>
  </g>
  <g
     class="edge"
     id="e82a77ed6-6666-4483-b44c-c60b91c15357"
     transform="translate(4,386)">
    <title
       id="title38">e1f5b79b5-767d-45c9-a8ff-8e0a7d51e778-&gt;ed02a384a-6632-421f-a0d3-f285208ad433</title>
    <path
       style="fill:none;stroke:#565758;stroke-width:5"
       inkscape:connector-curvature="0"
       id="path40"
       d="m 122,-119 c 0,0 -11.802,22.6208 -21.891,41.9583" />
    <polygon
       style="fill:#565758;stroke:#565758;stroke-width:5"
       id="polygon42"
       points="97.9623,-77.6567 101.841,-75.6329 97.5888,-72.2118 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text44"
       font-size="8.00"
       y="-82.599998"
       x="116.5">0.50</text>
  </g>
  <g
     class="edge"
     id="e4c8beef1-d95f-44b3-8508-59e7f75a99b8"
     transform="translate(4,386)">
    <title
       id="title47">e1f5b79b5-767d-45c9-a8ff-8e0a7d51e778-&gt;e42f106f3-0f3a-4c6d-badb-a136c2804361</title>
    <path
       style="fill:none;stroke:#565758;stroke-width:5"
       inkscape:connector-curvature="0"
       id="path49"
       d="m 122,-119 c 0,0 23.055,23.3941 42.316,42.9386" />
    <polygon
       style="fill:#565758;stroke:#565758;stroke-width:5"
       id="polygon51"
       points="163.042,-74.2376 166.158,-77.3086 168.11,-72.2118 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text53"
       font-size="8.00"
       y="-82.599998"
       x="169.5">0.50</text>
  </g>
  <g
     class="edge"
     id="e5de15572-12e2-445d-bf59-99796c2ea2a5"
     transform="translate(4,386)">
    <title
       id="title56">e4be75482-4189-4b15-adbf-06192a8ed49e-&gt;eb23e774d-b7bb-4a99-9442-5dd0552282dc</title>
    <path
       style="fill:none;stroke:#565758;stroke-width:5"
       inkscape:connector-curvature="0"
       id="path58"
       d="m 215,-332 c 0,0 -32.528,24.134 -59.109,43.855" />
    <polygon
       style="fill:#565758;stroke:#565758;stroke-width:5"
       id="polygon60"
       points="154.394,-289.758 157,-286.244 151.681,-285.022 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text62"
       font-size="8.00"
       y="-295.60001"
       x="183.5">0.50</text>
  </g>
  <g
     class="edge"
     id="e8500b8f4-f263-4d79-a082-d97aba791c12"
     transform="translate(4,386)">
    <title
       id="title65">eb23e774d-b7bb-4a99-9442-5dd0552282dc-&gt;ed2c17168-7e10-4975-a1f3-58afe71e03e1</title>
    <path
       style="fill:none;stroke:#252526;stroke-width:9"
       inkscape:connector-curvature="0"
       id="path67"
       d="m 122,-261 c 0,0 0,22.239 0,41.466" />
    <polygon
       style="fill:#252526;stroke:#252526;stroke-width:9"
       id="polygon69"
       points="118.063,-219.212 125.938,-219.212 122,-214.212 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text71"
       font-size="8.00"
       y="-224.60001"
       x="129">1.0</text>
  </g>
  <g
     class="edge"
     id="ee3beae3e-4e15-43e0-b0a8-675bc5ddd9d0"
     transform="translate(4,386)">
    <title
       id="title74">ecd6fc671-2941-4097-ab2b-bd3bbae4bef0-&gt;e87219b72-6a16-4a85-95d7-9490a133978d</title>
    <path
       style="fill:none;stroke:#acb89c;stroke-width:2;stroke-dasharray:5, 2"
       inkscape:connector-curvature="0"
       id="path76"
       d="m 159,-376.5 c 0,0 -16.35,8.474 -34.449,17.854" />
    <polygon
       style="fill:#acb89c;stroke:#acb89c;stroke-width:2"
       id="polygon78"
       points="123.555,-360.1 125.166,-356.993 119.921,-356.246 " />
  </g>
  <g
     class="edge"
     id="e0184621f-c9f0-476d-be50-0909dd6b814d"
     transform="translate(4,386)">
    <title
       id="title81">ecd6fc671-2941-4097-ab2b-bd3bbae4bef0-&gt;e4be75482-4189-4b15-adbf-06192a8ed49e</title>
    <path
       style="fill:none;stroke:#acb89c;stroke-width:2;stroke-dasharray:5, 2"
       inkscape:connector-curvature="0"
       id="path83"
       d="m 159,-376.5 c 0,0 10.605,8.049 22.586,17.141" />
    <polygon
       style="fill:#acb89c;stroke:#acb89c;stroke-width:2"
       id="polygon85"
       points="180.647,-357.875 182.763,-360.663 185.688,-356.246 " />
  </g>
  <g
     class="node"
     id="ed02a384a-6632-421f-a0d3-f285208ad433"
     transform="translate(4,386)">
    <title
       id="title88">ed02a384a-6632-421f-a0d3-f285208ad433</title>
    <path
       style="fill:#6d9bb6;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path90"
       d="m 117,-72 c 0,0 -62,0 -62,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 62,0 62,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text92"
       font-size="22.00"
       y="-51.400002"
       x="65.5">bob</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text94"
       font-size="14.00"
       y="-51.400002"
       x="102.5" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text96"
       font-size="16.00"
       y="-34.200001"
       x="70">0.50</text>
  </g>
  <g
     class="node"
     id="e42f106f3-0f3a-4c6d-badb-a136c2804361"
     transform="translate(4,386)">
    <title
       id="title99">e42f106f3-0f3a-4c6d-badb-a136c2804361</title>
    <path
       style="fill:#6d9bb6;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path101"
       d="m 221,-72 c 0,0 -62,0 -62,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 62,0 62,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text103"
       font-size="22.00"
       y="-51.400002"
       x="163">peter</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text105"
       font-size="14.00"
       y="-51.400002"
       x="213" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text107"
       font-size="16.00"
       y="-34.200001"
       x="174">0.50</text>
  </g>
  <g
     class="node"
     id="e87219b72-6a16-4a85-95d7-9490a133978d"
     transform="translate(4,386)">
    <title
       id="title110">e87219b72-6a16-4a85-95d7-9490a133978d</title>
    <path
       style="fill:#6d9bb6;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path112"
       d="m 142,-356 c 0,0 -130,0 -130,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 130,0 130,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text114"
       font-size="22.00"
       y="-335.39999"
       x="8">good morning</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text116"
       font-size="14.00"
       y="-335.39999"
       x="142" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text118"
       font-size="16.00"
       y="-318.20001"
       x="61">0.50</text>
  </g>
  <g
     class="node"
     id="ed2c17168-7e10-4975-a1f3-58afe71e03e1"
     transform="translate(4,386)">
    <title
       id="title121">ed2c17168-7e10-4975-a1f3-58afe71e03e1</title>
    <path
       style="fill:#0b4971;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path123"
       d="m 153,-214 c 0,0 -62,0 -62,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 62,0 62,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text125"
       font-size="22.00"
       y="-193.39999"
       x="92.5">name</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text127"
       font-size="14.00"
       y="-193.39999"
       x="147.5" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text129"
       font-size="16.00"
       y="-176.2"
       x="110.5">1.0</text>
  </g>
  <g
     class="node"
     id="e1f5b79b5-767d-45c9-a8ff-8e0a7d51e778"
     transform="translate(4,386)">
    <title
       id="title132">e1f5b79b5-767d-45c9-a8ff-8e0a7d51e778</title>
    <path
       style="fill:#0b4971;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path134"
       d="m 153,-143 c 0,0 -62,0 -62,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 62,0 62,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text136"
       font-size="22.00"
       y="-122.4"
       x="111.5">is</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text138"
       font-size="14.00"
       y="-122.4"
       x="128.5" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text140"
       font-size="16.00"
       y="-105.2"
       x="110.5">1.0</text>
  </g>
  <g
     class="node"
     id="e4be75482-4189-4b15-adbf-06192a8ed49e"
     transform="translate(4,386)">
    <title
       id="title143">e4be75482-4189-4b15-adbf-06192a8ed49e</title>
    <path
       style="fill:#6d9bb6;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path145"
       d="m 246,-356 c 0,0 -62,0 -62,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 62,0 62,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text147"
       font-size="22.00"
       y="-335.39999"
       x="189.5">hello</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text149"
       font-size="14.00"
       y="-335.39999"
       x="236.5" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text151"
       font-size="16.00"
       y="-318.20001"
       x="199">0.50</text>
  </g>
  <g
     class="node"
     id="eb23e774d-b7bb-4a99-9442-5dd0552282dc"
     transform="translate(4,386)">
    <title
       id="title154">eb23e774d-b7bb-4a99-9442-5dd0552282dc</title>
    <path
       style="fill:#0b4971;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path156"
       d="m 153,-285 c 0,0 -62,0 -62,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 62,0 62,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text158"
       font-size="22.00"
       y="-264.39999"
       x="105.5">my</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text160"
       font-size="14.00"
       y="-264.39999"
       x="134.5" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text162"
       font-size="16.00"
       y="-247.2"
       x="110.5">1.0</text>
  </g>
  <g
     class="node"
     id="ecd6fc671-2941-4097-ab2b-bd3bbae4bef0"
     transform="translate(4,386)">
    <title
       id="title165">ecd6fc671-2941-4097-ab2b-bd3bbae4bef0</title>
    <circle
       style="fill:#ced6bd;stroke:#595f45"
       r="4.5"
       id="ellipse167"
       cy="-377.5"
       cx="159" />
  </g>
  <g
     class="node"
     id="ed5e65ef0-3332-49ef-a154-dcc56b4bb259"
     transform="translate(4,386)">
    <title
       id="title170">ed5e65ef0-3332-49ef-a154-dcc56b4bb259</title>
    <circle
       style="fill:#d8bbb9;stroke:#614847"
       r="4.5"
       id="ellipse172"
       cy="-4.5"
       cx="147" />
  </g>
</svg>
</figure>

The two sentences are recognized properly. It is worth noticing that on the second sentence the first 2 words (*good morning*) have been recognized together, probably because I've said them very quickly, one next to the other.

The complete code of this example is available in the GitHub repository <https://github.com/beamline/examples/tree/master/src/main/java/beamline/examples/speechRecognition>.


