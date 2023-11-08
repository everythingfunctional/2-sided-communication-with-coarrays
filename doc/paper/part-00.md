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
