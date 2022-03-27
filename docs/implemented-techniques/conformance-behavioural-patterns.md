!!! bug "Old documentation - Content valid only for Beamline v. 0.1.0"
    The content of this page refers an old version of the library (0.1.0). The current version of Beamline uses completely different technology and thus the content migh be invalid.


## Dependency [![](https://jitpack.io/v/beamline/conformance-behavioural-patterns.svg)](https://jitpack.io/#beamline/conformance-behavioural-patterns)

To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the dependency:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>conformance-behavioural-patterns</artifactId>
    <version>master-SNAPSHOT</version>
</dependency>
```
See the [introduction page](index.md) for further instructions.


## Usage

To use the technique you need to create the conformance checker object using:

```java linenums="1"
SimpleConformance conformance = new SimpleConformance();
conformance.loadModel(new File("reference-model.tpn"));

conformance.setOnAfterEvent(new HookEventProcessing() {
    @Override
    public void trigger() {
        System.out.println(miner.getLatestResponse());
    }
});
```

In the current version, the reference model must be expressed as a Petri Net stored in TPN format. Additionally, in this version, the response is expressed as a `Pair<Integer, String>` object, where the first component is the cost of the execution of the current event (0 means the event was compliant, > 0 means the process was not compliant). The code above will print, after each event, the cost of the corresponding replay.

<div class="mermaid">
graph LR     
    ""
</div>

!!! note "TPN file format"
    A TPN file is just a text file where a Petri net is specified as the example below:
    <figure>
    <svg width="422pt" height="60pt"
     viewBox="0.00 0.00 422.00 60.00" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="graph0" class="graph" transform="scale(1 1) rotate(0) translate(4 56)">
    <title>G</title>
    <polygon fill="white" stroke="none" points="-4,4 -4,-56 418,-56 418,4 -4,4"/>
    <!-- t0 -->
    <g id="node1" class="node"><title>t0</title>
    <polygon fill="none" stroke="black" points="59,-34 36,-34 36,-17 59,-17 59,-34"/>
    <text text-anchor="middle" x="47.5" y="-23.6" font-family="Arial" font-size="8.00">A</text>
    </g>
    <!-- p1 -->
    <g id="node8" class="node"><title>p1</title>
    <ellipse fill="none" stroke="black" cx="88" cy="-25.5" rx="7" ry="7"/>
    </g>
    <!-- t0&#45;&gt;p1 -->
    <g id="edge3" class="edge"><title>t0&#45;&gt;p1</title>
    <path fill="none" stroke="black" d="M59.0203,-25.5C64.1215,-25.5 70.2604,-25.5 75.4866,-25.5"/>
    <polygon fill="black" stroke="black" points="75.7072,-27.2501 80.7071,-25.5 75.7071,-23.7501 75.7072,-27.2501"/>
    </g>
    <!-- t1 -->
    <g id="node2" class="node"><title>t1</title>
    <polygon fill="none" stroke="black" points="378,-34 356,-34 356,-17 378,-17 378,-34"/>
    <text text-anchor="middle" x="367" y="-23.6" font-family="Arial" font-size="8.00">B</text>
    </g>
    <!-- p3 -->
    <g id="node10" class="node"><title>p3</title>
    <ellipse fill="none" stroke="black" cx="407" cy="-25.5" rx="7" ry="7"/>
    </g>
    <!-- t1&#45;&gt;p3 -->
    <g id="edge2" class="edge"><title>t1&#45;&gt;p3</title>
    <path fill="none" stroke="black" d="M378.384,-25.5C383.419,-25.5 389.478,-25.5 394.636,-25.5"/>
    <polygon fill="black" stroke="black" points="394.789,-27.2501 399.789,-25.5 394.789,-23.7501 394.789,-27.2501"/>
    </g>
    <!-- t2 -->
    <g id="node3" class="node"><title>t2</title>
    <polygon fill="none" stroke="black" points="139,-34 117,-34 117,-17 139,-17 139,-34"/>
    <text text-anchor="middle" x="128" y="-23.6" font-family="Arial" font-size="8.00">C</text>
    </g>
    <!-- p0 -->
    <g id="node7" class="node"><title>p0</title>
    <ellipse fill="none" stroke="black" cx="168" cy="-25.5" rx="7" ry="7"/>
    </g>
    <!-- t2&#45;&gt;p0 -->
    <g id="edge8" class="edge"><title>t2&#45;&gt;p0</title>
    <path fill="none" stroke="black" d="M139.384,-25.5C144.419,-25.5 150.478,-25.5 155.636,-25.5"/>
    <polygon fill="black" stroke="black" points="155.789,-27.2501 160.789,-25.5 155.789,-23.7501 155.789,-27.2501"/>
    </g>
    <!-- t3 -->
    <g id="node4" class="node"><title>t3</title>
    <polygon fill="none" stroke="black" points="298,-34 276,-34 276,-17 298,-17 298,-34"/>
    <text text-anchor="middle" x="287" y="-23.6" font-family="Arial" font-size="8.00">D</text>
    </g>
    <!-- p4 -->
    <g id="node11" class="node"><title>p4</title>
    <ellipse fill="none" stroke="black" cx="327" cy="-25.5" rx="7" ry="7"/>
    </g>
    <!-- t3&#45;&gt;p4 -->
    <g id="edge10" class="edge"><title>t3&#45;&gt;p4</title>
    <path fill="none" stroke="black" d="M298.384,-25.5C303.419,-25.5 309.478,-25.5 314.636,-25.5"/>
    <polygon fill="black" stroke="black" points="314.789,-27.2501 319.789,-25.5 314.789,-23.7501 314.789,-27.2501"/>
    </g>
    <!-- t4 -->
    <g id="node5" class="node"><title>t4</title>
    <polygon fill="none" stroke="black" points="218,-52 197,-52 197,-35 218,-35 218,-52"/>
    <text text-anchor="middle" x="207.5" y="-41.6" font-family="Arial" font-size="8.00">E</text>
    </g>
    <!-- p2 -->
    <g id="node9" class="node"><title>p2</title>
    <ellipse fill="none" stroke="black" cx="247" cy="-25.5" rx="7" ry="7"/>
    </g>
    <!-- t4&#45;&gt;p2 -->
    <g id="edge11" class="edge"><title>t4&#45;&gt;p2</title>
    <path fill="none" stroke="black" d="M218.353,-38.7707C223.669,-36.2187 230.228,-33.0704 235.623,-30.4808"/>
    <polygon fill="black" stroke="black" points="236.431,-32.0341 240.182,-28.2928 234.917,-28.8788 236.431,-32.0341"/>
    </g>
    <!-- t5 -->
    <g id="node6" class="node"><title>t5</title>
    <polygon fill="none" stroke="black" points="218,-17 197,-17 197,-0 218,-0 218,-17"/>
    <text text-anchor="middle" x="207.5" y="-6.6" font-family="Arial" font-size="8.00">F</text>
    </g>
    <!-- t5&#45;&gt;p2 -->
    <g id="edge12" class="edge"><title>t5&#45;&gt;p2</title>
    <path fill="none" stroke="black" d="M218.353,-12.9665C223.669,-15.3767 230.228,-18.3502 235.623,-20.7959"/>
    <polygon fill="black" stroke="black" points="234.905,-22.3918 240.182,-22.8624 236.35,-19.204 234.905,-22.3918"/>
    </g>
    <!-- p0&#45;&gt;t4 -->
    <g id="edge6" class="edge"><title>p0&#45;&gt;t4</title>
    <path fill="none" stroke="black" d="M174.533,-28.156C179.209,-30.4003 186.116,-33.7156 192.314,-36.6908"/>
    <polygon fill="black" stroke="black" points="191.602,-38.2902 196.867,-38.8762 193.117,-35.1349 191.602,-38.2902"/>
    </g>
    <!-- p0&#45;&gt;t5 -->
    <g id="edge7" class="edge"><title>p0&#45;&gt;t5</title>
    <path fill="none" stroke="black" d="M174.859,-22.8438C179.43,-20.7718 185.981,-17.802 191.938,-15.1015"/>
    <polygon fill="black" stroke="black" points="192.914,-16.5805 196.745,-12.9222 191.469,-13.3928 192.914,-16.5805"/>
    </g>
    <!-- p1&#45;&gt;t2 -->
    <g id="edge5" class="edge"><title>p1&#45;&gt;t2</title>
    <path fill="none" stroke="black" d="M95.2749,-25.5C99.794,-25.5 106.091,-25.5 111.884,-25.5"/>
    <polygon fill="black" stroke="black" points="111.997,-27.2501 116.997,-25.5 111.997,-23.7501 111.997,-27.2501"/>
    </g>
    <!-- p2&#45;&gt;t3 -->
    <g id="edge9" class="edge"><title>p2&#45;&gt;t3</title>
    <path fill="none" stroke="black" d="M254.275,-25.5C258.794,-25.5 265.091,-25.5 270.884,-25.5"/>
    <polygon fill="black" stroke="black" points="270.997,-27.2501 275.997,-25.5 270.997,-23.7501 270.997,-27.2501"/>
    </g>
    <!-- p4&#45;&gt;t1 -->
    <g id="edge4" class="edge"><title>p4&#45;&gt;t1</title>
    <path fill="none" stroke="black" d="M334.275,-25.5C338.794,-25.5 345.091,-25.5 350.884,-25.5"/>
    <polygon fill="black" stroke="black" points="350.997,-27.2501 355.997,-25.5 350.997,-23.7501 350.997,-27.2501"/>
    </g>
    <!-- p5 -->
    <g id="node12" class="node"><title>p5</title>
    <ellipse fill="none" stroke="black" cx="7" cy="-25.5" rx="7" ry="7"/>
    </g>
    <!-- p5&#45;&gt;t0 -->
    <g id="edge1" class="edge"><title>p5&#45;&gt;t0</title>
    <path fill="none" stroke="black" d="M14.0156,-25.5C18.4846,-25.5 24.798,-25.5 30.6722,-25.5"/>
    <polygon fill="black" stroke="black" points="30.8778,-27.2501 35.8778,-25.5 30.8778,-23.7501 30.8778,-27.2501"/>
    </g>
    </g>
    </svg>
    </figure>

    ```
    place "place_0";
    place "place_1";
    place "place_2";
    place "place_3";
    place "place_4";
    place "place_5" init 1;
    trans "t_7"~"A" in "place_5" out "place_1" ;
    trans "t_8"~"B" in "place_4" out "place_3" ;
    trans "t_9"~"C" in "place_1" out "place_0" ;
    trans "t_10"~"D" in "place_2" out "place_4" ;
    trans "t_11"~"E" in "place_0" out "place_2" ;
    trans "t_12"~"F" in "place_0" out "place_2" ;
    ```

In order to properly pre-process the Petri net, it is necessary to set up a [property file](https://en.wikipedia.org/wiki/.properties) called `javaOfflinePreProcessor.properties` with the following content:

```properties
JAVA_BIN = FULL_PATH_OF_THE_JAVA_EXECUTABLE
OFFLINE_PREPROCESSOR_JAR = FULL_PATH_OF_THE_PREPROCESSOR
```

The preprocessor can be downloaded from <https://github.com/beamline/conformance-behavioural-patterns/blob/master/src/main/resources/pre-processor/region-based-conformance-offline-preprocessor-v2.jar>.


## Scientific literature

The techniques implemented in this package are described in:

- [Online Conformance Checking Using Behavioural Patterns](https://andrea.burattin.net/publications/2018-bpm)  
A. Burattin, S. van Zelst, A. Armas-Cervantes, B. van Dongen, J. Carmona  
In Proceedings of BPM 2018; Sydney, Australia; September 2018.
