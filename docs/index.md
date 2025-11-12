---
hide:
  - navigation
  - toc
---

# Beamline Framework

<img src="img/logo.png" style="float: right; width: 150px;" />
Beamline is a framework designed to facilitate the prototyping and the development of ***streaming process mining*** algorithms.

The framework comprises two libraries: **pyBeamline** (Python) and **Beamline** (Java).

pyBeamline is built on [ReactiveX](https://reactivex.io/) and its Python implementation, RxPY - a library for composing asynchronous, event-driven programs using observable sequences and pipable query operators. pyBeamline is suitable for prototyping algorithm very quickly, without necessarily bothering with performance aspects. It also simplifies collaboration by, for example, leveraging online notebook services (like Google Colab). [py]Beamline consists of both algorithms and data structures, sources, and sinks to facilitate the development of streaming process mining applications. While redefining the concept of *event*, Beamline tries to maintain compatibility with OpenXES and the IEEE XES standard.

Beamline, the Java library, is designed on top of [Apache Flink](https://flink.apache.org/) which makes it suitable for extremely efficient computation due to the distributed and stateful nature of its components. 


## Streaming process mining

[Process mining](https://en.wikipedia.org/wiki/Process_mining) is a well establish discipline, aiming at bridging data science and process science together, with the ultimate goal of improving processes and their corresponding executions.

Classical process mining techniques take as input so-called *event log files*: static files containing executions to be analyzed. These event log files are typically structured as XML files according to the [IEEE XES standard](https://xes-standard.org/). These files contain events referring to a fixed period of time and, therefore, the results of the process mining analyses refer to the same time frame.

In [streaming process mining](https://andrea.burattin.net/publications/2018-encyclopedia), the input is not a static file, but an *event stream*. As in [event stream processing](https://en.wikipedia.org/wiki/Event_stream_processing), in streaming process mining the goal is to analyze data immediately and update the analysis immediately.

The picture below refers to the control-flow discovery case but, obviously, the same principle applies when [conformance checking](https://en.wikipedia.org/wiki/Conformance_checking) or enhancement algorithms are considered.

<figure markdown> 
  ![Streaming process mining idea](img/idea.svg)
  <figcaption>
    <p>Conceptualization of the streaming process discovery.</p>
    <p style="line-height: 15px !important; font-size: .7em; color: #AAA;">
    <span>Image adapted from: A. Burattin, A. Sperduti, and W. van der Aalst. Control-
flow Discovery from Event Streams. In Proc. of IEEE WCCI-CEC, 2014.</span></p></figcaption>
</figure>



## Beamline

Beamline is a framework meant to simplify the research and the development of streaming process mining, by providing a set of tools that can lift researchers from the burden of setting up streams and running experiments.

!!! note "On the name Beamline"
    The term *Beamline* is borrowed from [high energy physics](https://en.wikipedia.org/wiki/Beamline), where it indicates the physical structure used to define experiments, i.e., where the accelerated particles travel. In the streaming process mining case, Beamline is used to set up experiments where process mining events are processed and consumed.

Beamline comprises utility classes as well as some algorithms already implemented that can be used for comparing new techniques with the state of the art.


## Citation

Please, cite this work as:

* Andrea Burattin. "[Beamline: A comprehensive toolkit for research and development of streaming process mining](http://dx.doi.org/10.1016/j.simpa.2023.100551)". In *Software Impacts*, vol. 17 (2023).

??? quote "BibTeX for citation"
    ```bibtex
    @article{BURATTIN2023100551,
      title = {Beamline: A comprehensive toolkit for research and development of streaming process mining},
      journal = {Software Impacts},
      volume = {17},
      pages = {100551},
      year = {2023},
      issn = {2665-9638},
      doi = {https://doi.org/10.1016/j.simpa.2023.100551},
      url = {https://www.sciencedirect.com/science/article/pii/S266596382300088X},
      author = {Andrea Burattin},
      keywords = {Process mining, Streaming process mining, Apache Flink, Reactive programming},
      abstract = {Beamline is a software library to support the research and development of streaming process mining algorithms. Specifically, it comprises a Java library, built on top of Apache Flink, which fosters high performance and deployment. The second component is a Python library (called pyBeamline, built using ReactiveX) which allows the quick prototyping and development of new streaming process mining algorithms. The two libraries share the same underlying data structures (BEvent) as well as the same fundamental principles, thus making the prototypes (built by researchers using pyBeamline) quickly transferrable to full-fledged and highly scalable applications (using Java Beamline).}
    }
    ```