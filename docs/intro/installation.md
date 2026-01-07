## pyBeamline

pyBeamline is meant to work with Python 3.9 and above. Installation can be done via `pip`:

```
pip install pybeamline
```
More information are available at <https://pypi.org/project/pybeamline/>.



## JBeamline

To use JBeamline in your Java Maven project it is necessary to include, in the `pom.xml` file, the package repository:
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
    <artifactId>framework</artifactId>
    <version>x.y.z</version>
</dependency>
```
See <https://jitpack.io/#beamline/framework> for further details (e.g., using it with Gradle).
