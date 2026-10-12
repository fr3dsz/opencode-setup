---
name: machine-learning
description: Use when working on machine-learning or AI projects involving datasets, preprocessing, feature engineering, model development, training, evaluation, experiments, inference, or reproducibility.
---

# Machine Learning

Treat machine-learning systems as both software systems and experimental systems.

Correctness includes both implementation correctness and experimental validity.

## Before Making Changes

Understand:

- project objective
- dataset structure
- preprocessing pipeline
- model architecture
- training workflow
- evaluation methodology
- inference workflow
- experiment configuration

Read the project's ML documentation before making architectural changes.

## Dataset Integrity

Treat raw datasets as immutable unless the project explicitly defines a controlled transformation process.

Do not:

- silently modify raw data
- mix evaluation data into training
- reuse test data during training
- create accidental train/test leakage
- overwrite datasets without understanding provenance

## Data Splits

Maintain clear separation between:

- training
- validation
- testing
- inference/demo data

Do not assume that a dataset split is valid simply because it exists.

Consider leakage through:

- duplicate samples
- related videos/images
- preprocessing performed before splitting
- subject overlap
- temporal overlap
- metadata
- generated derivatives

## Preprocessing

Preprocessing should be:

- deterministic where practical
- reproducible
- documented
- independently verifiable

Record important:

- parameters
- input assumptions
- output format
- transformations
- dependencies

Validate intermediate outputs before continuing to later pipeline stages.

## Features and Transformations

Before changing feature extraction or transformations, understand:

- mathematical purpose
- expected shape
- numerical range
- dimensionality
- downstream requirements

Do not add transformations simply because they are common in other projects.

## Model Architecture

When modifying a model:

1. understand current architecture
2. understand input/output shapes
3. identify affected components
4. determine whether the change affects training or inference
5. update documentation if the architecture changes

Do not silently change research architecture.

## Training

Training should be reproducible where practical.

Track:

- configuration
- dataset version
- preprocessing version
- model configuration
- hyperparameters
- random seeds where applicable
- software/environment information
- checkpoints
- metrics

Avoid hardcoding experimental parameters when the project already uses configuration files.

## Evaluation

Keep evaluation independent from training decisions.

Do not tune the model against the final test set.

Use the metrics defined by the project.

Report enough context to interpret metrics correctly.

## Experiments

Prefer controlled experiments.

When changing one major factor, keep other relevant conditions consistent when possible.

Record:

- hypothesis
- configuration
- dataset
- results
- conclusion

## Inference

Keep inference separate from training and evaluation workflows.

Inference/demo data should not automatically become evaluation data.

## Reproducibility

A future researcher should be able to determine:

- what data was used
- how it was transformed
- what model was trained
- what configuration was used
- how evaluation was performed

## Computational Constraints

Respect project hardware constraints.

Prefer efficient approaches when they preserve research validity.

Do not optimize away methodological requirements merely to make execution faster.

## Verification

Before trusting a model result, verify:

1. dataset integrity
2. preprocessing output
3. tensor/input shapes
4. model output
5. training behavior
6. evaluation implementation
7. metric calculation

A successful training run does not automatically mean the experiment is valid.