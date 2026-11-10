# Implementation and evaluation plan

Public research plan consolidated 10 November 2026. This plan describes intended work and acceptance criteria, not a completed integrated system. See the [research proposal](research-proposal.md) and [architecture](architecture-v1.md).

## Current implementation boundary

Ongoing development includes a task/measurement harness and a cache-free wrapper around native Qwen text modules. One-pass execution bypasses feedback; additional latent steps feed continuous state through the same middle blocks. Tiny-model software checks and a small pretrained diagnostic test exercise numerical plumbing. They do not demonstrate persistent semantic task memory, continuous event ingestion, multimodal 27B quality, learned handoffs, fast-path execution, or architectural speed/cost gains.

The initial slow-path experiment selects Qwen3.8-27B for adaptation. Exact layer partition, adapter scope, memory capacity, losses, curriculum mixture, gradient windows, hardware and training budget remain profiling and development decisions. This public documentation update does not publish unfinished code, evaluation artifacts or model weights.

## 1. Freeze task and measurement contracts

Define easy/medium workflow families before evaluating: forms, settings, file operations and bounded application workflows. Use resettable environments, declared screenshot/UI-text access, structured actions, execution receipts and independent exact outcome checks. Reserve held-out episodes and task/template families before generating training prefixes.

Record capture/encoding, prefill, reasoning, action selection, connector execution, UI waits, slow updates, retrieval, synchronization and recovery. Distinguish model errors from service failures. Keep actor timing separate from grading and setup.

The development real-browser track uses upstream Gitea in a disposable container and pinned Playwright Chromium. Synthetic diagnostics and structured-snapshot slow-guidance tasks are separately labelled. One app is not general computer-use coverage; structured guidance success is not application success or evidence of latent mechanisms.

## 2. Adapt and profile the slow core

Retain pretrained encoder and decoder/readout around shared recurrent middle blocks. Begin with one-pass parity, stable gradients and cache-free execution before optimizing cache reuse or kernels. Preserve native vision processing while separately validating multimodal integration. Latent-depth recurrence must not be mistaken for memory across observations.

Compare limited feedback/core-adapter training with matched nonrecurrent training. Profile real hardware memory, useful guidance latency and total compute rather than extrapolating from parameter count or text tokens per second.

## 3. Install persistent state and event interfaces

Keep learned task, observed-state, reasoning-memory and guidance interfaces alongside explicit goals, constraints, exact values, evidence references and ordered receipts. Bound recent context, retain original instructions and provide retrieval from older episode evidence.

Consume events at defined completed latent boundaries. Distinguish confirmed facts, pending action effects and predictions. When evidence invalidates a guidance packet, withdraw the whole packet and publish a coherent replacement. Unrelated observations or age alone need not invalidate compatible guidance. Preserve state across pause/resume and reset it between unrelated tasks.

## 4. Collect and audit sequential data

Record task, observation, action, next observation, outcome and timing. Include failed actions, delays, recovery, interruptions and instruction changes. Supervise predictions from observed transitions; an imagined alternative outcome is not an executed branch.

Candidate public trajectories require revision, license, alignment, provenance and split audits. Keep held-out outputs and corrections out of training. Use ChatGPT through the signed-in Codex CLI for the selected teacher pipeline. Teacher targets are compact public outputs based only on available episode prefixes, not hidden activations or private reasoning. Review labels before training; teacher context and student context conditions must be disclosed.

## 5. Train through a staged curriculum

1. Stabilize latent recurrence while retaining pretrained language and reasoning ability.
2. Learn short computer-use guidance, simple memory carry and publication/completion readouts.
3. Train persistent memory and harder reasoning together on delayed dependencies, constraints and recovery.
4. Add longer changing workflows, event-boundary updates, prediction correction, guidance replacement and interruption.
5. Refine using independently verified interaction outcomes and supervised corrections. Preference training or RL can be evaluated later.

Install memory interfaces before the curriculum. Retain earlier skills in later mixtures. Train memory writes through their effects on later decisions, with bounded unrolls and gradient windows. Depth recurrence and cross-event memory need distinct gradient paths. Initial structured readouts provide supervision, but only a receiving fast module can establish the usefulness of a learned compact handoff.

Post-training is part of the proposal, not an alternative to architecture work. It can reduce mistakes, excess actions and generated reasoning. The experiment asks whether persistent learned state and independently executing paths provide additional gains.

## 6. Add fast execution and prediction

Build a lightweight observation/state updater, grounded action head, candidate transition predictions and a wait gate. Compare reused/adapted VLM blocks with a narrower recurrent controller. Train fast/slow communication and prediction on sequential tasks rather than assuming independently capable modules will cooperate.

The fast path must execute routine actions without a full slow-model pass. The slow path continues during active tasks, including executor waits, and publishes compatible guidance adaptively. Protect action-path compute and bandwidth. Test delayed guidance, failed clicks, duplicate events, loading screens, unexpected dialogs and incorrect predictions.

## 7. Test speed, computation and reliability together

Compare a sequential VLM, optimized small specialized VLMs, external-state systems, an asynchronous fast/slow baseline without prediction, and the full proposal. Add matched ablations for learned memory, state reset/shuffling, latent depth, prediction and guidance reuse. Disclose any differences in backbone, training, tools, context, serving hardware or budgets.

Report independent exact completion, partial scores separately, success versus elapsed time, mean/median/tail completion and action latency, model calls, actions/retries, waits, memory use, retrieval and measured or explicitly estimated compute. Count the complete task cost of both paths, prediction, state maintenance, serving and recovery. Token counts alone do not measure latent-loop FLOPs, and API prices do not establish architectural efficiency.

Evaluate latency at comparable success and on the same jointly solved tasks, while retaining overall success and all failed attempts in the report. Do not select only successful or easy-for-this-model runs to claim superiority. Report fixed-time-budget success alongside generous-budget success and uncertainty across repeated runs.

## Evaluation integrity

Qualitative grading uses ChatGPT through the signed-in Codex CLI after the actor episode. A judge error is a batch hard stop; do not retry, substitute providers, invent scores or grade subsequent episodes without explicit direction. Judge time and qualitative rubrics remain separate from actor timing and deterministic outcomes. Missing evidence is unassessed, not a fabricated score.

Shared grading assesses observable alignment, state tracking and evidence use. Do not infer private reasoning, prediction or learned handoffs from fluent prose. Instrumented decision summaries are a separate condition, and prefix evaluations must exclude future observations and outcomes. Favorable judgments cannot override failed task invariants.

## Deliverable and success gates

The eventual deliverable is weights/configuration, a runtime supporting resident state and asynchronous latent updates, and a computer connector. Serving-engine support for the unmodified base model does not establish support for the proposed recurrence or scheduler.

First establish stable recurrent adaptation and useful memory on controlled development tasks. Then establish one complete bounded application workflow with independent outcomes and logs showing real fast-path independence, continuous slow computation, observation correction and stale-guidance handling. Only controlled broader comparisons can establish lower completion time, compute or cost at comparable success. Novelty requires a separate prior-art assessment.
