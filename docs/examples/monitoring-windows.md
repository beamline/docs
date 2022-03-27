!!! bug "Old documentation - Content valid only for Beamline v. 0.1.0"
    The content of this page refers an old version of the library (0.1.0). The current version of Beamline uses completely different technology and thus the content migh be invalid.

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

With this information it is now possible to wrap the code in a hot producer with:
```java
public class CurrentlyRunningProcess implements XesSource {

	private static final int POLLING_DELAY = 100; // milliseconds between checks of the active window
	private static final XFactory xesFactory = new XFactoryNaiveImpl();
	
	private String caseId;
	private String latestProcess = null;
	private Subject<XTrace> ps;
	
	public CurrentlyRunningProcess() {
		// each run of the system will create one process instance, so the case id is fixed
		this.caseId = UUID.randomUUID().toString();
		this.ps = PublishSubject.create();
	}
	
	@Override
	public Observable<XTrace> getObservable() {
		return ps;
	}

	@Override
	public void prepare() throws Exception {
		new Thread(new Runnable() {
			@Override
			public void run() {
				while(true) {
					String currentProcess = Informer.getWindowName();
					if (!currentProcess.isEmpty() && !currentProcess.equals(latestProcess)) {
						latestProcess = currentProcess;
						XEvent event = xesFactory.createEvent();
						XConceptExtension.instance().assignName(event, currentProcess);
						XTimeExtension.instance().assignTimestamp(event, new Date());
						XTrace eventWrapper = xesFactory.createTrace();
						XConceptExtension.instance().assignName(eventWrapper, caseId);
						eventWrapper.add(event);
						ps.onNext(eventWrapper);
					}
					
					try {
						Thread.sleep(POLLING_DELAY);
					} catch (InterruptedException e) { }
				}
			}
		}).start();
	}
}
```
The basic idea is to check every `POLLING_DELAY` milliseconds for the name of the window currently on focus and, if this has changed, then a new event is published.

An example run of the application utilizing the [Trivial Miner](../implemented-techniques/discovery-trivial.md) and the following code:
```java
public class EnumerateWindows {
	public static void main(String[] args) throws Exception {
		TrivialDiscoveryMiner miner = new TrivialDiscoveryMiner();
		miner.setModelRefreshRate(1);
		miner.setMinDependency(0);

		miner.setOnAfterEvent(() -> {
			if (miner.getProcessedEvents() % 5 == 0) {
				try {
					File f = new File("output.svg");
					miner.getLatestResponse().generateDot().exportToSvg(f);
				} catch (IOException e) { }
			}
		});
		
		// connects the miner to the actual source
		XesSource source = new CurrentlyRunningProcess();
		source.prepare();
		source.getObservable().subscribe(miner);
	}
}
```

Produces the following map:
<figure>
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="596px"
   height="250px"
   viewBox="0.00 0.00 596.00 250.00"
   version="1.1"
   id="svg146"
   sodipodi:docname="output.svg"
   inkscape:version="0.92.1 r15371">
  <metadata
     id="metadata152">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
        <dc:title></dc:title>
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <defs
     id="defs150" />
  <sodipodi:namedview
     pagecolor="#ffffff"
     bordercolor="#666666"
     borderopacity="1"
     objecttolerance="10"
     gridtolerance="10"
     guidetolerance="10"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:window-width="863"
     inkscape:window-height="480"
     id="namedview148"
     showgrid="false"
     inkscape:zoom="0.52684564"
     inkscape:cx="33.216561"
     inkscape:cy="125"
     inkscape:window-x="0"
     inkscape:window-y="0"
     inkscape:window-maximized="0"
     inkscape:current-layer="svg146" />
  <g
     class="edge"
     id="ea72017f1-2831-4e79-a792-5220f4904b43"
     transform="translate(4,246)">
    <title
       id="title6">eb456e3c8-51a5-4759-9364-c896a2565ede-&gt;e554f3cc4-908c-4313-9138-46540f154eae</title>
    <path
       style="fill:none;stroke:#38393a;stroke-width:7.4000001"
       inkscape:connector-curvature="0"
       id="path8"
       d="m 286,-218 c 0,0 90.232,5.737 157,30 10.431,3.791 21.16,9.007 30.987,14.391" />
    <polygon
       style="fill:#38393a;stroke:#38393a;stroke-width:7.4000001"
       id="polygon10"
       points="472.49,-170.737 475.645,-176.391 478.434,-171.128 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text12"
       font-size="8.00"
       y="-181.60001"
       x="472.5">0.80</text>
  </g>
  <g
     class="edge"
     id="e80a3e3a3-f48c-4bc3-b733-2aaa930f7fc0"
     transform="translate(4,246)">
    <title
       id="title15">eb456e3c8-51a5-4759-9364-c896a2565ede-&gt;eede49bad-0b23-4b49-8d28-34648634d0c3</title>
    <path
       style="fill:none;stroke:#737476;stroke-width:2.5999999"
       inkscape:connector-curvature="0"
       id="path17"
       d="m 286,-218 c 0,0 -139.009,7.391 -170,30 -21.8387,15.932 -34.8099,44.563 -41.8639,65.863" />
    <polygon
       style="fill:#737476;stroke:#737476;stroke-width:2.5999999"
       id="polygon19"
       points="72.4027,-122.461 75.7375,-121.398 72.5521,-117.166 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text21"
       font-size="8.00"
       y="-181.60001"
       x="125.5">0.20</text>
  </g>
  <g
     class="edge"
     id="eee487632-feff-4da6-bcd7-d28682ab394b"
     transform="translate(4,246)">
    <title
       id="title24">eb456e3c8-51a5-4759-9364-c896a2565ede-&gt;efdf20eed-2c2f-45a4-86af-af1f79f891a8</title>
    <path
       style="fill:none;stroke:#4c4d4e;stroke-width:5.80000019"
       inkscape:connector-curvature="0"
       id="path26"
       d="m 286,-218 c 0,0 -80.871,2.526 -110,47 -20.568,31.402 -3.714,75.3561 11.323,103.2506" />
    <polygon
       style="fill:#4c4d4e;stroke:#4c4d4e;stroke-width:5.80000019"
       id="polygon28"
       points="185.267,-66.2233 189.709,-68.6785 189.907,-63.075 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text30"
       font-size="8.00"
       y="-146.10001"
       x="185.5">0.60</text>
  </g>
  <g
     class="edge"
     id="e79d49535-33ec-49a8-8391-a2f40687c2f4"
     transform="translate(4,246)">
    <title
       id="title33">eb456e3c8-51a5-4759-9364-c896a2565ede-&gt;eebdb4049-6903-401e-9cfb-6ee5bda6c83f</title>
    <path
       style="fill:none;stroke:#737476;stroke-width:2.5999999"
       inkscape:connector-curvature="0"
       id="path35"
       d="m 286,-218 c 0,0 11.613,16.345 20,30 2.45,3.989 4.965,8.259 7.378,12.458" />
    <polygon
       style="fill:#737476;stroke:#737476;stroke-width:2.5999999"
       id="polygon37"
       points="311.953,-174.509 314.994,-176.242 315.949,-171.031 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text39"
       font-size="8.00"
       y="-181.60001"
       x="321.5">0.20</text>
  </g>
  <g
     class="edge"
     id="eda023916-da78-4a5b-9109-1e2ae0589955"
     transform="translate(4,246)">
    <title
       id="title42">e554f3cc4-908c-4313-9138-46540f154eae-&gt;eb456e3c8-51a5-4759-9364-c896a2565ede</title>
    <path
       style="fill:none;stroke:#5f6062;stroke-width:4.19999981"
       inkscape:connector-curvature="0"
       id="path44"
       d="m 513,-149 c 0,0 -90.389,-27.475 -157.092,-47.75" />
    <polygon
       style="fill:#5f6062;stroke:#5f6062;stroke-width:4.19999981"
       id="polygon46"
       points="356.064,-198.624 354.995,-195.107 350.745,-198.32 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text48"
       font-size="8.00"
       y="-181.60001"
       x="422.5">0.40</text>
  </g>
  <g
     class="edge"
     id="ee9196157-cc4a-442b-94d5-1ca6e18ef637"
     transform="translate(4,246)">
    <title
       id="title51">e554f3cc4-908c-4313-9138-46540f154eae-&gt;efdf20eed-2c2f-45a4-86af-af1f79f891a8</title>
    <path
       style="fill:none;stroke:#5f6062;stroke-width:4.19999981"
       inkscape:connector-curvature="0"
       id="path53"
       d="m 513,-147 c 0,0 -163.952,56.2426 -253.006,86.7917" />
    <polygon
       style="fill:#5f6062;stroke:#5f6062;stroke-width:4.19999981"
       id="polygon55"
       points="259.158,-61.8643 260.351,-58.3881 255.025,-58.5037 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text57"
       font-size="8.00"
       y="-92.099998"
       x="430.5">0.40</text>
  </g>
  <g
     class="edge"
     id="ebd88b017-efd6-4efa-aa80-ebb7f046d479"
     transform="translate(4,246)">
    <title
       id="title60">eede49bad-0b23-4b49-8d28-34648634d0c3-&gt;ea5539af0-e3a3-4673-a580-73083feabfcd</title>
    <path
       style="fill:none;stroke:#c2b0ab;stroke-width:2;stroke-dasharray:5, 2"
       inkscape:connector-curvature="0"
       id="path62"
       d="m 67,-93 c 0,0 0,56.4521 0,78.6691" />
    <polygon
       style="fill:#c2b0ab;stroke:#c2b0ab;stroke-width:2"
       id="polygon64"
       points="65.2501,-14.2598 68.7501,-14.2597 67,-9.25977 " />
  </g>
  <g
     class="edge"
     id="e654aff95-6a1c-43ea-9d07-e0e143df0719"
     transform="translate(4,246)">
    <title
       id="title67">efdf20eed-2c2f-45a4-86af-af1f79f891a8-&gt;eb456e3c8-51a5-4759-9364-c896a2565ede</title>
    <path
       style="fill:none;stroke:#252526;stroke-width:9"
       inkscape:connector-curvature="0"
       id="path69"
       d="m 204,-41 c 0,0 -20.475,-80.145 9,-130 4.984,-8.43 12.14,-15.608 20.044,-21.627" />
    <polygon
       style="fill:#252526;stroke:#252526;stroke-width:9"
       id="polygon71"
       points="235.76,-189.731 231.145,-196.112 237.504,-195.852 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text73"
       font-size="8.00"
       y="-146.10001"
       x="220">1.0</text>
  </g>
  <g
     class="edge"
     id="e916e694e-0291-44f7-9ffd-433d4651aebf"
     transform="translate(4,246)">
    <title
       id="title76">eebdb4049-6903-401e-9cfb-6ee5bda6c83f-&gt;eb456e3c8-51a5-4759-9364-c896a2565ede</title>
    <path
       style="fill:none;stroke:#737476;stroke-width:2.5999999"
       inkscape:connector-curvature="0"
       id="path78"
       d="m 328,-149 c 0,0 -33.658,-8.807 -45,-30 -1.893,-3.536 -2.752,-7.517 -2.955,-11.548" />
    <polygon
       style="fill:#737476;stroke:#737476;stroke-width:2.5999999"
       id="polygon80"
       points="281.796,-190.63 278.297,-190.676 280.112,-195.652 " />
    <text
       style="font-size:8px;font-family:Arial;text-anchor:middle"
       id="text82"
       font-size="8.00"
       y="-181.60001"
       x="292.5">0.20</text>
  </g>
  <g
     class="node"
     id="eb456e3c8-51a5-4759-9364-c896a2565ede"
     transform="translate(4,246)">
    <title
       id="title85">eb456e3c8-51a5-4759-9364-c896a2565ede</title>
    <path
       style="fill:#0b4971;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path87"
       d="m 338.5,-242 c 0,0 -105,0 -105,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 105,0 105,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text89"
       font-size="22.00"
       y="-221.39999"
       x="229.5">eclipse.exe</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text91"
       font-size="14.00"
       y="-221.39999"
       x="338.5" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#ffffff"
       id="text93"
       font-size="16.00"
       y="-204.2"
       x="274.5">1.0</text>
  </g>
  <g
     class="node"
     id="e554f3cc4-908c-4313-9138-46540f154eae"
     transform="translate(4,246)">
    <title
       id="title96">e554f3cc4-908c-4313-9138-46540f154eae</title>
    <path
       style="fill:#78a4be;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path98"
       d="m 576,-171 c 0,0 -126,0 -126,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 126,0 126,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text100"
       font-size="22.00"
       y="-150.39999"
       x="446">Explorer.EXE</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text102"
       font-size="14.00"
       y="-150.39999"
       x="576" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text104"
       font-size="16.00"
       y="-133.2"
       x="497">0.44</text>
  </g>
  <g
     class="node"
     id="eede49bad-0b23-4b49-8d28-34648634d0c3"
     transform="translate(4,246)">
    <title
       id="title107">eede49bad-0b23-4b49-8d28-34648634d0c3</title>
    <path
       style="fill:#b9dbec;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path109"
       d="m 122,-117 c 0,0 -110,0 -110,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 110,0 110,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text111"
       font-size="22.00"
       y="-96.400002"
       x="8">chrome.exe</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text113"
       font-size="14.00"
       y="-96.400002"
       x="122" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text115"
       font-size="16.00"
       y="-79.199997"
       x="51">0.11</text>
  </g>
  <g
     class="node"
     id="efdf20eed-2c2f-45a4-86af-af1f79f891a8"
     transform="translate(4,246)">
    <title
       id="title118">efdf20eed-2c2f-45a4-86af-af1f79f891a8</title>
    <path
       style="fill:#6292ae;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path120"
       d="m 243,-63 c 0,0 -78,0 -78,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 78,0 78,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text122"
       font-size="22.00"
       y="-42.400002"
       x="161">cmd.exe</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text124"
       font-size="14.00"
       y="-42.400002"
       x="243" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text126"
       font-size="16.00"
       y="-25.200001"
       x="188">0.56</text>
  </g>
  <g
     class="node"
     id="eebdb4049-6903-401e-9cfb-6ee5bda6c83f"
     transform="translate(4,246)">
    <title
       id="title129">eebdb4049-6903-401e-9cfb-6ee5bda6c83f</title>
    <path
       style="fill:#b9dbec;stroke:#000000"
       inkscape:connector-curvature="0"
       id="path131"
       d="m 407.5,-171 c 0,0 -159,0 -159,0 -6,0 -12,6 -12,12 0,0 0,22 0,22 0,6 6,12 12,12 0,0 159,0 159,0 6,0 12,-6 12,-12 0,0 0,-22 0,-22 0,-6 -6,-12 -12,-12" />
    <text
       style="font-size:22px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text133"
       font-size="22.00"
       y="-150.39999"
       x="244.5">sublime_text.exe</text>
    <text
       style="font-size:14px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text135"
       font-size="14.00"
       y="-150.39999"
       x="407.5" />
    <text
       style="font-size:16px;font-family:Arial;text-anchor:start;fill:#000000"
       id="text137"
       font-size="16.00"
       y="-133.2"
       x="312">0.11</text>
  </g>
  <g
     class="node"
     id="ea5539af0-e3a3-4673-a580-73083feabfcd"
     transform="translate(4,246)">
    <title
       id="title140">ea5539af0-e3a3-4673-a580-73083feabfcd</title>
    <circle
       style="fill:#d8bbb9;stroke:#614847"
       r="4.5"
       id="ellipse142"
       cy="-4.5"
       cx="67" />
  </g>
</svg>
</figure>

The complete code of this example is available in the GitHub repository <https://github.com/beamline/examples/tree/master/src/main/java/beamline/examples/windowsWindowMonitor>.


