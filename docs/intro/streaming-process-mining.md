
[Process mining](https://en.wikipedia.org/wiki/Process_mining) is a well establish discipline, aiming at bridging data science and process science together, with the ultimate goal of improving processes and their corresponding executions.

Classical process mining techniques take as input so-called *event log files*: static files containing executions to be analyzed. These event log files are typically structured as XML files according to the [IEEE XES standard](https://xes-standard.org/). These files contain events referring to a fixed period of time and, therefore, the results of the process mining analyses refer to the same time frame.

In [streaming process mining](https://andrea.burattin.net/publications/2018-encyclopedia), the input is not a static file, but an *event stream*. As in [event stream processing](https://en.wikipedia.org/wiki/Event_stream_processing), in streaming process mining the goal is to analyze data immediately and update the analysis immediately.

The picture below refers to the control-flow discovery case but, obviously, the same principle applies when [conformance checking](https://en.wikipedia.org/wiki/Conformance_checking) or enhancement algorithms are considered.

<figure markdown> 
  ![Streaming process mining idea](../img/idea.svg)
  <figcaption>
    <p>Conceptualization of the streaming process discovery.</p>
    <p style="line-height: 15px !important; font-size: .7em; color: #AAA;">
    <span>Image adapted from: A. Burattin, A. Sperduti, and W. van der Aalst. Control-
flow Discovery from Event Streams. In Proc. of IEEE WCCI-CEC, 2014.</span></p></figcaption>
</figure>