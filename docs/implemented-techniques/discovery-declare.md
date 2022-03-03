## Dependency [![](https://jitpack.io/v/beamline/discovery-declare.svg)](https://jitpack.io/#beamline/discovery-declare)

To use these algorithms in your Java Maven project it is necessary to include, in the `pom.xml` file, the dependency:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>discovery-declare</artifactId>
    <version>master-SNAPSHOT</version>
</dependency>
```
See the [introduction page](index.md) for further instructions.


## Usage

It is possible to call the two miners `beamline.miners.declare.DeclareMinerLossyCounting` and `beamline.miners.declare.DeclareMinerBudgetLossyCounting` using the following:

```java linenums="1"
new DeclareMinerLossyCounting(
	0.001, // the maximal approximation error
	10 // the number of declare constraints to show
);
```
```java linenums="1"
new DeclareMinerBudgetLossyCounting(
	1000, // the available budget
	10 // the number of declare constraints to show
);
```

## Scientific literature

The techniques implemented in this package are described in:

- [Online Discovery of Declarative Process Models from Event Streams](https://andrea.burattin.net/publications/2015-tsc)  
A. Burattin, M. Cimitile, F. Maggi, A. Sperduti  
In IEEE Transactions on Services Computing, vol. 8 (2015), no. 6, pp. 833-846.