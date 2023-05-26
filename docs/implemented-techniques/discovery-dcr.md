# Discovery DCR

## Dependency

To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the dependency:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>discovery-dcr</artifactId>
    <version>beamline-framework-SNAPSHOT</version>
</dependency>
```
See the [introduction page](index.md) for further instructions.

[![](https://jitpack.io/v/beamline/discovery-dcr.svg)](https://jitpack.io/#beamline/discovery-dcr)


## Usage

To construct a DCR miner it is possible to construct it with the following code:

```java linenums="1"
Reflections reflections = new Reflections("beamline");
DFGBasedMiner miner = new DFGBasedMiner(reflections.getTypesAnnotatedWith(ExposedDcrPattern.class));
```
In this case we use `Reflections` to identify and provide all the classes annoted with the `@ExposedDcrPattern`.

It is possible (though not necessary) to configure the miner with the following parameters:

```java linenums="3"
// configuration of the refresh rate (i.e., how many events between models update)
model.setModelRefreshRate(1);

// configuration of list of patters
miner.setDcrPatternsForMining("Response", "Condition", "Include", "Exclude");

// configuration of the miner type
miner.setStreamMinerType(new UnlimitedStreamMiner());
//miner.setStreamMinerType(new SlidingWindowStreamMiner(15, 500));

// configure which constraints to visualize
miner.setDcrConstraintsForVisualization(RELATION.CONDITION, RELATION.RESPONSE);

// configure the threshold
miner.setRelationsThreshold(0);

// configure the transitive reduction
miner.setTransitiveReductionList(RELATION.CONDITION, RELATION.RESPONSE);
```

Once the miner is properly configured, it can be used as any other consumer. For example, using the following code:
```java linenums="21"
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env
    .addSource(new StringTestSource("ABCDF", "ABCEF"))
    .keyBy(BEvent::getProcessName)
    .flatMap(miner)
    .addSink(new SinkFunction<DeclareModelView>(){
        public void invoke(DeclareModelView value, Context context) throws Exception {
            value.generateDot().exportToSvg(new File("output.svg"));
        };
    });
env.execute();

```

An example of the output produced is:
<figure>

<svg width="134px" height="332px"
 viewBox="0.00 0.00 134.00 332.00" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<g id="graph0" class="graph" transform="scale(1.0 1.0) rotate(0.0) translate(4.0 328.0)">
<title>G</title>
<polygon fill="white" stroke="none" points="-4,4 -4,-328 130,-328 130,4 -4,4"/>
<!-- e578f0930&#45;aba5&#45;467e&#45;880d&#45;bca6ba0b097a -->
<g id="e578f0930&#45;aba5&#45;467e&#45;880d&#45;bca6ba0b097a" class="node"><title>e578f0930&#45;aba5&#45;467e&#45;880d&#45;bca6ba0b097a</title>
<polygon fill="#f8f6ec" stroke="#cbcbcb" points="90,-252 36,-252 36,-216 90,-216 90,-252"/>
<text text-anchor="middle" x="63" y="-231.5" font-family="arial" font-size="10.00">B</text>
</g>
<!-- e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734 -->
<g id="e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734" class="node"><title>e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734</title>
<polygon fill="#f8f6ec" stroke="#cbcbcb" points="90,-180 36,-180 36,-144 90,-144 90,-180"/>
<text text-anchor="middle" x="63" y="-159.5" font-family="arial" font-size="10.00">C</text>
</g>
<!-- e578f0930&#45;aba5&#45;467e&#45;880d&#45;bca6ba0b097a&#45;&gt;e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734 -->
<g id="e9f1df9d6&#45;9481&#45;476c&#45;9972&#45;428b54fb3119" class="edge"><title>e578f0930&#45;aba5&#45;467e&#45;880d&#45;bca6ba0b097a&#45;&gt;e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734</title>
<path fill="none" stroke="#2993fc" d="M56.7174,-211.496C56.1104,-203.146 56.0946,-193.586 56.6702,-185.173"/>
<ellipse fill="#2993fc" stroke="#2993fc" cx="56.9102" cy="-213.704" rx="2" ry="2"/>
<polygon fill="#2993fc" stroke="#2993fc" points="58.4212,-185.236 57.105,-180.104 54.934,-184.936 58.4212,-185.236"/>
</g>
<!-- e578f0930&#45;aba5&#45;467e&#45;880d&#45;bca6ba0b097a&#45;&gt;e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734 -->
<g id="e860cfbe0&#45;665d&#45;40a9&#45;a2db&#45;cc4e66681c82" class="edge"><title>e578f0930&#45;aba5&#45;467e&#45;880d&#45;bca6ba0b097a&#45;&gt;e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734</title>
<path fill="none" stroke="#ffa500" d="M68.9157,-215.697C69.7377,-207.728 69.9523,-198.1 69.5595,-189.264"/>
<ellipse fill="#ffa500" stroke="#ffa500" cx="69.0398" cy="-182.099" rx="2" ry="2"/>
<polygon fill="#ffa500" stroke="#ffa500" points="71.2917,-188.954 69.1845,-184.094 67.8009,-189.207 71.2917,-188.954"/>
</g>
<!-- e3677451c&#45;681d&#45;46aa&#45;94c8&#45;b6a991735be3 -->
<g id="e3677451c&#45;681d&#45;46aa&#45;94c8&#45;b6a991735be3" class="node"><title>e3677451c&#45;681d&#45;46aa&#45;94c8&#45;b6a991735be3</title>
<polygon fill="#f8f6ec" stroke="#cbcbcb" points="54,-108 0,-108 0,-72 54,-72 54,-108"/>
<text text-anchor="middle" x="27" y="-87.5" font-family="arial" font-size="10.00">D</text>
</g>
<!-- e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734&#45;&gt;e3677451c&#45;681d&#45;46aa&#45;94c8&#45;b6a991735be3 -->
<g id="e2efb5638&#45;5f1d&#45;45be&#45;9769&#45;ef2545ce1a85" class="edge"><title>e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734&#45;&gt;e3677451c&#45;681d&#45;46aa&#45;94c8&#45;b6a991735be3</title>
<path fill="none" stroke="#ffa500" d="M48.1854,-143.697C43.1085,-135.474 37.7689,-125.483 33.5534,-116.421"/>
<ellipse fill="#ffa500" stroke="#ffa500" cx="30.7056" cy="-109.936" rx="2.00001" ry="2.00001"/>
<polygon fill="#ffa500" stroke="#ffa500" points="35.1225,-115.641 31.5098,-111.767 31.9178,-117.048 35.1225,-115.641"/>
</g>
<!-- e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734&#45;&gt;e3677451c&#45;681d&#45;46aa&#45;94c8&#45;b6a991735be3 -->
<g id="ef32502f0&#45;7862&#45;434f&#45;8321&#45;aeb098e50b80" class="edge"><title>e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734&#45;&gt;e3677451c&#45;681d&#45;46aa&#45;94c8&#45;b6a991735be3</title>
<path fill="none" stroke="#2993fc" d="M58.342,-139.765C54.5787,-131.209 49.5192,-121.347 44.4804,-112.74"/>
<ellipse fill="#2993fc" stroke="#2993fc" cx="59.233" cy="-141.857" rx="2.00001" ry="2.00001"/>
<polygon fill="#2993fc" stroke="#2993fc" points="45.7686,-111.487 41.6915,-108.104 42.7694,-113.291 45.7686,-111.487"/>
</g>
<!-- ec24f6d71&#45;e3be&#45;4240&#45;8cc5&#45;18467c2ba26e -->
<g id="ec24f6d71&#45;e3be&#45;4240&#45;8cc5&#45;18467c2ba26e" class="node"><title>ec24f6d71&#45;e3be&#45;4240&#45;8cc5&#45;18467c2ba26e</title>
<polygon fill="#f8f6ec" stroke="#cbcbcb" points="126,-108 72,-108 72,-72 126,-72 126,-108"/>
<text text-anchor="middle" x="99" y="-87.5" font-family="arial" font-size="10.00">K</text>
</g>
<!-- e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734&#45;&gt;ec24f6d71&#45;e3be&#45;4240&#45;8cc5&#45;18467c2ba26e -->
<g id="eabd67ac4&#45;8654&#45;4ff4&#45;8943&#45;8a12a3a6aaa8" class="edge"><title>e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734&#45;&gt;ec24f6d71&#45;e3be&#45;4240&#45;8cc5&#45;18467c2ba26e</title>
<path fill="none" stroke="#2993fc" d="M67.658,-139.765C71.4213,-131.209 76.4808,-121.347 81.5196,-112.74"/>
<ellipse fill="#2993fc" stroke="#2993fc" cx="66.767" cy="-141.857" rx="2.00001" ry="2.00001"/>
<polygon fill="#2993fc" stroke="#2993fc" points="83.2306,-113.291 84.3085,-108.104 80.2314,-111.487 83.2306,-113.291"/>
</g>
<!-- e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734&#45;&gt;ec24f6d71&#45;e3be&#45;4240&#45;8cc5&#45;18467c2ba26e -->
<g id="e3e27f89e&#45;c93d&#45;4a9f&#45;a7ec&#45;364cfae8dd00" class="edge"><title>e67c9c115&#45;c541&#45;48e8&#45;80e5&#45;6901bb8b4734&#45;&gt;ec24f6d71&#45;e3be&#45;4240&#45;8cc5&#45;18467c2ba26e</title>
<path fill="none" stroke="#ffa500" d="M77.8146,-143.697C82.8915,-135.474 88.2311,-125.483 92.4466,-116.421"/>
<ellipse fill="#ffa500" stroke="#ffa500" cx="95.2944" cy="-109.936" rx="2.00001" ry="2.00001"/>
<polygon fill="#ffa500" stroke="#ffa500" points="94.0822,-117.048 94.4902,-111.767 90.8775,-115.641 94.0822,-117.048"/>
</g>
<!-- eba1a3825&#45;bd6b&#45;4990&#45;bb2a&#45;9995b74ff782 -->
<g id="eba1a3825&#45;bd6b&#45;4990&#45;bb2a&#45;9995b74ff782" class="node"><title>eba1a3825&#45;bd6b&#45;4990&#45;bb2a&#45;9995b74ff782</title>
<polygon fill="#f8f6ec" stroke="#cbcbcb" points="54,-36 0,-36 0,-0 54,-0 54,-36"/>
<text text-anchor="middle" x="27" y="-15.5" font-family="arial" font-size="10.00">E</text>
</g>
<!-- e3677451c&#45;681d&#45;46aa&#45;94c8&#45;b6a991735be3&#45;&gt;eba1a3825&#45;bd6b&#45;4990&#45;bb2a&#45;9995b74ff782 -->
<g id="e2317ff2c&#45;1bf8&#45;4b01&#45;aa23&#45;dcbcb5545884" class="edge"><title>e3677451c&#45;681d&#45;46aa&#45;94c8&#45;b6a991735be3&#45;&gt;eba1a3825&#45;bd6b&#45;4990&#45;bb2a&#45;9995b74ff782</title>
<path fill="none" stroke="#2993fc" d="M20.7174,-67.4955C20.1104,-59.1456 20.0946,-49.5856 20.6702,-41.173"/>
<ellipse fill="#2993fc" stroke="#2993fc" cx="20.9102" cy="-69.7042" rx="2" ry="2"/>
<polygon fill="#2993fc" stroke="#2993fc" points="22.4212,-41.2356 21.105,-36.1043 18.934,-40.9364 22.4212,-41.2356"/>
</g>
<!-- e3677451c&#45;681d&#45;46aa&#45;94c8&#45;b6a991735be3&#45;&gt;eba1a3825&#45;bd6b&#45;4990&#45;bb2a&#45;9995b74ff782 -->
<g id="ee6b71ca8&#45;47d8&#45;4b7e&#45;a165&#45;6d65d8056f7a" class="edge"><title>e3677451c&#45;681d&#45;46aa&#45;94c8&#45;b6a991735be3&#45;&gt;eba1a3825&#45;bd6b&#45;4990&#45;bb2a&#45;9995b74ff782</title>
<path fill="none" stroke="#ffa500" d="M32.9157,-71.6966C33.7377,-63.7284 33.9523,-54.0995 33.5595,-45.2641"/>
<ellipse fill="#ffa500" stroke="#ffa500" cx="33.0398" cy="-38.0991" rx="2" ry="2"/>
<polygon fill="#ffa500" stroke="#ffa500" points="35.2917,-44.9541 33.1845,-40.0938 31.8009,-45.2074 35.2917,-44.9541"/>
</g>
<!-- e4b48c5a5&#45;016c&#45;458c&#45;b830&#45;243e25a8c96d -->
<g id="e4b48c5a5&#45;016c&#45;458c&#45;b830&#45;243e25a8c96d" class="node"><title>e4b48c5a5&#45;016c&#45;458c&#45;b830&#45;243e25a8c96d</title>
<polygon fill="#f8f6ec" stroke="#cbcbcb" points="90,-324 36,-324 36,-288 90,-288 90,-324"/>
<text text-anchor="middle" x="63" y="-303.5" font-family="arial" font-size="10.00">A</text>
</g>
<!-- e4b48c5a5&#45;016c&#45;458c&#45;b830&#45;243e25a8c96d&#45;&gt;e578f0930&#45;aba5&#45;467e&#45;880d&#45;bca6ba0b097a -->
<g id="e7f526626&#45;2b97&#45;46c5&#45;8c5e&#45;e758a95d7821" class="edge"><title>e4b48c5a5&#45;016c&#45;458c&#45;b830&#45;243e25a8c96d&#45;&gt;e578f0930&#45;aba5&#45;467e&#45;880d&#45;bca6ba0b097a</title>
<path fill="none" stroke="#2993fc" d="M56.7174,-283.496C56.1104,-275.146 56.0946,-265.586 56.6702,-257.173"/>
<ellipse fill="#2993fc" stroke="#2993fc" cx="56.9102" cy="-285.704" rx="2" ry="2"/>
<polygon fill="#2993fc" stroke="#2993fc" points="58.4212,-257.236 57.105,-252.104 54.934,-256.936 58.4212,-257.236"/>
</g>
<!-- e4b48c5a5&#45;016c&#45;458c&#45;b830&#45;243e25a8c96d&#45;&gt;e578f0930&#45;aba5&#45;467e&#45;880d&#45;bca6ba0b097a -->
<g id="e770e2439&#45;2bbf&#45;494c&#45;b232&#45;4a2a8e2d62bb" class="edge"><title>e4b48c5a5&#45;016c&#45;458c&#45;b830&#45;243e25a8c96d&#45;&gt;e578f0930&#45;aba5&#45;467e&#45;880d&#45;bca6ba0b097a</title>
<path fill="none" stroke="#ffa500" d="M68.9157,-287.697C69.7377,-279.728 69.9523,-270.1 69.5595,-261.264"/>
<ellipse fill="#ffa500" stroke="#ffa500" cx="69.0398" cy="-254.099" rx="2" ry="2"/>
<polygon fill="#ffa500" stroke="#ffa500" points="71.2917,-260.954 69.1845,-256.094 67.8009,-261.207 71.2917,-260.954"/>
</g>
</g>
</svg>


</figure>



## Scientific literature

The techniques implemented in this package are described in:

- Uncovering Change: A Streaming Approach for Declarative Processes   
A. Burattin, H. A. López, L. Starklit  
In *Proceedings of ICPM Workshop* (SA4PM), 2022.
