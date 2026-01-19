# Speech recognition

In this example, we are going to explore a possible usage of streaming process mining in the context of speech recognition: each word a person is saying can be recognized as an activity and the sentences these words belong to can be the process instances. Every time a person waits a considerable amount of time between words, we can assume a new sentence is being said and thus a new case should be generated.

To accomplish our goal we need to define a new `BeamlineAbstractSource` which can listen to the microphone, perform the speech recognition, and generate corresponding events. For the speech recognition we are going to use the [Vosk speech recognition toolkit](https://alphacephei.com/vosk/). We also going to use the [`vosk-model-small-en-us-0.15` model](https://alphacephei.com/vosk/models) which is available on the library website.

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
buffer.offer(BEvent.create("speech", "case-" + caseId, word));
```

Where `buffer` is a buffer used for storing events before they are dispatched to the other operators
and `MILLISECS_FOR_NEW_CASE` is a `long` indicating how many milliseconds separate each sentence (and hence creates a new case identifier).

A simple consumer, in this case the [Trivial discovery miner](../implemented-techniques/discovery-trivial.md), can then be attached to the source with:
```java
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env
   .addSource(new SpeechRecognitionSource())
   .keyBy(BEvent::getProcessName)
   .flatMap(new DirectlyFollowsDependencyDiscoveryMiner()
         .setModelRefreshRate(1)
         .setMinDependency(0))
   .addSink(new SinkFunction<ProcessMap>(){
      public void invoke(ProcessMap value, Context context) throws Exception {
         System.out.println(value.getProcessedEvents());
         value.generateDot().exportToSvg(new File("src/main/resources/output/output.svg"));
      };
   });
env.execute();
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
   height="381px"
   viewBox="0.00 0.00 266.00 381.00"
   version="1.1"
   id="svg184"
   sodipodi:docname="output.svg"
   inkscape:version="0.92.1 r15371">
  <metadata
     id="metadata190">
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
     id="defs188" />
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
     id="namedview186"
     showgrid="false"
     inkscape:zoom="2.4776903"
     inkscape:cx="90.628125"
     inkscape:cy="39.098958"
     inkscape:window-x="-8"
     inkscape:window-y="-8"
     inkscape:window-maximized="1"
     inkscape:current-layer="svg184" />
  <g
     id="graph0"
     class="graph"
     transform="scale(1.0 1.0) rotate(0.0) translate(4.0 377.0)">
    <title
       id="title2">G</title>
    <polygon
       fill="white"
       stroke="none"
       points="-4,4 -4,-377 262,-377 262,4 -4,4"
       id="polygon4" />
    <!-- e76ff4afd&#45;c262&#45;4cfe&#45;904d&#45;0468d17f3e76&#45;&gt;eb7dc8274&#45;6332&#45;4dc7&#45;9522&#45;b778782e936f -->
    <g
       id="eef5bc990-11de-487e-9b07-df1a16ae75c3"
       class="edge">
      <title
         id="title6">e76ff4afd-c262-4cfe-904d-0468d17f3e76-&gt;eb7dc8274-6332-4dc7-9522-b778782e936f</title>
      <path
         fill="none"
         stroke="#c2b0ab"
         stroke-width="2"
         stroke-dasharray="5,2"
         d="M86,-53.5C86,-53.5 123.64,-23.8818 139.786,-11.1769"
         id="path8" />
      <polygon
         fill="#c2b0ab"
         stroke="#c2b0ab"
         stroke-width="2"
         points="140.873,-12.548 143.72,-8.08069 138.709,-9.7974 140.873,-12.548"
         id="polygon10" />
      <text
         text-anchor="middle"
         x="133.5"
         y="-19.6"
         font-family="Arial"
         font-size="8.00"
         id="text12" />
    </g>
    <!-- eb73e3c89&#45;127b&#45;4ee2&#45;9704&#45;b2c34178ec08&#45;&gt;e7642d3c2&#45;398a&#45;436c&#45;bd9a&#45;06bd01cbe9b3 -->
    <g
       id="e556cb169-8d1b-4f0f-a463-a24b4f65bfcd"
       class="edge">
      <title
         id="title15">eb73e3c89-127b-4ee2-9704-b2c34178ec08-&gt;e7642d3c2-398a-436c-bd9a-06bd01cbe9b3</title>
      <path
         fill="none"
         stroke="#565758"
         stroke-width="5"
         d="M77,-317.5C77,-317.5 93.6137,-295.348 107.293,-277.11"
         id="path17" />
      <polygon
         fill="#565758"
         stroke="#565758"
         stroke-width="5"
         points="109.088,-278.362 110.338,-273.05 105.588,-275.737 109.088,-278.362"
         id="polygon19" />
      <text
         text-anchor="middle"
         x="119.5"
         y="-283.6"
         font-family="Arial"
         font-size="8.00"
         id="text21"> 0.50 (1)</text>
    </g>
    <!-- e8af4e578&#45;ab29&#45;42d8&#45;a4e0&#45;ac2ca9f416b0&#45;&gt;e889af76b&#45;8c58&#45;4b36&#45;be88&#45;97ae59fc4b1f -->
    <g
       id="e4c939de3-89ca-42b3-a4ca-fac67dedfa71"
       class="edge">
      <title
         id="title24">e8af4e578-ab29-42d8-a4e0-ac2ca9f416b0-&gt;e889af76b-8c58-4b36-be88-97ae59fc4b1f</title>
      <path
         fill="none"
         stroke="#252526"
         stroke-width="9"
         d="M125,-185.5C125,-185.5 125,-164.451 125,-146.496"
         id="path26" />
      <polygon
         fill="#252526"
         stroke="#252526"
         stroke-width="9"
         points="128.938,-146.05 125,-141.05 121.063,-146.05 128.938,-146.05"
         id="polygon28" />
      <text
         text-anchor="middle"
         x="138.5"
         y="-151.6"
         font-family="Arial"
         font-size="8.00"
         id="text30"> 1.0 (2)</text>
    </g>
    <!-- e889af76b&#45;8c58&#45;4b36&#45;be88&#45;97ae59fc4b1f&#45;&gt;e76ff4afd&#45;c262&#45;4cfe&#45;904d&#45;0468d17f3e76 -->
    <g
       id="ecbb8340d-db5c-4b02-91d0-ff7e3c0baa64"
       class="edge">
      <title
         id="title33">e889af76b-8c58-4b36-be88-97ae59fc4b1f-&gt;e76ff4afd-c262-4cfe-904d-0468d17f3e76</title>
      <path
         fill="none"
         stroke="#565758"
         stroke-width="5"
         d="M125,-119.5C125,-119.5 111.727,-97.7192 100.668,-79.5703"
         id="path35" />
      <polygon
         fill="#565758"
         stroke="#565758"
         stroke-width="5"
         points="102.383,-78.1813 97.9132,-75.0499 98.6471,-80.4579 102.383,-78.1813"
         id="polygon37" />
      <text
         text-anchor="middle"
         x="123.5"
         y="-85.6"
         font-family="Arial"
         font-size="8.00"
         id="text39"> 0.50 (1)</text>
    </g>
    <!-- e889af76b&#45;8c58&#45;4b36&#45;be88&#45;97ae59fc4b1f&#45;&gt;e9f0d9c0c&#45;45bb&#45;43f2&#45;8fd2&#45;1d1114895797 -->
    <g
       id="ed43771e3-7d06-44a8-a919-6f07233bf67d"
       class="edge">
      <title
         id="title42">e889af76b-8c58-4b36-be88-97ae59fc4b1f-&gt;e9f0d9c0c-45bb-43f2-8fd2-1d1114895797</title>
      <path
         fill="none"
         stroke="#565758"
         stroke-width="5"
         d="M125,-119.5C125,-119.5 147.877,-96.9746 166.488,-78.6507"
         id="path44" />
      <polygon
         fill="#565758"
         stroke="#565758"
         stroke-width="5"
         points="168.117,-80.1167 170.145,-75.0499 165.047,-76.9992 168.117,-80.1167"
         id="polygon46" />
      <text
         text-anchor="middle"
         x="176.5"
         y="-85.6"
         font-family="Arial"
         font-size="8.00"
         id="text48"> 0.50 (1)</text>
    </g>
    <!-- e7585ada9&#45;8ea0&#45;49d2&#45;b46a&#45;cae864aa78ae&#45;&gt;e7642d3c2&#45;398a&#45;436c&#45;bd9a&#45;06bd01cbe9b3 -->
    <g
       id="e396f20fc-0c73-49e3-b262-f501630173fb"
       class="edge">
      <title
         id="title51">e7585ada9-8ea0-49d2-b46a-cae864aa78ae-&gt;e7642d3c2-398a-436c-bd9a-06bd01cbe9b3</title>
      <path
         fill="none"
         stroke="#565758"
         stroke-width="5"
         d="M215,-317.5C215,-317.5 182.527,-294.408 156.592,-275.966"
         id="path53" />
      <polygon
         fill="#565758"
         stroke="#565758"
         stroke-width="5"
         points="157.835,-274.165 152.492,-273.05 155.299,-277.73 157.835,-274.165"
         id="polygon55" />
      <text
         text-anchor="middle"
         x="190.5"
         y="-283.6"
         font-family="Arial"
         font-size="8.00"
         id="text57"> 0.50 (1)</text>
    </g>
    <!-- e7642d3c2&#45;398a&#45;436c&#45;bd9a&#45;06bd01cbe9b3&#45;&gt;e8af4e578&#45;ab29&#45;42d8&#45;a4e0&#45;ac2ca9f416b0 -->
    <g
       id="e7a8df7af-01fe-414a-b6cf-77ad2987f8a9"
       class="edge">
      <title
         id="title60">e7642d3c2-398a-436c-bd9a-06bd01cbe9b3-&gt;e8af4e578-ab29-42d8-a4e0-ac2ca9f416b0</title>
      <path
         fill="none"
         stroke="#252526"
         stroke-width="9"
         d="M125,-251.5C125,-251.5 125,-230.451 125,-212.496"
         id="path62" />
      <polygon
         fill="#252526"
         stroke="#252526"
         stroke-width="9"
         points="128.938,-212.05 125,-207.05 121.063,-212.05 128.938,-212.05"
         id="polygon64" />
      <text
         text-anchor="middle"
         x="138.5"
         y="-217.6"
         font-family="Arial"
         font-size="8.00"
         id="text66"> 1.0 (2)</text>
    </g>
    <!-- e9f0d9c0c&#45;45bb&#45;43f2&#45;8fd2&#45;1d1114895797&#45;&gt;eb7dc8274&#45;6332&#45;4dc7&#45;9522&#45;b778782e936f -->
    <g
       id="ed7de76cd-a0c5-450e-9ccf-84b99f234b56"
       class="edge">
      <title
         id="title69">e9f0d9c0c-45bb-43f2-8fd2-1d1114895797-&gt;eb7dc8274-6332-4dc7-9522-b778782e936f</title>
      <path
         fill="none"
         stroke="#c2b0ab"
         stroke-width="2"
         stroke-dasharray="5,2"
         d="M190,-53.5C190,-53.5 164.83,-25.4036 153.004,-12.2026"
         id="path71" />
      <polygon
         fill="#c2b0ab"
         stroke="#c2b0ab"
         stroke-width="2"
         points="154.201,-10.9154 149.561,-8.35887 151.594,-13.2508 154.201,-10.9154"
         id="polygon73" />
      <text
         text-anchor="middle"
         x="165.5"
         y="-19.6"
         font-family="Arial"
         font-size="8.00"
         id="text75" />
    </g>
    <!-- eafc5561b&#45;c3c5&#45;452e&#45;8123&#45;b8bfdc453ee2&#45;&gt;eb73e3c89&#45;127b&#45;4ee2&#45;9704&#45;b2c34178ec08 -->
    <g
       id="e7c7450e6-af16-414b-98fc-bb42963a369f"
       class="edge">
      <title
         id="title78">eafc5561b-c3c5-452e-8123-b8bfdc453ee2-&gt;eb73e3c89-127b-4ee2-9704-b2c34178ec08</title>
      <path
         fill="none"
         stroke="#acb89c"
         stroke-width="2"
         stroke-dasharray="5,2"
         d="M160,-367.5C160,-367.5 136.918,-354.152 115.099,-341.533"
         id="path80" />
      <polygon
         fill="#acb89c"
         stroke="#acb89c"
         stroke-width="2"
         points="115.964,-340.012 110.759,-339.023 114.212,-343.042 115.964,-340.012"
         id="polygon82" />
      <text
         text-anchor="middle"
         x="140.5"
         y="-349.6"
         font-family="Arial"
         font-size="8.00"
         id="text84" />
    </g>
    <!-- eafc5561b&#45;c3c5&#45;452e&#45;8123&#45;b8bfdc453ee2&#45;&gt;e7585ada9&#45;8ea0&#45;49d2&#45;b46a&#45;cae864aa78ae -->
    <g
       id="e2cc0eef6-af8a-4cd0-8a0f-b78d94ba9f87"
       class="edge">
      <title
         id="title87">eafc5561b-c3c5-452e-8123-b8bfdc453ee2-&gt;e7585ada9-8ea0-49d2-b46a-cae864aa78ae</title>
      <path
         fill="none"
         stroke="#acb89c"
         stroke-width="2"
         stroke-dasharray="5,2"
         d="M160,-367.5C160,-367.5 174.54,-354.811 188.668,-342.481"
         id="path89" />
      <polygon
         fill="#acb89c"
         stroke="#acb89c"
         stroke-width="2"
         points="190.013,-343.63 192.629,-339.023 187.712,-340.993 190.013,-343.63"
         id="polygon91" />
      <text
         text-anchor="middle"
         x="183.5"
         y="-349.6"
         font-family="Arial"
         font-size="8.00"
         id="text93" />
    </g>
    <!-- e76ff4afd&#45;c262&#45;4cfe&#45;904d&#45;0468d17f3e76 -->
    <g
       id="e76ff4afd-c262-4cfe-904d-0468d17f3e76"
       class="node">
      <title
         id="title96">e76ff4afd-c262-4cfe-904d-0468d17f3e76</title>
      <path
         fill="#6d9bb6"
         stroke="black"
         d="M117,-75C117,-75 55,-75 55,-75 49,-75 43,-69 43,-63 43,-63 43,-46 43,-46 43,-40 49,-34 55,-34 55,-34 117,-34 117,-34 123,-34 129,-40 129,-46 129,-46 129,-63 129,-63 129,-69 123,-75 117,-75"
         id="path98" />
      <text
         text-anchor="start"
         x="59"
         y="-54.4"
         font-family="Arial"
         font-size="22.00"
         fill="#000000"
         id="text100">peter</text>
      <text
         text-anchor="start"
         x="109"
         y="-54.4"
         font-family="Arial"
         font-size="14.00"
         fill="#000000"
         id="text102" />
      <text
         text-anchor="start"
         x="67"
         y="-41.2"
         font-family="Arial"
         font-size="11.00"
         fill="#000000"
         id="text104">0.50 (1)</text>
    </g>
    <!-- eb73e3c89&#45;127b&#45;4ee2&#45;9704&#45;b2c34178ec08 -->
    <g
       id="eb73e3c89-127b-4ee2-9704-b2c34178ec08"
       class="node">
      <title
         id="title107">eb73e3c89-127b-4ee2-9704-b2c34178ec08</title>
      <path
         fill="#6d9bb6"
         stroke="black"
         d="M142,-339C142,-339 12,-339 12,-339 6,-339 0,-333 0,-327 0,-327 0,-310 0,-310 0,-304 6,-298 12,-298 12,-298 142,-298 142,-298 148,-298 154,-304 154,-310 154,-310 154,-327 154,-327 154,-333 148,-339 142,-339"
         id="path109" />
      <text
         text-anchor="start"
         x="8"
         y="-318.4"
         font-family="Arial"
         font-size="22.00"
         fill="#000000"
         id="text111">good morning</text>
      <text
         text-anchor="start"
         x="142"
         y="-318.4"
         font-family="Arial"
         font-size="14.00"
         fill="#000000"
         id="text113" />
      <text
         text-anchor="start"
         x="58"
         y="-305.2"
         font-family="Arial"
         font-size="11.00"
         fill="#000000"
         id="text115">0.50 (1)</text>
    </g>
    <!-- e8af4e578&#45;ab29&#45;42d8&#45;a4e0&#45;ac2ca9f416b0 -->
    <g
       id="e8af4e578-ab29-42d8-a4e0-ac2ca9f416b0"
       class="node">
      <title
         id="title118">e8af4e578-ab29-42d8-a4e0-ac2ca9f416b0</title>
      <path
         fill="#0b4971"
         stroke="black"
         d="M156,-207C156,-207 94,-207 94,-207 88,-207 82,-201 82,-195 82,-195 82,-178 82,-178 82,-172 88,-166 94,-166 94,-166 156,-166 156,-166 162,-166 168,-172 168,-178 168,-178 168,-195 168,-195 168,-201 162,-207 156,-207"
         id="path120" />
      <text
         text-anchor="start"
         x="95.5"
         y="-186.4"
         font-family="Arial"
         font-size="22.00"
         fill="#ffffff"
         id="text122">name</text>
      <text
         text-anchor="start"
         x="150.5"
         y="-186.4"
         font-family="Arial"
         font-size="14.00"
         fill="#ffffff"
         id="text124" />
      <text
         text-anchor="start"
         x="109"
         y="-173.2"
         font-family="Arial"
         font-size="11.00"
         fill="#ffffff"
         id="text126">1.0 (2)</text>
    </g>
    <!-- e889af76b&#45;8c58&#45;4b36&#45;be88&#45;97ae59fc4b1f -->
    <g
       id="e889af76b-8c58-4b36-be88-97ae59fc4b1f"
       class="node">
      <title
         id="title129">e889af76b-8c58-4b36-be88-97ae59fc4b1f</title>
      <path
         fill="#0b4971"
         stroke="black"
         d="M156,-141C156,-141 94,-141 94,-141 88,-141 82,-135 82,-129 82,-129 82,-112 82,-112 82,-106 88,-100 94,-100 94,-100 156,-100 156,-100 162,-100 168,-106 168,-112 168,-112 168,-129 168,-129 168,-135 162,-141 156,-141"
         id="path131" />
      <text
         text-anchor="start"
         x="114.5"
         y="-120.4"
         font-family="Arial"
         font-size="22.00"
         fill="#ffffff"
         id="text133">is</text>
      <text
         text-anchor="start"
         x="131.5"
         y="-120.4"
         font-family="Arial"
         font-size="14.00"
         fill="#ffffff"
         id="text135" />
      <text
         text-anchor="start"
         x="109"
         y="-107.2"
         font-family="Arial"
         font-size="11.00"
         fill="#ffffff"
         id="text137">1.0 (2)</text>
    </g>
    <!-- e7585ada9&#45;8ea0&#45;49d2&#45;b46a&#45;cae864aa78ae -->
    <g
       id="e7585ada9-8ea0-49d2-b46a-cae864aa78ae"
       class="node">
      <title
         id="title140">e7585ada9-8ea0-49d2-b46a-cae864aa78ae</title>
      <path
         fill="#6d9bb6"
         stroke="black"
         d="M246,-339C246,-339 184,-339 184,-339 178,-339 172,-333 172,-327 172,-327 172,-310 172,-310 172,-304 178,-298 184,-298 184,-298 246,-298 246,-298 252,-298 258,-304 258,-310 258,-310 258,-327 258,-327 258,-333 252,-339 246,-339"
         id="path142" />
      <text
         text-anchor="start"
         x="189.5"
         y="-318.4"
         font-family="Arial"
         font-size="22.00"
         fill="#000000"
         id="text144">hello</text>
      <text
         text-anchor="start"
         x="236.5"
         y="-318.4"
         font-family="Arial"
         font-size="14.00"
         fill="#000000"
         id="text146" />
      <text
         text-anchor="start"
         x="196"
         y="-305.2"
         font-family="Arial"
         font-size="11.00"
         fill="#000000"
         id="text148">0.50 (1)</text>
    </g>
    <!-- e7642d3c2&#45;398a&#45;436c&#45;bd9a&#45;06bd01cbe9b3 -->
    <g
       id="e7642d3c2-398a-436c-bd9a-06bd01cbe9b3"
       class="node">
      <title
         id="title151">e7642d3c2-398a-436c-bd9a-06bd01cbe9b3</title>
      <path
         fill="#0b4971"
         stroke="black"
         d="M156,-273C156,-273 94,-273 94,-273 88,-273 82,-267 82,-261 82,-261 82,-244 82,-244 82,-238 88,-232 94,-232 94,-232 156,-232 156,-232 162,-232 168,-238 168,-244 168,-244 168,-261 168,-261 168,-267 162,-273 156,-273"
         id="path153" />
      <text
         text-anchor="start"
         x="108.5"
         y="-252.4"
         font-family="Arial"
         font-size="22.00"
         fill="#ffffff"
         id="text155">my</text>
      <text
         text-anchor="start"
         x="137.5"
         y="-252.4"
         font-family="Arial"
         font-size="14.00"
         fill="#ffffff"
         id="text157" />
      <text
         text-anchor="start"
         x="109"
         y="-239.2"
         font-family="Arial"
         font-size="11.00"
         fill="#ffffff"
         id="text159">1.0 (2)</text>
    </g>
    <!-- e9f0d9c0c&#45;45bb&#45;43f2&#45;8fd2&#45;1d1114895797 -->
    <g
       id="e9f0d9c0c-45bb-43f2-8fd2-1d1114895797"
       class="node">
      <title
         id="title162">e9f0d9c0c-45bb-43f2-8fd2-1d1114895797</title>
      <path
         fill="#6d9bb6"
         stroke="black"
         d="M221,-75C221,-75 159,-75 159,-75 153,-75 147,-69 147,-63 147,-63 147,-46 147,-46 147,-40 153,-34 159,-34 159,-34 221,-34 221,-34 227,-34 233,-40 233,-46 233,-46 233,-63 233,-63 233,-69 227,-75 221,-75"
         id="path164" />
      <text
         x="169.5"
         y="-54.400002"
         font-size="22.00"
         id="text166"
         style="font-size:22px;font-family:Arial;text-anchor:start;fill:#000000">bob</text>
      <text
         text-anchor="start"
         x="206.5"
         y="-54.4"
         font-family="Arial"
         font-size="14.00"
         fill="#000000"
         id="text168" />
      <text
         text-anchor="start"
         x="171"
         y="-41.2"
         font-family="Arial"
         font-size="11.00"
         fill="#000000"
         id="text170">0.50 (1)</text>
    </g>
    <!-- eafc5561b&#45;c3c5&#45;452e&#45;8123&#45;b8bfdc453ee2 -->
    <g
       id="eafc5561b-c3c5-452e-8123-b8bfdc453ee2"
       class="node">
      <title
         id="title173">eafc5561b-c3c5-452e-8123-b8bfdc453ee2</title>
      <ellipse
         fill="#ced6bd"
         stroke="#595f45"
         cx="160"
         cy="-368.5"
         rx="4.5"
         ry="4.5"
         id="ellipse175" />
    </g>
    <!-- eb7dc8274&#45;6332&#45;4dc7&#45;9522&#45;b778782e936f -->
    <g
       id="eb7dc8274-6332-4dc7-9522-b778782e936f"
       class="node">
      <title
         id="title178">eb7dc8274-6332-4dc7-9522-b778782e936f</title>
      <ellipse
         fill="#d8bbb9"
         stroke="#614847"
         cx="147"
         cy="-4.5"
         rx="4.5"
         ry="4.5"
         id="ellipse180" />
    </g>
  </g>
</svg>
</figure>

The two sentences are recognized properly. It is worth noticing that on the second sentence the first 2 words (*good morning*) have been recognized together, probably because I've said them very quickly, one next to the other.

The complete code of this example is available in the GitHub repository <https://github.com/beamline/examples/tree/master/src/main/java/beamline/examples/speechRecognition>.


