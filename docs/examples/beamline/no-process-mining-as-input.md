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

To accomplish our goal, we need first to define a source capable of processing the file:
```java linenums="1"
BeamlineAbstractSource customSource = new BeamlineAbstractSource() {
   @Override
   public void run(SourceContext<BEvent> ctx) throws Exception {
      Files.lines(Path.of(logFile)).forEach(line -> {
         String caseId = line.substring(0, 3);
         String activityName = line.substring(3);
         
         try {
            ctx.collect(BEvent.create("my-process-name", caseId, activityName));
         } catch (EventException e) { }
      });
   }
};
```

Now, a stream of `BEvent`s is available and can be processed with any miner available, for example, using the [Trivial discovery miner](../implemented-techniques/discovery-trivial.md):

```java linenums="21"
StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
env
   .addSource(customSource)
   .keyBy(BEvent::getProcessName)
   .flatMap(new DirectlyFollowsDependencyDiscoveryMiner().setModelRefreshRate(1).setMinDependency(0.1))
   .addSink(new SinkFunction<ProcessMap>() {
      @Override
      public void invoke(ProcessMap value, Context context) throws Exception {
         value.generateDot().exportToSvg(new File("src/main/resources/output/output.svg"));
      };
   });
env.execute();
```

In this case, we configured the miner to consume all events and, once the stream is completed (in this case we do know that the stream will terminate) we dump the result of the miner into a file `output.svg` which will contain the following model:
<figure>
<svg width="94px" height="249px"
 viewBox="0.00 0.00 94.00 249.00" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<g id="graph0" class="graph" transform="scale(1.0 1.0) rotate(0.0) translate(4.0 245.0)">
<title>G</title>
<polygon fill="white" stroke="none" points="-4,4 -4,-245 90,-245 90,4 -4,4"/>
<!-- e6def0aa8&#45;a25c&#45;48d9&#45;8be2&#45;b6873af41849&#45;&gt;e6fd0d0c8&#45;9bf8&#45;41b4&#45;b32c&#45;27d996d529ec -->
<g id="e32ade99e&#45;1277&#45;410b&#45;8854&#45;5f7f6ab31bf6" class="edge"><title>e6def0aa8&#45;a25c&#45;48d9&#45;8be2&#45;b6873af41849&#45;&gt;e6fd0d0c8&#45;9bf8&#45;41b4&#45;b32c&#45;27d996d529ec</title>
<path fill="none" stroke="#252526" stroke-width="9" d="M43,-185.5C43,-185.5 43,-164.451 43,-146.496"/>
<polygon fill="#252526" stroke="#252526" stroke-width="9" points="46.9376,-146.05 43,-141.05 39.0626,-146.05 46.9376,-146.05"/>
<text text-anchor="middle" x="56.5" y="-151.6" font-family="Arial" font-size="8.00"> 1.0 (2)</text>
</g>
<!-- e6fd0d0c8&#45;9bf8&#45;41b4&#45;b32c&#45;27d996d529ec&#45;&gt;efed7b698&#45;4a16&#45;44d5&#45;99db&#45;2afa47a4c8e4 -->
<g id="eead91c39&#45;b40a&#45;4130&#45;8602&#45;f99a0ca6324e" class="edge"><title>e6fd0d0c8&#45;9bf8&#45;41b4&#45;b32c&#45;27d996d529ec&#45;&gt;efed7b698&#45;4a16&#45;44d5&#45;99db&#45;2afa47a4c8e4</title>
<path fill="none" stroke="#252526" stroke-width="9" d="M43,-119.5C43,-119.5 43,-98.4513 43,-80.4961"/>
<polygon fill="#252526" stroke="#252526" stroke-width="9" points="46.9376,-80.0498 43,-75.0499 39.0626,-80.0499 46.9376,-80.0498"/>
<text text-anchor="middle" x="56.5" y="-85.6" font-family="Arial" font-size="8.00"> 1.0 (2)</text>
</g>
<!-- efed7b698&#45;4a16&#45;44d5&#45;99db&#45;2afa47a4c8e4&#45;&gt;e05520936&#45;aa17&#45;4739&#45;bad0&#45;7d560003a923 -->
<g id="e6c1c1bff&#45;f27a&#45;4fc9&#45;8bc6&#45;6cba75b561dd" class="edge"><title>efed7b698&#45;4a16&#45;44d5&#45;99db&#45;2afa47a4c8e4&#45;&gt;e05520936&#45;aa17&#45;4739&#45;bad0&#45;7d560003a923</title>
<path fill="none" stroke="#c2b0ab" stroke-width="2" stroke-dasharray="5,2" d="M43,-53.5C43,-53.5 43,-28.2972 43,-14.4159"/>
<polygon fill="#c2b0ab" stroke="#c2b0ab" stroke-width="2" points="44.7501,-14.2664 43,-9.26648 41.2501,-14.2665 44.7501,-14.2664"/>
<text text-anchor="middle" x="44.5" y="-19.6" font-family="Arial" font-size="8.00"> </text>
</g>
<!-- ef4d5585f&#45;76e4&#45;451b&#45;badf&#45;d504407d9581&#45;&gt;e6def0aa8&#45;a25c&#45;48d9&#45;8be2&#45;b6873af41849 -->
<g id="ebad29131&#45;9e3f&#45;45df&#45;837c&#45;23f259000f04" class="edge"><title>ef4d5585f&#45;76e4&#45;451b&#45;badf&#45;d504407d9581&#45;&gt;e6def0aa8&#45;a25c&#45;48d9&#45;8be2&#45;b6873af41849</title>
<path fill="none" stroke="#acb89c" stroke-width="2" stroke-dasharray="5,2" d="M43,-235.5C43,-235.5 43,-223.872 43,-212.062"/>
<polygon fill="#acb89c" stroke="#acb89c" stroke-width="2" points="44.7501,-212.023 43,-207.023 41.2501,-212.023 44.7501,-212.023"/>
<text text-anchor="middle" x="44.5" y="-217.6" font-family="Arial" font-size="8.00"> </text>
</g>
<!-- e6def0aa8&#45;a25c&#45;48d9&#45;8be2&#45;b6873af41849 -->
<g id="e6def0aa8&#45;a25c&#45;48d9&#45;8be2&#45;b6873af41849" class="node"><title>e6def0aa8&#45;a25c&#45;48d9&#45;8be2&#45;b6873af41849</title>
<path fill="#0b4971" stroke="black" d="M74,-207C74,-207 12,-207 12,-207 6,-207 0,-201 0,-195 0,-195 0,-178 0,-178 0,-172 6,-166 12,-166 12,-166 74,-166 74,-166 80,-166 86,-172 86,-178 86,-178 86,-195 86,-195 86,-201 80,-207 74,-207"/>
<text text-anchor="start" x="18" y="-186.4" font-family="Arial" font-size="22.00" fill="#ffffff">ActA</text>
<text text-anchor="start" x="64" y="-186.4" font-family="Arial" font-size="14.00" fill="#ffffff"> </text>
<text text-anchor="start" x="27" y="-173.2" font-family="Arial" font-size="11.00" fill="#ffffff">1.0 (2)</text>
</g>
<!-- e6fd0d0c8&#45;9bf8&#45;41b4&#45;b32c&#45;27d996d529ec -->
<g id="e6fd0d0c8&#45;9bf8&#45;41b4&#45;b32c&#45;27d996d529ec" class="node"><title>e6fd0d0c8&#45;9bf8&#45;41b4&#45;b32c&#45;27d996d529ec</title>
<path fill="#0b4971" stroke="black" d="M74,-141C74,-141 12,-141 12,-141 6,-141 0,-135 0,-129 0,-129 0,-112 0,-112 0,-106 6,-100 12,-100 12,-100 74,-100 74,-100 80,-100 86,-106 86,-112 86,-112 86,-129 86,-129 86,-135 80,-141 74,-141"/>
<text text-anchor="start" x="33.5" y="-120.4" font-family="Arial" font-size="22.00" fill="#ffffff">B</text>
<text text-anchor="start" x="48.5" y="-120.4" font-family="Arial" font-size="14.00" fill="#ffffff"> </text>
<text text-anchor="start" x="27" y="-107.2" font-family="Arial" font-size="11.00" fill="#ffffff">1.0 (2)</text>
</g>
<!-- efed7b698&#45;4a16&#45;44d5&#45;99db&#45;2afa47a4c8e4 -->
<g id="efed7b698&#45;4a16&#45;44d5&#45;99db&#45;2afa47a4c8e4" class="node"><title>efed7b698&#45;4a16&#45;44d5&#45;99db&#45;2afa47a4c8e4</title>
<path fill="#0b4971" stroke="black" d="M74,-75C74,-75 12,-75 12,-75 6,-75 0,-69 0,-63 0,-63 0,-46 0,-46 0,-40 6,-34 12,-34 12,-34 74,-34 74,-34 80,-34 86,-40 86,-46 86,-46 86,-63 86,-63 86,-69 80,-75 74,-75"/>
<text text-anchor="start" x="11" y="-54.4" font-family="Arial" font-size="22.00" fill="#ffffff">Act_C</text>
<text text-anchor="start" x="71" y="-54.4" font-family="Arial" font-size="14.00" fill="#ffffff"> </text>
<text text-anchor="start" x="27" y="-41.2" font-family="Arial" font-size="11.00" fill="#ffffff">1.0 (2)</text>
</g>
<!-- ef4d5585f&#45;76e4&#45;451b&#45;badf&#45;d504407d9581 -->
<g id="ef4d5585f&#45;76e4&#45;451b&#45;badf&#45;d504407d9581" class="node"><title>ef4d5585f&#45;76e4&#45;451b&#45;badf&#45;d504407d9581</title>
<ellipse fill="#ced6bd" stroke="#595f45" cx="43" cy="-236.5" rx="4.5" ry="4.5"/>
</g>
<!-- e05520936&#45;aa17&#45;4739&#45;bad0&#45;7d560003a923 -->
<g id="e05520936&#45;aa17&#45;4739&#45;bad0&#45;7d560003a923" class="node"><title>e05520936&#45;aa17&#45;4739&#45;bad0&#45;7d560003a923</title>
<ellipse fill="#d8bbb9" stroke="#614847" cx="43" cy="-4.5" rx="4.5" ry="4.5"/>
</g>
</g>
</svg>

</figure>

The complete code of this example is available in the GitHub repository <https://github.com/beamline/examples/tree/master/src/main/java/beamline/examples/rawData>.