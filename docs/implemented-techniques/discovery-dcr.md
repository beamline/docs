## Dependency [![](https://jitpack.io/v/beamline/discovery-dcr.svg)](https://jitpack.io/#beamline/discovery-dcr)

To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the dependency:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>discovery-dcr</artifactId>
    <version>master-SNAPSHOT</version>
</dependency>
```
See the [introduction page](index.md) for further instructions.


## Usage

To construct a DCR miner it is possible to construct it with the following code:

```java linenums="1"
DFGBasedMiner miner = new DFGBasedMiner();
```

It is possible (though not necessary) to configure the miner with the following parameters:

```java linenums="2"
// configuration of list of patters
miner.setDcrPatternsForMining("Response", "Condition", "Include", "Exclude");

// configuration of the miner type
miner.setStreamMinerType(new UnlimitedStreamMiner());
//miner.setStreamMinerType(new SlidingWindowStreamMiner(15, 500));

// configure which constraints to visualize
miner.setDcrConstraintsForVisualization(RELATION.CONDITION, RELATION.RESPONSE);

// configure the threshold
miner.setRelationsThreshold(1);

// configure the transitive reduction
miner.setTransitiveReductionList(RELATION.CONDITION, RELATION.RESPONSE);
```

Once the miner is properly configured, it can be used as any other consumer. For example, using the following code:
```java linenums="17"
XesSource source = ...
source.prepare();
source
	.getObservable()
	.subscribe(miner);

```

It is also possible to attach hooks to the miner, for example to export the model every so often:
```java
miner.setOnAfterEvent(() -> {
	if (miner.getProcessedEvents() % 1000 == 0) {
		try {
			new DcrModelView(miner.getDcrModel()).exportToSvg(new File("out.svg"));
		} catch (IOException e) { }
	}
});
```

An example of the output produced is:

<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="213.85083"
   height="324.94119"
   viewBox="0 0 213.88954 324.94119"
   version="1.1"
   id="svg332"
   sodipodi:docname="out.svg"
   inkscape:version="0.92.1 r15371">
  <metadata
     id="metadata338">
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
     id="defs336" />
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
     id="namedview334"
     showgrid="false"
     fit-margin-top="0"
     fit-margin-left="0"
     fit-margin-right="0"
     fit-margin-bottom="0"
     inkscape:zoom="1.2356021"
     inkscape:cx="166.3297"
     inkscape:cy="86.296716"
     inkscape:window-x="-8"
     inkscape:window-y="-8"
     inkscape:window-maximized="1"
     inkscape:current-layer="svg332" />
  <polygon
     points="72,-504 126,-504 126,-540 72,-540 "
     id="polygon65"
     style="fill:#f8f6ec;stroke:#cbcbcb"
     transform="translate(0.5,540.43086)" />
  <text
     x="99.5"
     y="20.930861"
     font-size="10.00"
     id="text67"
     style="font-size:10px;font-family:arial;text-anchor:middle">G</text>
  <polygon
     points="72,-432 126,-432 126,-468 72,-468 "
     id="polygon72"
     style="fill:#f8f6ec;stroke:#cbcbcb"
     transform="translate(0.5,540.43086)" />
  <text
     x="99.5"
     y="92.930862"
     font-size="10.00"
     id="text74"
     style="font-size:10px;font-family:arial;text-anchor:middle">E</text>
  <path
     d="m 97.58502,36.73386 c -0.822,7.969 -1.0366,17.597 -0.6438,26.433"
     id="path79"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#ffa500" />
  <circle
     cx="97.460907"
     cy="70.331863"
     id="ellipse81"
     r="2"
     style="fill:#ffa500;stroke:#ffa500" />
  <polygon
     points="90.7083,-476.954 94.1991,-477.207 92.8155,-472.094 "
     id="polygon83"
     style="fill:#ffa500;stroke:#ffa500"
     transform="translate(4.500724,540.43086)" />
  <polygon
     points="0,-360 54,-360 54,-396 0,-396 "
     id="polygon97"
     style="fill:#f8f6ec;stroke:#cbcbcb"
     transform="translate(0.5,540.43086)" />
  <text
     x="27.5"
     y="164.93086"
     font-size="10.00"
     id="text99"
     style="font-size:10px;font-family:arial;text-anchor:middle">L</text>
  <path
     d="m 75.7865,108.73386 c -9.8812,8.732 -21.0841,19.457 -30.2877,28.947"
     id="path104"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#ffa500" />
  <circle
     cx="40.574001"
     cy="142.87486"
     id="ellipse106"
     r="2.00001"
     style="fill:#ffa500;stroke:#ffa500" />
  <polygon
     points="46.1601,-401.432 41.4501,-399.007 43.6202,-403.84 "
     id="polygon108"
     style="fill:#ffa500;stroke:#ffa500"
     transform="translate(0.5,540.43086)" />
  <path
     d="m 84.686,111.86186 c -8.6327,9.099 -19.6309,19.798 -29.7309,28.922"
     id="path113"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#2993fc" />
  <circle
     cx="86.250099"
     cy="110.19386"
     id="ellipse115"
     r="2.00002"
     style="fill:#2993fc;stroke:#2993fc" />
  <polygon
     points="55.383,-398.13 50.4881,-396.104 53.0516,-400.74 "
     id="polygon117"
     style="fill:#2993fc;stroke:#2993fc"
     transform="translate(0.5,540.43086)" />
  <polygon
     points="72,-360 126,-360 126,-396 72,-396 "
     id="polygon122"
     style="fill:#f8f6ec;stroke:#cbcbcb"
     transform="translate(0.5,540.43086)" />
  <text
     x="99.5"
     y="164.93086"
     font-size="10.00"
     id="text124"
     style="font-size:10px;font-family:arial;text-anchor:middle">M</text>
  <path
     d="m 93.5843,108.73386 c -0.822,7.969 -1.0366,17.597 -0.6438,26.433"
     id="path129"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#ffa500" />
  <circle
     cx="93.460197"
     cy="142.33186"
     id="ellipse131"
     r="2"
     style="fill:#ffa500;stroke:#ffa500" />
  <polygon
     points="94.1991,-405.207 92.8155,-400.094 90.7083,-404.954 "
     id="polygon133"
     style="fill:#ffa500;stroke:#ffa500"
     transform="translate(0.5,540.43086)" />
  <path
     d="m 105.783,112.93486 c 0.607,8.35 0.622,17.91 0.047,26.323"
     id="path138"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#2993fc" />
  <circle
     cx="105.59"
     cy="110.72685"
     id="ellipse140"
     r="2"
     style="fill:#2993fc;stroke:#2993fc" />
  <polygon
     points="107.066,-400.936 104.895,-396.104 103.579,-401.236 "
     id="polygon142"
     style="fill:#2993fc;stroke:#2993fc"
     transform="translate(0.5,540.43086)" />
  <polygon
     points="144,-360 198,-360 198,-396 144,-396 "
     id="polygon147"
     style="fill:#f8f6ec;stroke:#cbcbcb"
     transform="translate(0.5,540.43086)" />
  <text
     x="171.5"
     y="164.93086"
     font-size="10.00"
     id="text149"
     style="font-size:10px;font-family:arial;text-anchor:middle">K</text>
  <path
     d="m 111.382,108.73386 c 8.237,8.901 19.363,19.874 29.86,29.498"
     id="path154"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#ffa500" />
  <circle
     cx="146.52499"
     cy="142.98888"
     id="ellipse156"
     r="2.00001"
     style="fill:#ffa500;stroke:#ffa500" />
  <polygon
     points="141.994,-403.426 144.539,-398.781 139.652,-400.825 "
     id="polygon158"
     style="fill:#ffa500;stroke:#ffa500"
     transform="translate(0.5,540.43086)" />
  <path
     d="m 126.42,111.59586 c 10.065,9.065 21.084,19.759 29.798,28.912"
     id="path163"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#2993fc" />
  <circle
     cx="124.70599"
     cy="110.06587"
     id="ellipse165"
     r="2.00002"
     style="fill:#2993fc;stroke:#2993fc" />
  <polygon
     points="157.157,-400.948 159.302,-396.104 154.604,-398.553 "
     id="polygon167"
     style="fill:#2993fc;stroke:#2993fc"
     transform="translate(0.5,540.43086)" />
  <polygon
     points="108,-288 162,-288 162,-324 108,-324 "
     id="polygon172"
     style="fill:#f8f6ec;stroke:#cbcbcb"
     transform="translate(0.5,540.43086)" />
  <text
     x="135.5"
     y="236.93086"
     font-size="10.00"
     id="text174"
     style="font-size:10px;font-family:arial;text-anchor:middle">H</text>
  <path
     d="m 126.701,96.35286 c 25.827,6.275 63.235,19.894 80.799,48.078 8.462,13.579 7.219,21.721 0,36 -7.845,15.516 -22.61,27.601 -36.737,36.287"
     id="path179"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#ffa500" />
  <circle
     cx="164.30901"
     cy="220.43987"
     id="ellipse181"
     r="2.00001"
     style="fill:#ffa500;stroke:#ffa500" />
  <polygon
     points="170.747,-321.972 165.542,-320.99 168.999,-325.004 "
     id="polygon183"
     style="fill:#ffa500;stroke:#ffa500"
     transform="translate(0.5,540.43086)" />
  <path
     d="m 57.5183,182.88686 c 14.6329,9.485 32.214,20.88 46.9757,30.448"
     id="path238"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#2993fc" />
  <circle
     cx="55.598099"
     cy="181.64287"
     id="ellipse240"
     r="2.00002"
     style="fill:#2993fc;stroke:#2993fc" />
  <polygon
     points="105.235,-328.378 108.479,-324.19 103.331,-325.441 "
     id="polygon242"
     style="fill:#2993fc;stroke:#2993fc"
     transform="translate(0.5,540.43086)" />
  <path
     d="m 110.283,184.39686 c 4.425,8.604 9.547,18.564 14.014,27.251"
     id="path247"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#2993fc" />
  <circle
     cx="109.314"
     cy="182.51286"
     id="ellipse249"
     r="2.00002"
     style="fill:#2993fc;stroke:#2993fc" />
  <polygon
     points="125.473,-329.351 126.203,-324.104 122.36,-327.75 "
     id="polygon251"
     style="fill:#2993fc;stroke:#2993fc"
     transform="translate(0.5,540.43086)" />
  <path
     d="m 160.717,184.39686 c -4.425,8.604 -9.547,18.564 -14.014,27.251"
     id="path256"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#2993fc" />
  <circle
     cx="161.686"
     cy="182.51286"
     id="ellipse258"
     r="2.00002"
     style="fill:#2993fc;stroke:#2993fc" />
  <polygon
     points="147.64,-327.75 143.797,-324.104 144.527,-329.351 "
     id="polygon260"
     style="fill:#2993fc;stroke:#2993fc"
     transform="translate(0.5,540.43086)" />
  <polygon
     points="108,-216 162,-216 162,-252 108,-252 "
     id="polygon265"
     style="fill:#f8f6ec;stroke:#cbcbcb"
     transform="translate(0.5,540.43086)" />
  <text
     x="135.5"
     y="308.93085"
     font-size="10.00"
     id="text267"
     style="font-size:10px;font-family:arial;text-anchor:middle">F</text>
  <path
     d="m 137.78228,256.93486 c 0.607,8.35 0.622,17.91 0.047,26.323"
     id="path281"
     inkscape:connector-curvature="0"
     style="fill:none;stroke:#2993fc" />
  <circle
     cx="137.58926"
     cy="254.72685"
     id="ellipse283"
     r="2"
     style="fill:#2993fc;stroke:#2993fc" />
  <polygon
     points="143.066,-256.936 140.895,-252.104 139.579,-257.236 "
     id="polygon285"
     style="fill:#2993fc;stroke:#2993fc"
     transform="translate(-3.5007241,540.43086)" />
</svg>




## Scientific literature

The techniques implemented in this package are described in:

- TBA