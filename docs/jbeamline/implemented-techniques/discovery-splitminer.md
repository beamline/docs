# Split Miner

## Dependency

To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the dependency:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>discovery-splitminer</artifactId>
    <version>master-SNAPSHOT</version>
</dependency>
```
See the [installation page](../installation.md) for further instructions.

[![](https://jitpack.io/v/beamline/discovery-splitminer.svg)](https://jitpack.io/#beamline/discovery-splitminer)


## Usage

This miner can be used to extract a BPMN process model in a similar way as performed by the Split Miner.

Once a `XesSource` is available, the miner can be configured and used as follows:

```java linenums="1"

LossyCountingBudgetSplitMiner miner = new LossyCountingBudgetSplitMiner(
	10, // the budget for cases
	10, // the budget for relations
	0.01, // concurrency threshold
	0.01, // the frequency threshold
	5); // the sliding window size

StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env
	.addSource(new StringTestSource("ABCDF", "ABCEF"))
	.keyBy(BEvent::getProcessName)
	.flatMap(miner)
	.addSink(new SinkFunction<BPMNTemplateResponse>() {
		public void invoke(BPMNTemplateResponse value, Context context) throws Exception {
			PaliaLikeBPMNDiagramGenerator.fromBPMNTemplate(
				"process",
				value.getBpmnTemplate(),
				"output.svg");
		}
	});
env.execute();
```

This code will produce the following model:
<figure>

<svg width="668px" height="98px"
 viewBox="0.00 0.00 668.00 98.00" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<g id="graph0" class="graph" transform="scale(1.0 1.0) rotate(0.0) translate(4.0 94.0)">
<title>G</title>
<polygon fill="white" stroke="transparent" points="-4,4 -4,-94 664,-94 664,4 -4,4"/>
<!-- e53a1df30&#45;9705&#45;4b08&#45;b0a8&#45;3263f4319ccc&#45;&gt;e19ab2931&#45;dc04&#45;48da&#45;bc8b&#45;a6445506d5c4 -->
<g id="e60b78e77&#45;f800&#45;4745&#45;8f69&#45;56f7a8303f9c" class="edge">
<title>e53a1df30&#45;9705&#45;4b08&#45;b0a8&#45;3263f4319ccc&#45;&gt;e19ab2931&#45;dc04&#45;48da&#45;bc8b&#45;a6445506d5c4</title>
<path fill="none" stroke="black" d="M12,-45C12,-45 29.5,-45 47.25,-45"/>
<polygon fill="black" stroke="black" points="47.6,-48.5 57.6,-45 47.6,-41.5 47.6,-48.5"/>
</g>
<!-- e19ab2931&#45;dc04&#45;48da&#45;bc8b&#45;a6445506d5c4&#45;&gt;e808aba30&#45;b5eb&#45;469b&#45;b542&#45;d5a27f4588b7 -->
<g id="e570fa095&#45;6945&#45;4ff5&#45;b8eb&#45;53abc79efd9a" class="edge">
<title>e19ab2931&#45;dc04&#45;48da&#45;bc8b&#45;a6445506d5c4&#45;&gt;e808aba30&#45;b5eb&#45;469b&#45;b542&#45;d5a27f4588b7</title>
<path fill="none" stroke="black" d="M86,-45C86,-45 113.31,-45 137.51,-45"/>
<polygon fill="black" stroke="black" points="137.6,-48.5 147.6,-45 137.6,-41.5 137.6,-48.5"/>
</g>
<!-- e808aba30&#45;b5eb&#45;469b&#45;b542&#45;d5a27f4588b7&#45;&gt;eeab80efd&#45;180c&#45;4fe1&#45;8e69&#45;9934b9ea0b09 -->
<g id="ec0a5f655&#45;43a5&#45;4088&#45;b71e&#45;7b5e25f8dcff" class="edge">
<title>e808aba30&#45;b5eb&#45;469b&#45;b542&#45;d5a27f4588b7&#45;&gt;eeab80efd&#45;180c&#45;4fe1&#45;8e69&#45;9934b9ea0b09</title>
<path fill="none" stroke="black" d="M176,-45C176,-45 203.31,-45 227.51,-45"/>
<polygon fill="black" stroke="black" points="227.6,-48.5 237.6,-45 227.6,-41.5 227.6,-48.5"/>
</g>
<!-- ee7b841cb&#45;464c&#45;419a&#45;8bae&#45;3f806f9ec5c9&#45;&gt;e6ae57bba&#45;eded&#45;484d&#45;af11&#45;a5a1989a71ee -->
<g id="e8ecd58b0&#45;5875&#45;4132&#45;b7d9&#45;851199c9f711" class="edge">
<title>ee7b841cb&#45;464c&#45;419a&#45;8bae&#45;3f806f9ec5c9&#45;&gt;e6ae57bba&#45;eded&#45;484d&#45;af11&#45;a5a1989a71ee</title>
<path fill="none" stroke="black" d="M576,-45C576,-45 606.61,-45 627.91,-45"/>
<polygon fill="black" stroke="black" points="627.99,-48.5 637.99,-45 627.99,-41.5 627.99,-48.5"/>
</g>
<!-- eeab80efd&#45;180c&#45;4fe1&#45;8e69&#45;9934b9ea0b09&#45;&gt;ea1411cd2&#45;ee63&#45;41c7&#45;a2dc&#45;1c7840253baa -->
<g id="e356780f9&#45;408a&#45;4f3b&#45;8d2d&#45;1dc7d897a344" class="edge">
<title>eeab80efd&#45;180c&#45;4fe1&#45;8e69&#45;9934b9ea0b09&#45;&gt;ea1411cd2&#45;ee63&#45;41c7&#45;a2dc&#45;1c7840253baa</title>
<path fill="none" stroke="black" d="M266,-45C266,-45 295.43,-45 317.55,-45"/>
<polygon fill="black" stroke="black" points="317.65,-48.5 327.65,-45 317.65,-41.5 317.65,-48.5"/>
</g>
<!-- e808e2a5f&#45;5092&#45;4189&#45;90b5&#45;8395b10cce91&#45;&gt;ebc3567e8&#45;38c0&#45;4f5e&#45;ae50&#45;e43c49309c44 -->
<g id="e10a92820&#45;95ed&#45;4d97&#45;80c5&#45;2903c32392db" class="edge">
<title>e808e2a5f&#45;5092&#45;4189&#45;90b5&#45;8395b10cce91&#45;&gt;ebc3567e8&#45;38c0&#45;4f5e&#45;ae50&#45;e43c49309c44</title>
<path fill="none" stroke="black" d="M421,-72C421,-72 454.32,-60.08 476.69,-52.08"/>
<polygon fill="black" stroke="black" points="478.08,-55.3 486.32,-48.64 475.72,-48.71 478.08,-55.3"/>
</g>
<!-- eaf32a996&#45;30c2&#45;4603&#45;b9ef&#45;ae197503fc9b&#45;&gt;ebc3567e8&#45;38c0&#45;4f5e&#45;ae50&#45;e43c49309c44 -->
<g id="e8f788920&#45;6292&#45;45f9&#45;9a72&#45;ceafb01d2073" class="edge">
<title>eaf32a996&#45;30c2&#45;4603&#45;b9ef&#45;ae197503fc9b&#45;&gt;ebc3567e8&#45;38c0&#45;4f5e&#45;ae50&#45;e43c49309c44</title>
<path fill="none" stroke="black" d="M421,-18C421,-18 454.32,-29.92 476.69,-37.92"/>
<polygon fill="black" stroke="black" points="475.72,-41.29 486.32,-41.36 478.08,-34.7 475.72,-41.29"/>
</g>
<!-- ea1411cd2&#45;ee63&#45;41c7&#45;a2dc&#45;1c7840253baa&#45;&gt;e808e2a5f&#45;5092&#45;4189&#45;90b5&#45;8395b10cce91 -->
<g id="e412e60ca&#45;e1df&#45;4934&#45;9d90&#45;097a50a06d41" class="edge">
<title>ea1411cd2&#45;ee63&#45;41c7&#45;a2dc&#45;1c7840253baa&#45;&gt;e808e2a5f&#45;5092&#45;4189&#45;90b5&#45;8395b10cce91</title>
<path fill="none" stroke="black" d="M343.5,-45C343.5,-45 363.68,-52.22 383.17,-59.19"/>
<polygon fill="black" stroke="black" points="382,-62.48 392.59,-62.56 384.36,-55.89 382,-62.48"/>
</g>
<!-- ea1411cd2&#45;ee63&#45;41c7&#45;a2dc&#45;1c7840253baa&#45;&gt;eaf32a996&#45;30c2&#45;4603&#45;b9ef&#45;ae197503fc9b -->
<g id="eaa2a0c8e&#45;3ce9&#45;41c2&#45;9a90&#45;5f577efee202" class="edge">
<title>ea1411cd2&#45;ee63&#45;41c7&#45;a2dc&#45;1c7840253baa&#45;&gt;eaf32a996&#45;30c2&#45;4603&#45;b9ef&#45;ae197503fc9b</title>
<path fill="none" stroke="black" d="M343.5,-45C343.5,-45 363.68,-37.78 383.17,-30.81"/>
<polygon fill="black" stroke="black" points="384.36,-34.11 392.59,-27.44 382,-27.52 384.36,-34.11"/>
</g>
<!-- ebc3567e8&#45;38c0&#45;4f5e&#45;ae50&#45;e43c49309c44&#45;&gt;ee7b841cb&#45;464c&#45;419a&#45;8bae&#45;3f806f9ec5c9 -->
<g id="e0d89edff&#45;2af6&#45;427d&#45;ac62&#45;d700b7d131be" class="edge">
<title>ebc3567e8&#45;38c0&#45;4f5e&#45;ae50&#45;e43c49309c44&#45;&gt;ee7b841cb&#45;464c&#45;419a&#45;8bae&#45;3f806f9ec5c9</title>
<path fill="none" stroke="black" d="M498.5,-45C498.5,-45 518.13,-45 537.37,-45"/>
<polygon fill="black" stroke="black" points="537.59,-48.5 547.59,-45 537.59,-41.5 537.59,-48.5"/>
</g>
<!-- e53a1df30&#45;9705&#45;4b08&#45;b0a8&#45;3263f4319ccc -->
<g id="e53a1df30&#45;9705&#45;4b08&#45;b0a8&#45;3263f4319ccc" class="node">
<title>e53a1df30&#45;9705&#45;4b08&#45;b0a8&#45;3263f4319ccc</title>
<ellipse fill="white" stroke="black" cx="11" cy="-45" rx="11" ry="11"/>
</g>
<!-- e19ab2931&#45;dc04&#45;48da&#45;bc8b&#45;a6445506d5c4 -->
<g id="e19ab2931&#45;dc04&#45;48da&#45;bc8b&#45;a6445506d5c4" class="node">
<title>e19ab2931&#45;dc04&#45;48da&#45;bc8b&#45;a6445506d5c4</title>
<path fill="#ffffcc" stroke="black" d="M100,-63C100,-63 70,-63 70,-63 64,-63 58,-57 58,-51 58,-51 58,-39 58,-39 58,-33 64,-27 70,-27 70,-27 100,-27 100,-27 106,-27 112,-33 112,-39 112,-39 112,-51 112,-51 112,-57 106,-63 100,-63"/>
<text text-anchor="middle" x="85" y="-42.6" font-size="8.00">A</text>
</g>
<!-- e808aba30&#45;b5eb&#45;469b&#45;b542&#45;d5a27f4588b7 -->
<g id="e808aba30&#45;b5eb&#45;469b&#45;b542&#45;d5a27f4588b7" class="node">
<title>e808aba30&#45;b5eb&#45;469b&#45;b542&#45;d5a27f4588b7</title>
<path fill="#ffffcc" stroke="black" d="M190,-63C190,-63 160,-63 160,-63 154,-63 148,-57 148,-51 148,-51 148,-39 148,-39 148,-33 154,-27 160,-27 160,-27 190,-27 190,-27 196,-27 202,-33 202,-39 202,-39 202,-51 202,-51 202,-57 196,-63 190,-63"/>
<text text-anchor="middle" x="175" y="-42.6" font-size="8.00">B</text>
</g>
<!-- ee7b841cb&#45;464c&#45;419a&#45;8bae&#45;3f806f9ec5c9 -->
<g id="ee7b841cb&#45;464c&#45;419a&#45;8bae&#45;3f806f9ec5c9" class="node">
<title>ee7b841cb&#45;464c&#45;419a&#45;8bae&#45;3f806f9ec5c9</title>
<path fill="#ffffcc" stroke="black" d="M590,-63C590,-63 560,-63 560,-63 554,-63 548,-57 548,-51 548,-51 548,-39 548,-39 548,-33 554,-27 560,-27 560,-27 590,-27 590,-27 596,-27 602,-33 602,-39 602,-39 602,-51 602,-51 602,-57 596,-63 590,-63"/>
<text text-anchor="middle" x="575" y="-42.6" font-size="8.00">F</text>
</g>
<!-- eeab80efd&#45;180c&#45;4fe1&#45;8e69&#45;9934b9ea0b09 -->
<g id="eeab80efd&#45;180c&#45;4fe1&#45;8e69&#45;9934b9ea0b09" class="node">
<title>eeab80efd&#45;180c&#45;4fe1&#45;8e69&#45;9934b9ea0b09</title>
<path fill="#ffffcc" stroke="black" d="M280,-63C280,-63 250,-63 250,-63 244,-63 238,-57 238,-51 238,-51 238,-39 238,-39 238,-33 244,-27 250,-27 250,-27 280,-27 280,-27 286,-27 292,-33 292,-39 292,-39 292,-51 292,-51 292,-57 286,-63 280,-63"/>
<text text-anchor="middle" x="265" y="-42.6" font-size="8.00">C</text>
</g>
<!-- e808e2a5f&#45;5092&#45;4189&#45;90b5&#45;8395b10cce91 -->
<g id="e808e2a5f&#45;5092&#45;4189&#45;90b5&#45;8395b10cce91" class="node">
<title>e808e2a5f&#45;5092&#45;4189&#45;90b5&#45;8395b10cce91</title>
<path fill="#ffffcc" stroke="black" d="M435,-90C435,-90 405,-90 405,-90 399,-90 393,-84 393,-78 393,-78 393,-66 393,-66 393,-60 399,-54 405,-54 405,-54 435,-54 435,-54 441,-54 447,-60 447,-66 447,-66 447,-78 447,-78 447,-84 441,-90 435,-90"/>
<text text-anchor="middle" x="420" y="-69.6" font-size="8.00">E</text>
</g>
<!-- eaf32a996&#45;30c2&#45;4603&#45;b9ef&#45;ae197503fc9b -->
<g id="eaf32a996&#45;30c2&#45;4603&#45;b9ef&#45;ae197503fc9b" class="node">
<title>eaf32a996&#45;30c2&#45;4603&#45;b9ef&#45;ae197503fc9b</title>
<path fill="#ffffcc" stroke="black" d="M435,-36C435,-36 405,-36 405,-36 399,-36 393,-30 393,-24 393,-24 393,-12 393,-12 393,-6 399,0 405,0 405,0 435,0 435,0 441,0 447,-6 447,-12 447,-12 447,-24 447,-24 447,-30 441,-36 435,-36"/>
<text text-anchor="middle" x="420" y="-15.6" font-size="8.00">D</text>
</g>
<!-- ea1411cd2&#45;ee63&#45;41c7&#45;a2dc&#45;1c7840253baa -->
<g id="ea1411cd2&#45;ee63&#45;41c7&#45;a2dc&#45;1c7840253baa" class="node">
<title>ea1411cd2&#45;ee63&#45;41c7&#45;a2dc&#45;1c7840253baa</title>
<polygon fill="white" stroke="black" points="342.5,-59.5 328,-45 342.5,-30.5 357,-45 342.5,-59.5"/>
<text text-anchor="start" x="334.26" y="-33" font-size="30.00">×</text>
</g>
<!-- ebc3567e8&#45;38c0&#45;4f5e&#45;ae50&#45;e43c49309c44 -->
<g id="ebc3567e8&#45;38c0&#45;4f5e&#45;ae50&#45;e43c49309c44" class="node">
<title>ebc3567e8&#45;38c0&#45;4f5e&#45;ae50&#45;e43c49309c44</title>
<polygon fill="white" stroke="black" points="497.5,-59.5 483,-45 497.5,-30.5 512,-45 497.5,-59.5"/>
<text text-anchor="start" x="489.26" y="-33" font-size="30.00">×</text>
</g>
<!-- e6ae57bba&#45;eded&#45;484d&#45;af11&#45;a5a1989a71ee -->
<g id="e6ae57bba&#45;eded&#45;484d&#45;af11&#45;a5a1989a71ee" class="node">
<title>e6ae57bba&#45;eded&#45;484d&#45;af11&#45;a5a1989a71ee</title>
<ellipse fill="white" stroke="black" stroke-width="3" cx="649" cy="-45" rx="11" ry="11"/>
</g>
</g>
</svg>

</figure>

## Scientific literature

The techniques implemented in this package are described in:

- [Split Miner process discovery technique in streaming process mining environments](https://findit.dtu.dk/en/catalog/64bc6ffbb3ea963131d70caf)  
A. Jarmolkowicz  
Master Thesis, DTU, Jun. 2023.

The Split Miner algorithm is presented in:

- [Split miner: automated discovery of accurate and simple business process models from event logs](https://doi.org/10.1007/s10115-018-1214-x)  
Augusto, A., Conforti, R., Dumas, M. *et al.*   
In *Knowledge and Information Systems* 59, 251-284 (2019)