---
issue: November 2023, \textbf{39}, 1
title: Reinventing Two-Sided Communication in Fortran to Transmit Polymorphic Objects Between Images
firstpage: 1
author:
  - Brad Richardson
...

# Motivation

As of the latest version of the Fortran standard [@F2023], there are a handful of constraints that prevent the effective use of polymorphic objects in coarrays.
Specifically, it is not allowed to coindex an object which has any polymorphic components.
There are reasons to want these restrictions for performance and memory management,
but there are problems for which polymorphism is highly desirable.
However, it is valid to use `co_broadcast` on objects with allocatable, polymorphic components.
This paper describes a method of combining this feature with a novel use of the teams feature
to re-derive a two-sided communication mechanism that is able to communicate polymorphic objects between images.

# Usage

A variable of the derived type `communicator_t` defined in the `communicator` module is declared.
The `init` type-bound procedure of this variable must be called by every image in the current team prior to initiating any communication.
An image may then initiate transfer of any data object by calling the `send_to` type-bound procedure of that object and indicating the image to which the data should be sent.
The identified image must execute a call to `receive_from` of the corresponding `communicator_t` variable identifying the image which is executing the `send_to` procedure.
The `send_to` and `receive_from` procedures constitute synchronous, blocking operations.
Thus, care must be taken to ensure that a deadlock does not occur.
For instance, if all images initiate a send operation, then no image will be available to execute a corresponding receive, and all the images will wait forever.

An example program making use of the `communicator` library is shown below.
The image with the largest index creates a message and sends it to its lower neighbor, i.e. image with one lower index.
Each other image receives the message from its upper neighbor, i.e. image one higher index, and then sends it to its lower neighbor.
Each image then prints the message.

```{include=app/main.f90}
```
