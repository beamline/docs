This page lists the streaming process mining techniques currently implemented in the Beamline Framework.
To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the package repository:
```xml
<repositories>
    <repository>
        <id>jitpack.io</id>
        <url>https://jitpack.io</url>
    </repository>
</repositories>
```
Then, for each technique to be used, corresponding depepdencies should be includeded as well.

Control-flow discovery techniques implemented:

- [Trivial miner](discovery-trivial.md)
- [Heuristics miner](discovery-heuristics-miner.md)
- [Declare miner](discovery-declare.md)
- [DCR Miner](discovery-dcr.md)
- [Soft Conformance Model Miner](discovery-soft.md)
- [Split Miner](discovery-splitminer.md)

Conformance checking techniques implemented:

- [Behavioural Patterns](conformance-behavioural-patterns.md)
- [Soft Conformance](conformance-soft.md)

Random generation of processes and simulation:

- [Simulation with PLG](simulation-plg.md)