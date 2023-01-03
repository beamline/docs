## Dependency

To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the dependency:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>soft-conformance</artifactId>
    <version>master-SNAPSHOT</version>
</dependency>
```
See the [introduction page](index.md) for further instructions.

[![](https://jitpack.io/v/beamline/soft-conformance.svg)](https://jitpack.io/#beamline/soft-conformance)


## Usage

This conformance approach uses a descriptive model (i.e., a pattern of the observed behavior over a certain amount of time) which is not necessarily referring to the control-flow (e.g., it can be based on the social network of handover of work). To create such a model you need to specify the states and the probability of transitioning. Additionally, it is necessary to specify the likelihood of a random walk (i.e., the parameter &alpha;):

```java linenums="1"
PDFA reference = new PDFA();
reference.addNode("A");
reference.addNode("B");
reference.addNode("C");
reference.addEdge("A", "A", 0.2);
reference.addEdge("A", "B", 0.8);
reference.addEdge("B", "C", 1);

reference = WeightsNormalizer.normalize(reference, alpha);
```

The model can be visualized with
```java
PDFAVisualizer.getDot(reference).exportToSvg(new File("test.svg"));
```
<figure>

<svg width="296px" height="125px"
 viewBox="0.00 0.00 296.00 124.89" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<g id="graph0" class="graph" transform="scale(1.0 1.0) rotate(0.0) translate(4.0 120.889)">
<title>G</title>
<polygon fill="white" stroke="none" points="-4,4 -4,-120.889 292,-120.889 292,4 -4,4"/>
<!-- edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2 -->
<g id="edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2" class="node"><title>edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2</title>
<ellipse fill="none" stroke="black" cx="27" cy="-20.8894" rx="27" ry="18"/>
<text text-anchor="middle" x="27" y="-17.1894" font-family="Calibri" font-size="14.00">A</text>
</g>
<!-- edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2&#45;&gt;edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2 -->
<g id="ecc5822da&#45;d255&#45;44eb&#45;9852&#45;cc18ccb48075" class="edge"><title>edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2&#45;&gt;edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2</title>
<path fill="none" stroke="black" stroke-width="1.83333" d="M16.7224,-37.9268C14.6249,-47.7474 18.0508,-56.8894 27,-56.8894 32.5933,-56.8894 36.029,-53.3183 37.3071,-48.2424"/>
<polygon fill="black" stroke="black" stroke-width="1.83333" points="40.8063,-47.9167 37.2776,-37.9268 33.8063,-47.9368 40.8063,-47.9167"/>
<text text-anchor="middle" x="27" y="-60.6894" font-family="Calibri" font-size="14.00">0.27</text>
</g>
<!-- eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320 -->
<g id="eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320" class="node"><title>eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320</title>
<ellipse fill="none" stroke="black" cx="144" cy="-65.8894" rx="27" ry="18"/>
<text text-anchor="middle" x="144" y="-62.1894" font-family="Calibri" font-size="14.00">B</text>
</g>
<!-- edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2&#45;&gt;eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320 -->
<g id="e4ae834b4&#45;f0ea&#45;4728&#45;8fc4&#45;1604082c12a2" class="edge"><title>edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2&#45;&gt;eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320</title>
<path fill="none" stroke="black" stroke-width="3.33333" d="M43.5468,-35.4446C51.4889,-42.0866 61.6462,-49.4451 72,-53.8894 82.8181,-58.5331 95.2848,-61.3842 106.723,-63.1332"/>
<polygon fill="black" stroke="black" stroke-width="3.33333" points="106.495,-66.6328 116.862,-64.4493 107.396,-59.691 106.495,-66.6328"/>
<text text-anchor="middle" x="85.5" y="-64.6894" font-family="Calibri" font-size="14.00">0.57</text>
</g>
<!-- ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4 -->
<g id="ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4" class="node"><title>ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4</title>
<ellipse fill="none" stroke="black" cx="261" cy="-20.8894" rx="27" ry="18"/>
<text text-anchor="middle" x="261" y="-17.1894" font-family="Calibri" font-size="14.00">C</text>
</g>
<!-- edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2&#45;&gt;ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4 -->
<g id="e59f6fed1&#45;fcd8&#45;494b&#45;a784&#45;2642294c704d" class="edge"><title>edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2&#45;&gt;ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4</title>
<path fill="none" stroke="black" stroke-width="1.33333" d="M54.1624,-20.8894C95.697,-20.8894 176.825,-20.8894 223.875,-20.8894"/>
<polygon fill="black" stroke="black" stroke-width="1.33333" points="223.933,-24.3895 233.933,-20.8894 223.933,-17.3895 223.933,-24.3895"/>
<text text-anchor="middle" x="144" y="-24.6894" font-family="Calibri" font-size="14.00">0.17</text>
</g>
<!-- eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320&#45;&gt;edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2 -->
<g id="eefd32215&#45;7913&#45;4a76&#45;8322&#45;817d81b46553" class="edge"><title>eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320&#45;&gt;edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2</title>
<path fill="none" stroke="black" stroke-width="1.33333" d="M126.445,-51.7239C118.591,-45.6849 108.794,-39.0792 99,-34.8894 88.122,-30.236 75.6395,-27.1117 64.2048,-25.0212"/>
<polygon fill="black" stroke="black" stroke-width="1.33333" points="64.5057,-21.5244 54.0743,-23.3778 63.3848,-28.434 64.5057,-21.5244"/>
<text text-anchor="middle" x="85.5" y="-38.6894" font-family="Calibri" font-size="14.00">0.17</text>
</g>
<!-- eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320&#45;&gt;eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320 -->
<g id="e02702fa9&#45;65f9&#45;4659&#45;8f8c&#45;75686e44e50f" class="edge"><title>eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320&#45;&gt;eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320</title>
<path fill="none" stroke="black" stroke-width="1.33333" d="M133.722,-82.9268C131.625,-92.7474 135.051,-101.889 144,-101.889 149.593,-101.889 153.029,-98.3183 154.307,-93.2424"/>
<polygon fill="black" stroke="black" stroke-width="1.33333" points="157.806,-92.9167 154.278,-82.9268 150.806,-92.9368 157.806,-92.9167"/>
<text text-anchor="middle" x="144" y="-105.689" font-family="Calibri" font-size="14.00">0.17</text>
</g>
<!-- eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320&#45;&gt;ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4 -->
<g id="e4f21f012&#45;a1ac&#45;47d2&#45;9072&#45;db824ce2dcb0" class="edge"><title>eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320&#45;&gt;ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4</title>
<path fill="none" stroke="black" stroke-width="3.83333" d="M171.138,-64.4493C184.928,-62.9618 201.87,-59.9547 216,-53.8894 223.118,-50.8339 230.144,-46.401 236.42,-41.7706"/>
<polygon fill="black" stroke="black" stroke-width="3.83333" points="238.762,-44.3812 244.453,-35.4446 234.431,-38.8817 238.762,-44.3812"/>
<text text-anchor="middle" x="202.5" y="-64.6894" font-family="Calibri" font-size="14.00">0.67</text>
</g>
<!-- ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4&#45;&gt;edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2 -->
<g id="e851e6087&#45;2c40&#45;4119&#45;a0ef&#45;7dd95ab540bb" class="edge"><title>ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4&#45;&gt;edf5adbb8&#45;1495&#45;49f7&#45;bf4d&#45;dae11812ecf2</title>
<path fill="none" stroke="black" stroke-width="1.33333" d="M235.668,-14.2474C217.903,-9.75423 193.154,-4.22789 171,-1.88945 147.133,0.629815 140.867,0.629815 117,-1.88945 98.6535,-3.82597 78.5275,-7.94872 62.0622,-11.8605"/>
<polygon fill="black" stroke="black" stroke-width="1.33333" points="61.2101,-8.46566 52.332,-14.2474 62.8779,-15.2641 61.2101,-8.46566"/>
<text text-anchor="middle" x="144" y="-5.68945" font-family="Calibri" font-size="14.00">0.17</text>
</g>
<!-- ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4&#45;&gt;eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320 -->
<g id="e0573f8e8&#45;58e4&#45;4bbd&#45;aba6&#45;1831e649c130" class="edge"><title>ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4&#45;&gt;eab3fce2a&#45;df45&#45;43e8&#45;9b62&#45;89ce28ff3320</title>
<path fill="none" stroke="black" stroke-width="1.33333" d="M233.926,-23.3778C220.153,-25.3422 203.208,-28.8115 189,-34.8894 182.42,-37.7044 175.838,-41.61 169.845,-45.7016"/>
<polygon fill="black" stroke="black" stroke-width="1.33333" points="167.588,-43.015 161.555,-51.7239 171.702,-48.6784 167.588,-43.015"/>
<text text-anchor="middle" x="202.5" y="-38.6894" font-family="Calibri" font-size="14.00">0.17</text>
</g>
<!-- ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4&#45;&gt;ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4 -->
<g id="edb6019b1&#45;89c4&#45;43a7&#45;b746&#45;5eb3bda6387f" class="edge"><title>ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4&#45;&gt;ea8b69327&#45;9b41&#45;4ca2&#45;90b3&#45;b6c8a50b04d4</title>
<path fill="none" stroke="black" stroke-width="1.33333" d="M250.722,-37.9268C248.625,-47.7474 252.051,-56.8894 261,-56.8894 266.593,-56.8894 270.029,-53.3183 271.307,-48.2424"/>
<polygon fill="black" stroke="black" stroke-width="1.33333" points="274.806,-47.9167 271.278,-37.9268 267.806,-47.9368 274.806,-47.9167"/>
<text text-anchor="middle" x="261" y="-60.6894" font-family="Calibri" font-size="14.00">0.17</text>
</g>
</g>
</svg>

</figure>

Please note that [these models can also be mined](discovery-soft.md).

Once a model is available, it is possible to use it for conformance checking with:

```java linenums="10"

PDFA reference = ...;
int maxCasesToStore = 1000; // max expected number of parallel process instances

PDFAConformance conformance = new PDFAConformance(reference, maxCasesToStore);
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env
    .addSource(source)
    .keyBy(BEvent::getTraceName)
    .flatMap(conformance)
    .addSink(new SinkFunction<SoftConformanceReport>(){
        public void invoke(SoftConformanceReport value) throws Exception {
            for(String caseId : value.keySet()) {
                System.out.println(
                    "Case: " + caseId + "\t" +
                    "soft conformance: " + value.get(caseId).getSoftConformance() + "\t" +
                    "mean of probs: " + value.get(caseId).getMeanProbabilities());
            }
        };
    });
env.execute();

```

It is worth highlighting that since each trace can be processed independently from the others, it is possible to increase the parallelism by keying the stream based on the case identifier (`BEvent::getTraceName`, line 17).

## Scientific literature

The techniques implemented in this package are described in:

- [Online Soft Conformance Checking: Any Perspective Can Indicate Deviations](https://andrea.burattin.net/publications/2022-arxiv)  
A. Burattin  
In arXiv:2201.09222, Jan. 2022.
