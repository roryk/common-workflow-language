Work in progress.

This version:
  * https://w3id.org/cwl/draft-3/

Current version:
  * https://w3id.org/cwl/

Authors:

* Peter Amstutz <peter.amstutz@curoverse.com>, Curoverse
* Nebojša Tijanić <nebojsa.tijanic@sbgenomics.com>, Seven Bridges Genomics

Contributers:

* Luka Stojanovic <luka.stojanovic@sbgenomics.com>, Seven Bridges Genomics
* John Chilton <jmchilton@gmail.com>, Galaxy Project, Pennsylvania State University
* Michael R. Crusoe <crusoe@ucdavis.edu>, University of California, Davis
* Hervé Ménager <herve.menager@gmail.com>, Institut Pasteur
* Maxim Mikheev <mikhmv@biodatomics.com>, BioDatomics
* Stian Soiland-Reyes [soiland-reyes@cs.manchester.ac.uk](mailto:soiland-reyes@cs.manchester.ac.uk), University of Manchester

# Abstract

A Workflow is an analysis task represented by a directed graph describing a
sequence of operations that transform an input data set to output.  This
specification defines the Common Workflow Language (CWL), a vendor-neutral
standard for representing workflows and concrete process steps intended to
be portable across a variety of computing platforms.

# Status of This Document

This document is the product of the [Common Workflow Language working
group](https://groups.google.com/forum/#!forum/common-workflow-language).  The
latest version of this document is available in the "specification" directory at

https://github.com/common-workflow-language/common-workflow-language

The products of the CWL working group (including this document) are made available
under the terms of the Apache License, version 2.0.

# Introduction

The Common Workflow Language (CWL) working group is an informal, multi-vendor
working group consisting of various organizations and individuals that have an
interest in portability of data analysis workflows.  The goal is to create
specifications like this one that enable data scientists to describe analysis
tools and workflows that are powerful, easy to use, portable, and support
reproducibility.

## Introduction to draft 3

This specification represents the third milestone of the CWL group.  Since
draft-2, this draft introduces the following changes and additions:

* ...

## Purpose

CWL is designed to express workflows for data-intensive science, such as
Bioinformatics, Chemistry, Physics, and Astronomy.  This specification is
intended to define a data and execution model for Workflows and Command Line
Tools that can be implemented on top of a variety of computing platforms,
ranging from an individual workstation to cluster, grid, cloud, and high
performance computing systems.

## References to Other Specifications

* [JSON](http://json.org)
* [JSON-LD](http://json-ld.org)
* [JSON Pointer](https://tools.ietf.org/html/draft-ietf-appsawg-json-pointer-04)
* [YAML](http://yaml.org)
* [Avro](https://avro.apache.org/docs/current/spec.html)
* [Uniform Resource Identifier (URI): Generic Syntax](https://tools.ietf.org/html/rfc3986)
* [UTF-8](https://www.ietf.org/rfc/rfc2279.txt)
* [Portable Operating System Interface (POSIX.1-2008)](http://pubs.opengroup.org/onlinepubs/9699919799/)
* [Resource Description Framework (RDF)](http://www.w3.org/RDF/)

## Scope

This document describes the CWL syntax, execution, and object model.  It
is not intended to document a specific implementation of CWL, however it may
serve as a reference for the behavior of conforming implementations.

## Terminology

The terminology used to describe CWL documents is defined in the
Concepts section of the specification. The terms defined in the
following list are used in building those definitions and in describing the
actions of an CWL implementation:

**may**: Conforming CWL documents and CWL implementations are permitted but
not required to behave as described.

**must**: Conforming CWL documents and CWL implementations are required to behave
as described; otherwise they are in error.

**error**: A violation of the rules of this specification; results are
undefined. Conforming implementations may detect and report an error and may
recover from it.

**fatal error**: A violation of the rules of this specification; results are
undefined. Conforming implementations must not continue to execute the current
process and may report an error.

**at user option**: Conforming software may or must (depending on the modal verb in
the sentence) behave as described; if it does, it must provide users a means to
enable or disable the behavior described.

# Data model

## Data concepts

An **object** is a data structure equivalent to the "object" type in JSON,
consisting of a unordered set of name/value pairs (referred to here as
**fields**) and where the name is a string and the value is a string, number,
boolean, array, or object.

A **document** is a file containing a serialized object, or an array of objects.

A **process** is a basic unit of computation which accepts input data,
performs some computation, and produces output data.

An **input object** is an object describing the inputs to a invocation of process.

An **output object** is an object describing the output of an invocation of a process.

An **input schema** describes the valid format (required fields, data types)
for an input object.

An **output schema** describes the valid format for a output object.

**Metadata** is information about workflows, tools, or input items that is
not used directly in the computation.

## Syntax

Documents containing CWL objects are serialized and loaded using YAML
syntax and UTF-8 text encoding.  A conforming implementation must accept
all valid YAML documents.

The CWL schema is defined using Avro Linked Data (avro-ld).  Avro-ld is an
extension of the Apache Avro schema language to support additional
annotations mapping Avro fields to RDF predicates via JSON-LD.

A CWL document may be validated by transforming the avro-ld schema to a
base Apache Avro schema.

An implementation may interpret a CWL document as
[JSON-LD](http://json-ld.org) and convert a CWL document to a [Resource
Description Framework (RDF)](http://www.w3.org/RDF/) using the
CWL [JSON-LD Context](https://w3id.org/cwl/draft-2/context) (extracted from the avro-ld schema).
The CWL [RDFS schema](https://w3id.org/cwl/draft-2/cwl.ttl) defines the classes and properties used by
CWL as JSON-LD.

The latest draft-2 schema is defined here:
https://github.com/common-workflow-language/common-workflow-language/blob/master/schemas/draft-2/cwl-avro.yml



## Identifiers

If an object contains an `id` field, that is used to uniquely identify the
object in that document.  The value of the `id` field must be unique over the
entire document.  The format of the `id` field is that of a [relative fragment
identifier](https://tools.ietf.org/html/rfc3986#section-3.5), and must start
with a hash `#` character.

An implementation may choose to only honor references to object types for
which the `id` field is explicitly listed in this specification.

When loading a CWL document, an implementation may resolve relative
identifiers to absolute URI references.  For example, "my_tool.cwl" located
in the directory "/home/example/work/" may be transformed to
"file:///home/example/work/my_tool.cwl" and a relative fragment reference
"#input" in this file may be transformed to
"file:///home/example/work/my_tool.cwl#input".

## Document preprocessing

An implementation must resolve `import` directives.  An `import` directive
is an object consisting of the field `import` specifying a URI.  The URI
referenced by `import` must be loaded as a CWL document (including
recursive preprocessing) and then the `import` object is implicitly
replaced by the external resource.  URIs may include document fragments
referring to objects identified by their `id` field, in which case the `import`
directive is replaced by only the fragment object.

An implementation must resolve `include` directives.  An `include`
directive is an object consisting of the field `include` specifying a URI.
The URI referenced by `include` must be loaded as UTF-8 encoded text
document and the `include` directive implicitly replaced by a string with
the contents of the document.  Because the loaded resource is unparsed,
URIs used with `include` must not include fragments.

## Extensions and Metadata

Implementation extensions not required for correct
execution (for example, fields related to GUI rendering) may
be stored in [process hints](#requirements_and_hints).

Input metadata (for example, a lab sample identifier) may be explicitly
represented within a workflow using input parameters which are propagated
to output.  Future versions of this specification may define additional
facilities for working with input/output metadata.

Fields for tool and workflow metadata (for example, authorship for use in
citations) are not defined in this specification.  Future versions of this
specification may define such fields.

# Execution model

## Execution concepts

A **parameter** is a named symbolic input or output of process, with an
associated datatype or schema.  During execution, values are assigned to
parameters to make the input object or output object used for concrete
process invocation.

A **command line tool** is a process characterized by the execution of a
standalone, non-interactive program which is invoked on some input,
produces output, and then terminates.

A **workflow** is a process characterized by multiple subprocess steps,
where step outputs are connected to the inputs of other downstream steps to
form a directed graph, and independent steps may run concurrently.

A **runtime environment** is the actual hardware and software environment when
executing a command line tool.  It includes, but is not limited to, the
hardware architecture, hardware resources, operating system, software runtime
(if applicable, such as the Python interpreter or the JVM), libraries, modules,
packages, utilities, and data files required to run the tool.

A **workflow platform** is a specific hardware and software implementation
capable of interpreting a CWL document and executing the processes specified by
the document.  The responsibilities of the workflow platform may include
scheduling process invocation, setting up the necessary runtime environment,
making input data available, invoking the tool process, and collecting output.

It is intended that the workflow platform has broad leeway outside of this
specification to optimize use of computing resources and enforce policies
not covered by this specifcation.  Some areas that are currently out of
scope for CWL specification but may be handled by a specific workflow
platform include:

* Data security and permissions.
* Scheduling tool invocations on remote cluster or cloud compute nodes.
* Using virtual machines or operating system containers to manage the runtime
(except as described in [DockerRequirement](#dockerrequirement)).
* Using remote or distributed file systems to manage input and output files.
* Translating or rewriting file paths.
* Determining if a process has previously been executed, skipping it and
reusing previous results.
* Pausing and resuming of processes or workflows.

Conforming CWL processes must not assume anything about the runtime
environment or workflow platform unless explicitly declared though the use
of [process requirements](#processrequirement).

## Generic execution process

The generic execution sequence of a CWL process (including both workflows
and concrete process implementations) is as follows.

1. Load and validate CWL document, yielding a process object.
2. Load input object.
3. Validate the input object against the `inputs` schema for the process.
4. Validate that process requirements are met.
5. Perform any further setup required by the specific process type.
6. Execute the process.
7. Capture results of process execution into the output object.
8. Validate the output object against the `outputs` schema for the process.
9. Report the output object to the process caller.

## Requirements and hints

A **[process requirement](#processrequirement)** modifies the semantics or runtime
environment of a process.  If an implementation cannot satisfy all
requirements, or a requirement is listed which is not recognized by the
implementation, it is a fatal error and the implementation must not attempt
to run the process, unless overridden at user option.

A **hint** is similar to a requirement, however it is not an error if an
implementation cannot satisfy all hints.  The implementation may report a
warning if a hint cannot be satisfied.

Requirements are inherited.  A requirement specified in a Workflow applies
to all workflow steps; a requirement specified on a workflow step will
apply to the process implementation.

If the same process requirement appears at different levels of the
workflow, the most specific instance of the requirement is used, that is,
an entry in `requirements` on a process implementation such as
CommandLineTool will take precendence over an entry in `requirements`
specified in a workflow step, and an entry in `requirements` on a workflow
step takes precedence over the workflow.  Entries in `hints` are resolved
the same way.

Requirements override hints.  If a process implementation provides a
process requirement in `hints` which is also provided in `requirements` by
an enclosing workflow or workflow step, the enclosing `requirements` takes
precedence.

Process requirements are the primary mechanism for specifying extensions to
the CWL core specification.

## Parameter references

Parameter references are denoted by the syntax `$(...)` and may be used in
any field permitting the pseudo-type `Expression`, as specified by this
document.  Conforming implementations must support parameter
references.  Parameter references use the following subset of
[Javascript/ECMAScript 5.1](http://www.ecma-international.org/ecma-262/5.1/) syntax:

symbol::    {Unicode alphanumeric}+
singleq::   '[' ''' ( {character} - ''' | '\' ''' )* ''' ']'
doubleq::   '[' '"' ( {character} - '"' | '\' '"' )* '"' ']'
index::     '[' {decimal digit}+ ']'
segment::   '.' {symbol} | {singleq} | {doubleq} | {index}
parameter:: '$' '(' {symbol} {segment}* ')'

Use the following algorithm to resolve a parameter reference:

  1. Match the leading symbol as key
  2. Look up the key in the parameter context (described below) to get the current value.
     It is an error if the key is not found in the parameter context.
  3. If there are no subsequent segments, terminate and return current value
  4. Else, match the next segment
  5. Extract the symbol, string, or index from the segment as key
  6. Look up the key in current value and assign as new current value.  If
     the key is a symbol or string, the current value must be an object.
     If the key is an index, the current value must be an array or string.
     It is an error if the key does not match the required type, or the key is not found or out
     of range.
  7. Repeat steps 3-6

The root namspace is the parameter context.  The following parameters must
be provided:

  * `inputs`: The input object to the current Process.
  * `self`: A context-specific value.  The contextual values for 'self' are
    documented for specific fields elsewhere in this specification.  If
    a contextual value of 'self' is not documented for a field, it
    must be 'null'.
  * `runtime`: An object containing configuration details.  Specific to the
    [Process](#process) type.  An implementation may provide may provide
    opaque strings for any or all fields of `runtime`.  These must be
    filled in by the platform after processing the Tool but before actual
    execution.  Parameter references and expressions may only use the
    literal string value of the field and must not perform computation on
    the contents.

If the value of a field has no leading or trailing non-whitespace
characters around a parameter reference, the effective value of the field
becomes the value of the referenced parameter, preserving the return type.

If the value of a field has non-whitespace leading or trailing characters
around an parameter reference, it is subject to string interpolation.  The
effective value of the field is a string containing the leading characters;
followed by the string value of the parameter reference; followed by the
trailing characters.  The string value of the parameter reference is its
textual JSON representation with the following rules:

  * Leading and trailing quotes are stripped from strings
  * Objects entries are sorted by key

Multiple parameter references may appear in a single field.  This case is
must be treated as a string interpolation.  After interpolating the first
parameter reference, interpolation must be recursively applied to the
trailing characters to yield the final string value.

## Expressions

An expression is a fragment of [Javascript/ECMAScript
5.1](http://www.ecma-international.org/ecma-262/5.1/) code which is
evaluated by the workflow platform to affect the inputs, outputs, or
behavior of a process.  In the generic execution sequence, expressions may
be evaluated during step 5 (process setup), step 6 (execute process),
and/or step 7 (capture output).  Expressions are distinct from regular
processes in that they are intended to modify the behavior of the workflow
itself rather than perform the primary work of the workflow.

To declare the use of expressions, the document must include the process
requirement `InlineJavascriptRequirement`.  Expressions may be used in any
field permitting the pseudo-type `Expression`, as specified by this
document.

Expressions are denoted by the syntax `$(...)` or `${...}`.  A code
fragment wrapped in the `$(...)` syntax must be evaluated as a
[ECMAScript expression](http://www.ecma-international.org/ecma-262/5.1/#sec-11).  A
code fragment wrapped in the `${...}` syntax must be evaluated as a
[EMACScript function body](http://www.ecma-international.org/ecma-262/5.1/#sec-13)
for an anonymous, zero-argument function.  Expressions must return a valid JSON
data type: one of null, string, number, boolean, array, object.
Implementations must permit any syntatically valid Javascript and account
for nesting of parenthesis or braces and that strings that may contain
parenthesis or braces when scanning for expressions.

The runtime must include any code defined in the ["expressionLib" field of
InlineJavascriptRequirement](#inlinejavascriptrequirement) prior to
executing the actual expression.

Before executing the expression, the runtime must initialize as global
variables the fields of the parameter context described above.

The effective value of the field after expression evaluation follows the
same rules as parameter references discussed above.  Multiple expressions
may appear in a single field.

Expressions must be evaluated in an isolated context (a "sandbox") which
permits no side effects to leak outside the context.  Expressions also must
be evaluated in [Javascript strict mode](http://www.ecma-international.org/ecma-262/5.1/#sec-4.2.2).

The order in which expressions are evaluated is undefined except where
otherwise noted in this document.

An implementation may choose to implement parameter references by
evalutating as a Javascript expression.  The results of evaluating
parameter references must be identical whether implemented by Javascript
evaluation or some other means.

Implementations may apply other limits, such as process isolation, timeouts,
and operating system containers/jails to minimize the security risks associated
with running untrusted code embedded in a CWL document.

## Workflow graph

A workflow describes a set of **steps** and the **dependencies** between
those processes.  When a process produces output that will be consumed by a
second process, the first process is a dependency of the second process.
When there is a dependency, the workflow engine must execute the dependency
process and wait for it to successfully produce output before executing the
dependent process.  If two processes are defined in the workflow graph that
are not directly or indirectly dependent, these processes are
**independent**, and may execute in any order or execute concurrently.  A
workflow is complete when all steps have been executed.

## Success and failure

A completed process must result in one of `success`, `temporaryFailure` or
`permanentFailure` states.  An implementation may choose to retry a process
execution which resulted in `temporaryFailure`.  An implementation may
choose to either continue running other steps of a workflow, or terminate
immediately upon `permanentFailure`.

* If any step of a workflow execution results in `permanentFailure`, then the
workflow status is `permanentFailure`.

* If one or more steps result in `temporaryFailure` and all other steps
complete `success` or are not executed, then the workflow status is
`temporaryFailure`.

* If all workflow steps are executed and complete with `success`, then the workflow
status is `success`.

## Executing CWL documents as scripts

By convention, a CWL document may begin with `#!/usr/bin/env cwl-runner`
and be marked as executable (the POSIX "+x" permission bits) to enable it
to be executed directly.  A workflow platform may support this mode of
operation; if so, it must provide `cwl-runner` as an alias for the
platform's CWL implementation.

A CWL input object document may similarly begin with `#!/usr/bin/env
cwl-runner` and be marked as executable.  In this case, the input object
must include the field "cwl:tool" supplying a URI to the default CWL
document that should be executed with the fields of the input object as
input parameters.