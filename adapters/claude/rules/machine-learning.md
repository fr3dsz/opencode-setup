---
paths:
  - "**/*.ipynb"
  - "**/{models,training,train,experiments,preprocessing,dataset,datasets}/**/*.py"
  - "**/{train,evaluate,eval,inference}*.py"
---

# Machine-learning files

- Use the `machine-learning` skill; in a thesis project also use the project's `thesis-research` skill.
- Never modify raw data; prevent leakage across train/validation/test splits.
- Compute metrics from actual predictions; never invent or edit results.
