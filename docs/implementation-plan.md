# Implementation and evaluation handoff

This is a proposed build sequence. No training run, hardware budget, tensor dimensions, or base checkpoint has been selected.

## 1. Establish the task and timing contract

- Define easy/medium task families before comparing models: forms, settings, file operations, and bounded application workflows.
- Build resettable environments, exact outcome checks, and an action/observation recording interface.
- Separate train, validation, and held-out evaluation workflows. Do not collect training corrections from the held-out set.
- Record screenshot capture, encoding, decision, execution, UI waiting, slow-path updates, and synchronization times.
- Run a sequential VLM baseline with the same observation and tool access.

## 2. Select and profile the base

Compare screenshot text recognition, grounding, task success, guidance latency, and modifiability. Measure visual encoding and prefill separately from output decoding. Parameter count and text-generation throughput alone do not determine computer-use latency.

Preserve the pretrained backbone initially. Add the task/memory interfaces, event encoder, recurrent fast module, prediction heads, structured action outputs, and gate. Verify that a fast action can execute independently of a new deep pass.

## 3. Build the state contract before optimizing execution

Specify state ownership, exact-value storage, event ordering, source versions, pending actions, prediction correction, and reset behavior. Implement a simple inspectable runtime first; keep learned decisions distinct from execution bookkeeping.

Exercise delayed guidance, duplicate events, loading screens, unexpected dialogs, failed clicks, and prediction mismatch. These are required behavior checks, not claims that a particular implementation exists.

## 4. Collect sequential interaction data

Record `task -> observation -> action -> next observation -> outcome`, plus timing and execution feedback. Use appropriate existing data and additional human/teacher demonstrations. Include failures, retries, alternative actions, and recovery; successful screenshot/action pairs alone do not specify transition dynamics.

## 5. Train and integrate

1. Preserve the backbone while training new interfaces and the fast path on sequential demonstrations.
2. Train action-conditioned next-state representations and action selection together so prediction serves decisions. Use actual transition outcomes to evaluate predictive usefulness.
3. Train recurrent state and slow memory across sequences; expose them to their own imperfect state updates.
4. Jointly tune the paths as appropriate, including learned guidance queries. Simulate stale guidance and asynchronous observations during training.
5. Run in resettable training environments, collect failures/corrections, and iterate. Reinforcement learning is optional later, with correct completion prioritized over speed.

Exact losses, supervision, freezing strategy, memory sizes, and training budget remain open experiments.

## 6. Test the research claim

Compare:

- Sequential pretrained VLM agent.
- Asynchronous fast/slow agent without predictive state.
- Full stateful predictive architecture.

Add focused ablations for recurrence/memory and predictive preparation when needed to isolate their contributions. Keep backbone, tools, data access, task set, and hardware comparable; disclose any differences.

Primary target: lower end-to-end completion time at a matched success rate. Report success rates and uncertainty, median/tail action latency, completion-time distributions, extra actions, synchronization pauses, recovery, and compute consumption. Report failed attempts and timeouts explicitly; timing only successful runs can conceal a success tradeoff.

Measure fixed-time-budget success as well as generous-time-budget success. The former can improve through speed; the latter requires better decisions or recovery.

## 7. Serve the trained model

The deliverable is model weights/configuration, a custom inference runtime, and a computer connector. Keep task state resident. Schedule the fast path with sufficient resources, while the slow path reads snapshots and publishes compatible guidance at cycle boundaries. Clear task state deliberately between unrelated tasks.

Off-the-shelf VLM serving support is not proof that a serving engine supports the modified recurrence, shared blocks, or asynchronous state updates. Start with an inspectable implementation and optimize after profiling.

## First implementation milestone

One bounded workflow should complete through the actual fast action loop while the slow path updates asynchronously. Logs should demonstrate that the fast path does not run the full VLM for every action, that forecasts are corrected from real observations, and that delayed guidance cannot overwrite newer state. This establishes the execution design, not benchmark superiority.
