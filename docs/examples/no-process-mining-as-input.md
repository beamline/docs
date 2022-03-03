Let's say we have a certain file that we want to consider for processing using Beamline but this file does not meet any of the sources already implemented. Then, this example shows how to process such a file using Beamline.

For the sake of simplicity let's consider a file where each line refers to one event but, within the line, the first 3 characters identify the case id, while the rest is the activity name. This is an example of such a file (where `001` and `002` are the case ids, and `ActA`, `B` and `Act_C` are the activity names):

```linenums="1"
002ActA
001ActA
002B
002Act_C
001B
001Act_C
```

To accomplish our goal, we need first to import the file as a stream of strings (assuming that a variable called `fileName` exists and its value is the absolute path of the file to be parsed):

```java linenums="1"
Observable<String> streamOfStrings = Observable.fromStream(Files.lines(Paths.get(fileName)));
```

Next, it is necessary to transform such a stream of strings into a stream of `XTrace`s:

```java linenums="2"
XFactory factory = new XFactoryNaiveImpl();

Observable<XTrace> streamOfXTraces = streamOfStrings.flatMap(new Function<String, ObservableSource<XTrace>>() {
	@Override
	public @NonNull ObservableSource<XTrace> apply(@NonNull String t) throws Throwable {
		String caseId = t.substring(0, 3);
		String activityName = t.substring(3);
		
		XTrace wrapper = factory.createTrace();
		XEvent event = factory.createEvent();
		
		XConceptExtension.instance().assignName(wrapper, caseId);
		XConceptExtension.instance().assignName(event, activityName);
		
		wrapper.add(event);
		
		return Observable.just(wrapper);
	}
});
```

Now, a stream of `XTrace` is available and can be processed with any miner available, for example, using the [Trivial discovery miner](../implemented-techniques/discovery-trivial.md):

```java linenums="21"
TrivialDiscoveryMiner miner = new TrivialDiscoveryMiner();
miner.setMinDependency(0); // no filtering
miner.setModelRefreshRate(1); // since we have only few events, we refresh the output at every event
streamOfXTraces
	.doOnComplete(() -> miner
		.getLatestResponse()
		.generateDot()
		.exportToSvg(new File("output.svg")))
	.subscribe(miner);
```

In this case, we configured the miner to consume all events and, once the stream is completed (in this case we do know that the stream will terminate) we dump the result of the miner into a file `output.svg` which will contain the following model:

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="87"
   height="241"
   viewBox="0 0 87 241"
   version="1.1"
   id="svg82"
   sodipodi:docname="output-6.svg"
   inkscape:version="0.92.1 r15371">
  <metadata
     id="metadata88">
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
     id="defs86" />
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
     id="namedview84"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:zoom="1.9032258"
     inkscape:cx="82.834082"
     inkscape:cy="164.098"
     inkscape:window-x="1912"
     inkscape:window-y="-8"
     inkscape:window-maximized="1"
     inkscape:current-layer="e615c20bc-8ba7-4f15-a624-44024836d1c0" />
  <g
     class="edge"
     id="e615c20bc-8ba7-4f15-a624-44024836d1c0"
     transform="translate(0.5,240.5)">
    <title
       id="title6">ef458f9c8-1e0f-4092-a07d-0c8c5f2aa299-&gt;e3b8e3384-86a9-4252-a826-a23ccd62d707</title>
    <path
       style="fill:none;stroke:#252526;stroke-width:9"
       inkscape:connector-curvature="0"
       id="path8"
       d="m 43,-190 c 0,0 0,22.239 0,41.466" />
    <polygon
       style="fill:#252526;stroke:#252526;stroke-width:9"
       id="polygon10"
       points="39.0626,-148.212 46.9376,-148.212 43,-143.212 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text12"
       font-size="8.00"
       y="-153.60001"
       x="54">1.0</text>
  </g>
  <path
     d="m 43.5,121.5 c 0,0 0,22.239 0,41.466"
     id="path17"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#252526;stroke-width:9" />
  <polygon
     points="46.9376,-77.2118 43,-72.2118 39.0626,-77.2119 "
     id="polygon19"
     style="fill:#252526;stroke:#252526;stroke-width:9"
     transform="translate(0.5,240.5)" />
  <text
     x="54.5"
     y="157.89999"
     font-size="8.00"
     id="text21"
     style="font-size:8px;font-family:Arial;text-anchor:middle">1.0</text>
  <g
     class="edge"
     id="e3375df6b-d97a-4139-a585-694027524560"
     transform="translate(0.5,240.5)">
    <title
       id="title24">e79676f5f-97c7-4b0e-97de-5081c41113e2-&gt;e3ad28cf8-6c4b-4eb0-9bb0-8cfa80049600</title>
    <path
       style="fill:none;stroke:#c2b0ab;stroke-width:2;stroke-dasharray:5, 2"
       inkscape:connector-curvature="0"
       id="path26"
       d="m 43,-48 c 0,0 0,21.1209 0,33.5841" />
    <polygon
       style="fill:#c2b0ab;stroke:#c2b0ab;stroke-width:2"
       id="polygon28"
       points="41.2501,-14.1236 44.7501,-14.1235 43,-9.12353 " />
  </g>
  <g
     class="edge"
     id="e7ba07599-0d5c-4862-9552-dce519b93514"
     transform="translate(0.5,240.5)">
    <title
       id="title31">ee32e64a7-b6c2-49f3-9219-f6c5e070953d-&gt;ef458f9c8-1e0f-4092-a07d-0c8c5f2aa299</title>
    <path
       style="fill:none;stroke:#acb89c;stroke-width:2;stroke-dasharray:5, 2"
       inkscape:connector-curvature="0"
       id="path33"
       d="m 43,-234.5 c 0,0 0,6.838 0,15.029" />
    <polygon
       style="fill:#acb89c;stroke:#acb89c;stroke-width:2"
       id="polygon35"
       points="41.2501,-219.246 44.7501,-219.246 43,-214.246 " />
  </g>
  <g
     class="node"
     id="ef458f9c8-1e0f-4092-a07d-0c8c5f2aa299"
     transform="translate(0.5,240.5)">
    <title
       id="title38">ef458f9c8-1e0f-4092-a07d-0c8c5f2aa299</title>
    <path
       style="fill:#0b4971;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path40"
       d="m 74,-214 c 0,0 -62,0 -62,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 62,0 62,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text42"
       font-size="22.00"
       y="-193.39999"
       x="18">ActA</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text44"
       font-size="14.00"
       y="-193.39999"
       x="64" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text46"
       font-size="16.00"
       y="-176.2"
       x="31.5">1.0</text>
  </g>
  <g
     class="node"
     id="e3b8e3384-86a9-4252-a826-a23ccd62d707"
     transform="translate(0.5,240.5)">
    <title
       id="title49">e3b8e3384-86a9-4252-a826-a23ccd62d707</title>
    <path
       style="fill:#0b4971;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path51"
       d="m 74,-143 c 0,0 -62,0 -62,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 62,0 62,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text53"
       font-size="22.00"
       y="-122.4"
       x="33.5">B</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text55"
       font-size="14.00"
       y="-122.4"
       x="48.5" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text57"
       font-size="16.00"
       y="-105.2"
       x="31.5">1.0</text>
  </g>
  <g
     class="node"
     id="e79676f5f-97c7-4b0e-97de-5081c41113e2"
     transform="translate(0.5,240.5)">
    <title
       id="title60">e79676f5f-97c7-4b0e-97de-5081c41113e2</title>
    <path
       style="fill:#0b4971;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path62"
       d="m 74,-72 c 0,0 -62,0 -62,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 62,0 62,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text64"
       font-size="22.00"
       y="-51.400002"
       x="11">Act_C</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text66"
       font-size="14.00"
       y="-51.400002"
       x="71" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text68"
       font-size="16.00"
       y="-34.200001"
       x="31.5">1.0</text>
  </g>
  <g
     class="node"
     id="ee32e64a7-b6c2-49f3-9219-f6c5e070953d"
     transform="translate(0.5,240.5)">
    <title
       id="title71">ee32e64a7-b6c2-49f3-9219-f6c5e070953d</title>
    <circle
       style="fill:#ced6bd;stroke:#595f45"
       r="4.5"
       id="ellipse73"
       cy="-235.5"
       cx="43" />
  </g>
  <g
     class="node"
     id="e3ad28cf8-6c4b-4eb0-9bb0-8cfa80049600"
     transform="translate(0.5,240.5)">
    <title
       id="title76">e3ad28cf8-6c4b-4eb0-9bb0-8cfa80049600</title>
    <circle
       style="fill:#d8bbb9;stroke:#614847"
       r="4.5"
       id="ellipse78"
       cy="-4.5"
       cx="43" />
  </g>
</svg>