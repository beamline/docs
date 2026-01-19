# Monitoring active windows (for Windows systems)

One possible usage of streaming process mining could involve the monitoring of the current system. One possible way of achieving this goal is to monitor the window currently active (i.e., with the focus) as a proxy for the application being used by the user[^1].

[^1]: It is important to emphasize that the active window might not really be the one that the user is currently using. For example, a user might be reading a webpage in a browser or a PDF document or another text document while having active another window.

To achieve this goal it is possible to define a new `XesSource` which observes the windows currently active and, whenever there is a new window in focus, emits an event. To accomplish this goal, in the following we make use of the [JNA (Java Native Access) library](https://en.wikipedia.org/wiki/Java_Native_Access) which gives us access to the native shared libraries of the operating system. To have access to the library we need, first of all, to include it in our Maven dependency:
```xml
<dependency>
	<groupId>net.java.dev.jna</groupId>
	<artifactId>jna</artifactId>
	<version>5.10.0</version>
</dependency>
<dependency>
	<groupId>net.java.dev.jna</groupId>
	<artifactId>jna-platform</artifactId>
	<version>5.10.0</version>
</dependency>
```

Once the library is include we can define the method that will return the name of the currently active window on the screen (this works and has been tested on Windows 10 Enterprise):

```java
class Informer {
	public static String getWindowName() {
		int MAX_TITLE_LENGTH = 1024;
		char[] buffer = new char[MAX_TITLE_LENGTH * 2];
		HWND hwnd = User32.INSTANCE.GetForegroundWindow();
		User32.INSTANCE.GetWindowText(hwnd, buffer, MAX_TITLE_LENGTH);
		
		IntByReference pid = new IntByReference();
		User32.INSTANCE.GetWindowThreadProcessId(hwnd, pid);
		HANDLE p = Kernel32.INSTANCE.OpenProcess(
				Kernel32.PROCESS_QUERY_INFORMATION | Kernel32.PROCESS_VM_READ,
				false,
				pid.getValue());
		Psapi.INSTANCE.GetModuleBaseNameW(p, null, buffer, MAX_TITLE_LENGTH);

		return Native.toString(buffer);
	}

	public interface Psapi extends StdCallLibrary {
		@SuppressWarnings("deprecation")
		Psapi INSTANCE = (Psapi) Native.loadLibrary("Psapi", Psapi.class);
		WinDef.DWORD GetModuleBaseNameW(HANDLE hProcess, HANDLE hModule, char[] lpBaseName, int nSize);
	}
}
```
The documentation on the system calls used here can be found on the MSDN documentation (here, for example, the documentation for the [`GetForegroundWindow` function](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getforegroundwindow)).

With this information it is now possible to wrap the code in a proper source:
```java
public class WindowsWindowMonitorSource implements BeamlineAbstractSource {

   private static final int POLLING_DELAY = 100; // milliseconds between checks of the active window

   @Override
   public void run(SourceContext<BEvent> ctx) throws Exception {
      Queue<BEvent> buffer = new LinkedList<>();
      
      String caseId = UUID.randomUUID().toString();
      new Thread(new Runnable() {
         @Override
         public void run() {
            String latestProcess = "";
            while(isRunning()) {
               String currentProcess = getWindowName();
               if (!currentProcess.isEmpty() && !currentProcess.equals(latestProcess)) {
                  latestProcess = currentProcess;
                  try {
                     buffer.add(BEvent.create("window", caseId, currentProcess));
                  } catch (EventException e) { }
               }
               
               try {
                  Thread.sleep(POLLING_DELAY);
               } catch (InterruptedException e) { }
            }
         }
      }).start();
      
      while(isRunning()) {
         while (isRunning() && buffer.isEmpty()) {
            Thread.sleep(100l);
         }
         if (isRunning()) {
            synchronized (ctx.getCheckpointLock()) {
               BEvent e = buffer.poll();
               ctx.collect(e);
            }
         }
      }
   }
}
```
The basic idea is to check every `POLLING_DELAY` milliseconds for the name of the window currently on focus and, if this has changed, then a new event is published.

An example run of the application utilizing the [Trivial Miner](../implemented-techniques/discovery-trivial.md) and the following code:
```java
public class WindowsWindowMonitor {
   public static void main(String[] args) throws Exception {
      StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
      env
         .addSource(new WindowsWindowMonitorSource())
         .keyBy(BEvent::getProcessName)
         .flatMap(new DirectlyFollowsDependencyDiscoveryMiner().setModelRefreshRate(1).setMinDependency(0))
         .addSink(new SinkFunction<ProcessMap>(){
            public void invoke(ProcessMap value, Context context) throws Exception {
               value.generateDot().exportToSvg(new File("src/main/resources/output/output.svg"));
            };
         });
      env.execute();
   }
}
```

Produces the following map:
<figure>

<svg width="324px" height="281px"
 viewBox="0.00 0.00 323.50 281.00" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<g id="graph0" class="graph" transform="scale(1.0 1.0) rotate(0.0) translate(4.0 277.0)">
<title>G</title>
<polygon fill="white" stroke="none" points="-4,4 -4,-277 319.5,-277 319.5,4 -4,4"/>
<!-- e3e9b1010&#45;99f2&#45;42f2&#45;9a8b&#45;b87c95a37494&#45;&gt;e886f2ff8&#45;9c79&#45;453a&#45;b67e&#45;a8ab38501ee0 -->
<g id="e0cb93538&#45;c36f&#45;416d&#45;a3a7&#45;a12ce9b8df3d" class="edge"><title>e3e9b1010&#45;99f2&#45;42f2&#45;9a8b&#45;b87c95a37494&#45;&gt;e886f2ff8&#45;9c79&#45;453a&#45;b67e&#45;a8ab38501ee0</title>
<path fill="none" stroke="#252526" stroke-width="9" d="M204,-151.5C204,-151.5 154.08,-127.834 114.952,-109.285"/>
<polygon fill="#252526" stroke="#252526" stroke-width="9" points="116.443,-105.634 110.238,-107.05 113.069,-112.75 116.443,-105.634"/>
<text text-anchor="middle" x="158.5" y="-117.6" font-family="Arial" font-size="8.00"> 1.0 (1)</text>
</g>
<!-- e3e9b1010&#45;99f2&#45;42f2&#45;9a8b&#45;b87c95a37494&#45;&gt;ef91712ff&#45;1664&#45;431b&#45;9547&#45;561693db89c9 -->
<g id="e95208fa4&#45;1fa4&#45;41a5&#45;941c&#45;eacff0041769" class="edge"><title>e3e9b1010&#45;99f2&#45;42f2&#45;9a8b&#45;b87c95a37494&#45;&gt;ef91712ff&#45;1664&#45;431b&#45;9547&#45;561693db89c9</title>
<path fill="none" stroke="#252526" stroke-width="9" d="M204,-151.5C204,-151.5 172.653,-132.971 180,-115 180.487,-113.808 181.054,-112.639 181.686,-111.498"/>
<polygon fill="#252526" stroke="#252526" stroke-width="9" points="185.035,-113.569 184.411,-107.236 178.4,-109.327 185.035,-113.569"/>
<text text-anchor="middle" x="193.5" y="-117.6" font-family="Arial" font-size="8.00"> 1.0 (1)</text>
</g>
<!-- e98d60a8f&#45;7389&#45;47c7&#45;aea3&#45;7b135deb82db&#45;&gt;e3e9b1010&#45;99f2&#45;42f2&#45;9a8b&#45;b87c95a37494 -->
<g id="e45c99a84&#45;b50f&#45;4a79&#45;b06b&#45;e322d6628509" class="edge"><title>e98d60a8f&#45;7389&#45;47c7&#45;aea3&#45;7b135deb82db&#45;&gt;e3e9b1010&#45;99f2&#45;42f2&#45;9a8b&#45;b87c95a37494</title>
<path fill="none" stroke="#252526" stroke-width="9" d="M227,-21.5C227,-21.5 257.48,-41.1689 267,-66 273.523,-83.0147 275.381,-90.8194 267,-107 262.583,-115.528 255.696,-122.77 248.07,-128.778"/>
<polygon fill="#252526" stroke="#252526" stroke-width="9" points="245.42,-125.842 243.769,-131.988 250.131,-132.153 245.42,-125.842"/>
<text text-anchor="middle" x="285.5" y="-84.6" font-family="Arial" font-size="8.00"> 1.0 (1)</text>
</g>
<!-- e886f2ff8&#45;9c79&#45;453a&#45;b67e&#45;a8ab38501ee0&#45;&gt;e98d60a8f&#45;7389&#45;47c7&#45;aea3&#45;7b135deb82db -->
<g id="edf90044f&#45;5944&#45;45a0&#45;aa96&#45;dc8d00ce9018" class="edge"><title>e886f2ff8&#45;9c79&#45;453a&#45;b67e&#45;a8ab38501ee0&#45;&gt;e98d60a8f&#45;7389&#45;47c7&#45;aea3&#45;7b135deb82db</title>
<path fill="none" stroke="#252526" stroke-width="9" d="M69,-85.5C69,-85.5 128.14,-61.5448 174.055,-42.946"/>
<polygon fill="#252526" stroke="#252526" stroke-width="9" points="175.58,-46.5766 178.736,-41.0499 172.624,-39.2776 175.58,-46.5766"/>
<text text-anchor="middle" x="171.5" y="-51.6" font-family="Arial" font-size="8.00"> 1.0 (1)</text>
</g>
<!-- e3c37b245&#45;6359&#45;445f&#45;b594&#45;77d60b1ea9c8&#45;&gt;e3e9b1010&#45;99f2&#45;42f2&#45;9a8b&#45;b87c95a37494 -->
<g id="ece05f8f4&#45;aab5&#45;482a&#45;9466&#45;446784c855c3" class="edge"><title>e3c37b245&#45;6359&#45;445f&#45;b594&#45;77d60b1ea9c8&#45;&gt;e3e9b1010&#45;99f2&#45;42f2&#45;9a8b&#45;b87c95a37494</title>
<path fill="none" stroke="#252526" stroke-width="9" d="M204,-217.5C204,-217.5 204,-196.451 204,-178.496"/>
<polygon fill="#252526" stroke="#252526" stroke-width="9" points="207.938,-178.05 204,-173.05 200.063,-178.05 207.938,-178.05"/>
<text text-anchor="middle" x="217.5" y="-183.6" font-family="Arial" font-size="8.00"> 1.0 (1)</text>
</g>
<!-- ef91712ff&#45;1664&#45;431b&#45;9547&#45;561693db89c9&#45;&gt;e3e9b1010&#45;99f2&#45;42f2&#45;9a8b&#45;b87c95a37494 -->
<g id="e963f7715&#45;2ed9&#45;4784&#45;911d&#45;9ca26e5aaf5e" class="edge"><title>ef91712ff&#45;1664&#45;431b&#45;9547&#45;561693db89c9&#45;&gt;e3e9b1010&#45;99f2&#45;42f2&#45;9a8b&#45;b87c95a37494</title>
<path fill="none" stroke="#252526" stroke-width="9" d="M207,-87.5C207,-87.5 207.881,-107.802 207,-124 206.947,-124.971 206.884,-125.961 206.812,-126.96"/>
<polygon fill="#252526" stroke="#252526" stroke-width="9" points="202.884,-126.682 206.393,-131.992 210.732,-127.336 202.884,-126.682"/>
<text text-anchor="middle" x="220.5" y="-117.6" font-family="Arial" font-size="8.00"> 1.0 (1)</text>
</g>
<!-- ef949dfe4&#45;9d22&#45;4d8e&#45;8a7a&#45;04df7737f67d&#45;&gt;e3c37b245&#45;6359&#45;445f&#45;b594&#45;77d60b1ea9c8 -->
<g id="ebd0e2212&#45;4726&#45;4f61&#45;81dc&#45;0651204015b6" class="edge"><title>ef949dfe4&#45;9d22&#45;4d8e&#45;8a7a&#45;04df7737f67d&#45;&gt;e3c37b245&#45;6359&#45;445f&#45;b594&#45;77d60b1ea9c8</title>
<path fill="none" stroke="#acb89c" stroke-width="2" stroke-dasharray="5,2" d="M204,-267.5C204,-267.5 204,-255.872 204,-244.062"/>
<polygon fill="#acb89c" stroke="#acb89c" stroke-width="2" points="205.75,-244.023 204,-239.023 202.25,-244.023 205.75,-244.023"/>
<text text-anchor="middle" x="205.5" y="-249.6" font-family="Arial" font-size="8.00"> </text>
</g>
<!-- e3e9b1010&#45;99f2&#45;42f2&#45;9a8b&#45;b87c95a37494 -->
<g id="e3e9b1010&#45;99f2&#45;42f2&#45;9a8b&#45;b87c95a37494" class="node"><title>e3e9b1010&#45;99f2&#45;42f2&#45;9a8b&#45;b87c95a37494</title>
<path fill="#0b4971" stroke="black" d="M256.5,-173C256.5,-173 151.5,-173 151.5,-173 145.5,-173 139.5,-167 139.5,-161 139.5,-161 139.5,-144 139.5,-144 139.5,-138 145.5,-132 151.5,-132 151.5,-132 256.5,-132 256.5,-132 262.5,-132 268.5,-138 268.5,-144 268.5,-144 268.5,-161 268.5,-161 268.5,-167 262.5,-173 256.5,-173"/>
<text text-anchor="start" x="147.5" y="-152.4" font-family="Arial" font-size="22.00" fill="#ffffff">eclipse.exe</text>
<text text-anchor="start" x="256.5" y="-152.4" font-family="Arial" font-size="14.00" fill="#ffffff"> </text>
<text text-anchor="start" x="188" y="-139.2" font-family="Arial" font-size="11.00" fill="#ffffff">1.0 (3)</text>
</g>
<!-- e98d60a8f&#45;7389&#45;47c7&#45;aea3&#45;7b135deb82db -->
<g id="e98d60a8f&#45;7389&#45;47c7&#45;aea3&#45;7b135deb82db" class="node"><title>e98d60a8f&#45;7389&#45;47c7&#45;aea3&#45;7b135deb82db</title>
<path fill="#8eb6cd" stroke="black" d="M303.5,-41C303.5,-41 150.5,-41 150.5,-41 144.5,-41 138.5,-35 138.5,-29 138.5,-29 138.5,-12 138.5,-12 138.5,-6 144.5,-0 150.5,-0 150.5,-0 303.5,-0 303.5,-0 309.5,-0 315.5,-6 315.5,-12 315.5,-12 315.5,-29 315.5,-29 315.5,-35 309.5,-41 303.5,-41"/>
<text text-anchor="start" x="146.5" y="-20.4" font-family="Arial" font-size="22.00" fill="#000000">OUTLOOK.EXE</text>
<text text-anchor="start" x="303.5" y="-20.4" font-family="Arial" font-size="14.00" fill="#000000"> </text>
<text text-anchor="start" x="208" y="-7.2" font-family="Arial" font-size="11.00" fill="#000000">0.33 (1)</text>
</g>
<!-- e886f2ff8&#45;9c79&#45;453a&#45;b67e&#45;a8ab38501ee0 -->
<g id="e886f2ff8&#45;9c79&#45;453a&#45;b67e&#45;a8ab38501ee0" class="node"><title>e886f2ff8&#45;9c79&#45;453a&#45;b67e&#45;a8ab38501ee0</title>
<path fill="#8eb6cd" stroke="black" d="M126,-107C126,-107 12,-107 12,-107 6,-107 0,-101 0,-95 0,-95 0,-78 0,-78 0,-72 6,-66 12,-66 12,-66 126,-66 126,-66 132,-66 138,-72 138,-78 138,-78 138,-95 138,-95 138,-101 132,-107 126,-107"/>
<text text-anchor="start" x="8" y="-86.4" font-family="Arial" font-size="22.00" fill="#000000">explorer.exe</text>
<text text-anchor="start" x="126" y="-86.4" font-family="Arial" font-size="14.00" fill="#000000"> </text>
<text text-anchor="start" x="50" y="-73.2" font-family="Arial" font-size="11.00" fill="#000000">0.33 (1)</text>
</g>
<!-- e3c37b245&#45;6359&#45;445f&#45;b594&#45;77d60b1ea9c8 -->
<g id="e3c37b245&#45;6359&#45;445f&#45;b594&#45;77d60b1ea9c8" class="node"><title>e3c37b245&#45;6359&#45;445f&#45;b594&#45;77d60b1ea9c8</title>
<path fill="#8eb6cd" stroke="black" d="M259,-239C259,-239 149,-239 149,-239 143,-239 137,-233 137,-227 137,-227 137,-210 137,-210 137,-204 143,-198 149,-198 149,-198 259,-198 259,-198 265,-198 271,-204 271,-210 271,-210 271,-227 271,-227 271,-233 265,-239 259,-239"/>
<text text-anchor="start" x="145" y="-218.4" font-family="Arial" font-size="22.00" fill="#000000">chrome.exe</text>
<text text-anchor="start" x="259" y="-218.4" font-family="Arial" font-size="14.00" fill="#000000"> </text>
<text text-anchor="start" x="185" y="-205.2" font-family="Arial" font-size="11.00" fill="#000000">0.33 (1)</text>
</g>
<!-- ef91712ff&#45;1664&#45;431b&#45;9547&#45;561693db89c9 -->
<g id="ef91712ff&#45;1664&#45;431b&#45;9547&#45;561693db89c9" class="node"><title>ef91712ff&#45;1664&#45;431b&#45;9547&#45;561693db89c9</title>
<path fill="#8eb6cd" stroke="black" d="M246,-107C246,-107 168,-107 168,-107 162,-107 156,-101 156,-95 156,-95 156,-78 156,-78 156,-72 162,-66 168,-66 168,-66 246,-66 246,-66 252,-66 258,-72 258,-78 258,-78 258,-95 258,-95 258,-101 252,-107 246,-107"/>
<text text-anchor="start" x="164" y="-86.4" font-family="Arial" font-size="22.00" fill="#000000">cmd.exe</text>
<text text-anchor="start" x="246" y="-86.4" font-family="Arial" font-size="14.00" fill="#000000"> </text>
<text text-anchor="start" x="188" y="-73.2" font-family="Arial" font-size="11.00" fill="#000000">0.33 (1)</text>
</g>
<!-- ef949dfe4&#45;9d22&#45;4d8e&#45;8a7a&#45;04df7737f67d -->
<g id="ef949dfe4&#45;9d22&#45;4d8e&#45;8a7a&#45;04df7737f67d" class="node"><title>ef949dfe4&#45;9d22&#45;4d8e&#45;8a7a&#45;04df7737f67d</title>
<ellipse fill="#ced6bd" stroke="#595f45" cx="204" cy="-268.5" rx="4.5" ry="4.5"/>
</g>
</g>
</svg>

</figure>

The complete code of this example is available in the GitHub repository <https://github.com/beamline/examples/tree/master/src/main/java/beamline/examples/windowsWindowMonitor>.


