---
name: documentation
description: Use when creating, updating, organizing, or reviewing project documentation, architecture documentation, data-flow documentation, READMEs, technical explanations, or developer guides.
---

# Documentation

Documentation should explain the system accurately enough that another developer can understand and work on it without rediscovering everything from source code.

## Core Principle

Documentation describes the actual system.

Do not document assumptions as facts.

Do not invent behavior that is not supported by the implementation or project requirements.

## Before Writing

Inspect:

- project AGENTS.md
- README
- existing docs
- relevant source code
- configuration
- tests
- architecture where applicable

Use the GitNexus MCP tools (see global instructions) to understand relationships when the task justifies it.

## Documentation Layers

Keep different kinds of information separate.

### Overview

Explain:

- what the project is
- why it exists
- major capabilities
- major technologies
- important boundaries

### Architecture

Explain:

- major components
- responsibilities
- dependencies
- communication between components
- important architectural decisions

### Data Flow

Explain:

- where data originates
- transformations
- processing stages
- storage
- outputs

### Requirements

Explain:

- required behavior
- constraints
- supported scenarios
- limitations

### Decisions

Record important architectural or technical decisions and their rationale.

### Changelog

Record meaningful changes rather than every trivial edit.

## Writing Style

Prefer:

- clear language
- concrete terminology
- short sections
- examples when useful
- diagrams for complicated relationships
- explicit assumptions

Avoid:

- unnecessary jargon
- vague descriptions
- marketing language in technical docs
- documentation that merely repeats source code

## Keeping Documentation Current

When implementation changes significantly, determine whether related documentation must change.

Do not update unrelated documentation.

## Accuracy

If the implementation and documentation disagree:

1. identify the discrepancy
2. determine which source represents the intended behavior
3. do not silently choose one
4. ask for clarification when necessary

## For Research Projects

Document:

- dataset assumptions
- preprocessing
- experimental configuration
- model architecture
- evaluation methodology
- reproducibility requirements
- known limitations

Keep research methodology separate from generic software documentation.