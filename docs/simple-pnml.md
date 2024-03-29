# Simple PNML

`simple-pnml` is a library to describe Petri nets and [de]serialize them as PNML XML files.

> **Attention:** this library is actually the porting of the **ProM PetriNets package**, which has been isolated out of the ProM environment and has been made available as Maven dependency. Therefore, the authors of this simple-pnml library are the authors of the ProM version of the PetriNets package (module some changes made by Andrea Burattin for isolating the library from ProM and making it self-contained). The ProM package PetriNets is licensed as L-GPL so this distribution is as well. The original source code of the ProM PetriNets package is located at <https://svn.win.tue.nl/repos/prom/Packages/PetriNets/>. The ProM packages licenses are discussed in <http://www.promtools.org/doku.php?id=packlicense> and for general information on ProM you can visit <http://www.promtools.org/>.



### Installing the library

To use the library in your Maven project it is necessary to include, in the `pom.xml` file, the package repository:
```xml
<repositories>
    <repository>
        <id>jitpack.io</id>
        <url>https://jitpack.io</url>
    </repository>
</repositories>
```
Then you can include the dependency to the version you are interested, for example:
```xml
<dependency>
    <groupId>com.github.beamline</groupId>
    <artifactId>simple-pnml</artifactId>
    <version>0.0.1</version>
</dependency>
```
See <https://jitpack.io/#beamline/simple-pnml> for further details (e.g., using it with Gradle).


### Importing a Petri net from a PNML file

To import a Petri net from a PNML file you can use the following code:

```java
Object[] i = PnmlImportNet.importFromStream(new FileInputStream(new File("file.pnml")));

Petrinet net = (Petrinet) i[0];
Marking marking = (Marking) i[1];
```

### Importing a Petri net from a TPN file

To import a Petri net from a TPN file you can use the following code:

```java
Object[] i = TpnImport.importFromStream(new FileInputStream(new File("file.tpn")));

Petrinet net = (Petrinet) i[0];
Marking marking = (Marking) i[1];
```


### Exporting a Petri net into a PNML file

To export a Petri net into a PNML file you can use the following code:

```java
Petrinet net = ...;
Marking marking = ...;

PnmlExportNetToPNML.exportPetriNetToPNMLFile(net, marking, new File("file.pnml"));
```