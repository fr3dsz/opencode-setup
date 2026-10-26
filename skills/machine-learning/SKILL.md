---
name: machine-learning
description: Use for machine-learning and AI model work — datasets, preprocessing, data splits, feature extraction, model architecture, training loops, evaluation metrics, experiments, inference, PyTorch, notebooks, and research or thesis code.
---

# Machine Learning

## Before changing anything

1. Read the project's `AGENTS.md` and docs. In a thesis or research repo, the paper or methodology doc is the source of truth. Do not change the method without asking.
2. Find the config files and the entry scripts (train, evaluate, infer).

## Data

- [ ] Never modify or delete raw data. Write processed data to a separate folder.
- [ ] Train, validation, and test splits never share samples (or the same source video, patient, or user).
- [ ] Fit preprocessing (normalization, scalers) on training data only.
- [ ] Record dataset version and split seeds.

## Training

- [ ] Set random seeds for Python, NumPy, and the framework.
- [ ] Hyperparameters live in a config file, not hardcoded.
- [ ] Save checkpoints and the config used for each run.
- [ ] Log loss and metrics per epoch.

## Evaluation

- [ ] Compute metrics from actual model predictions on the test set.
- [ ] Never invent, round up, or edit results.
- [ ] Use the metrics the method or paper specifies.
- [ ] Report the exact config and checkpoint that produced each number.

## Changing the model

- Match the architecture described in the method doc. If you think it should differ, ask first.
- Change one thing per experiment so the effect is clear.

## Verify

- Run a short smoke test (one batch or one epoch on a small subset) before a full run.
- Check tensor shapes and device (CPU or GPU) at each stage when something fails.
- Report what you ran and the actual numbers.
