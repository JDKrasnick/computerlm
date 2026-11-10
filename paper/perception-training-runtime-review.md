# Perception, training, and local runtime

Research and design update, 10 November 2026. This follows the [interface review](interface-literature-review.md) and [decision register](design-questions.md). No training, evaluation, model download, or deployment was run for this review.

## Decisions from the latest discussion

- Both paths observe screens and available UI/accessibility text. Only fast control executes actions.
- New evidence should be delivered immediately, without an intentional batching delay. Learned task state persists until the task ends; pause/resume preserves that state.
- Guidance is a learned latent interface. Its encoder/adapter must be trained, and fusion remains an ablation.
- Fast-path autonomy is a central ablation: immediate greedy action selection versus a learned decision to defer execution for more computation or fresher slow guidance. Slow reasoning remains active in both conditions.
- Action-conditioned prediction belongs to the fast path. Slow reasoning can advise execution, but does not own the predictor or execute actions.
- Local inference is the preferred deployment outcome. The initial comparison still targets one GPU.
- The primary result is faster and cheaper task completion at comparable success on easy/medium tasks. Broader capability improvements can follow.

Latest refinement: use native VLM perception initially; preserve capability rather than minimize encoder cost. Seek matched accuracy, then faster completion as the primary improvement and lower cost as the secondary improvement. Guidance communicates subgoals/dependencies. Prefer action-embedding feedback with exact information retained as needed. Group predictive preparation with the immediate-action versus learned-deliberation ablation. Custom runtime software on standard GPU/CPU hardware is in scope; training remains open.

Selected reuse default in Draft 0.7: cache native visual features for identical encoder inputs and settings, and fully encode changed screens. Include weights/processor version and any temporal context in validity. Keep the cache task-bounded and continue delivering new observation, action, and timing events on visual cache hits. Approximate patch/token reuse is optional future work; its reported gains are not required for the proposed result. This does not authorize reusing stale language-model activations across changing recurrent states.

## How published models encode screens

The useful common pattern is screenshot patches, pretrained visual features, and a learned interface into the language/action model. This is not merely converting the screen to OCR text. Spatial tokens retain information about layout, icons, and controls. Available accessibility text can supplement those features under the same baseline observation contract.

| Model or research line | Published screen-processing design | Relevance to ComputerLM |
|---|---|---|
| [Holo4-27B](https://huggingface.co/Hcompany/Holo4-27B) | Built on Qwen3.8-27B. Both public configs specify a 27-layer, width-1152 vision tower, 16-pixel patches, and spatial merging by 2. | A current strong open-weight computer-use model inherits an established VLM perception stack rather than requiring a new GUI-specific image encoder architecture. |
| [Qwen2.5-VL](https://arxiv.org/abs/2502.13923) | Dynamic-resolution ViT, window attention, spatial positional information, and an MLP merger grouping four adjacent patch features into language-compatible visual tokens. | A detailed, reproducible precedent for reading high-resolution screenshots efficiently while retaining spatial detail. |
| [OpenCUA](https://arxiv.org/abs/2508.09123) | Adapts pretrained VLM families including Qwen2.5-VL. Its comparisons identify image pixel budget as relevant to high-resolution grounding. | GUI training and resolution policy matter alongside the encoder architecture. Its strong grounding results do not by themselves establish complete-task success. |
| [UI-TARS-2](https://arxiv.org/abs/2509.02544) | Starts from Seed-thinking-1.6 with a 532M vision encoder and a 230B-total/23B-active MoE language model. | Another major GUI research system builds on pretrained multimodal perception. Its model scale is not an appropriate local controller template. |
| [ShowUI](https://arxiv.org/abs/2411.17465) | A small VLA model with UI-guided selection of redundant visual tokens. | Relevant when reducing the visual token budget. Its reported token/training improvements should not be presented as equivalent end-to-end GUI task speedups. |

Configuration checks: [Qwen3.8-27B](https://huggingface.co/Qwen/Qwen3.8-27B/raw/main/config.json), [Holo4-27B](https://huggingface.co/Hcompany/Holo4-27B/raw/main/config.json). Matching published configuration establishes the architecture, not identical trained vision weights. These are informative public examples, not a claim that all are current leaderboard leaders or that closed models share the same architecture.

**Selected initial direction:** retain the pretrained VLM's native vision encoder and processor, with trainable adapters for both paths. Alternative encoders remain comparisons. Fast inference must be able to consume visual features without waiting for a full slow language-model pass. Capability and precise grounding remain important even when another encoder is cheaper.

Sharing one visual pass is a candidate, not a free latency improvement. The encoder itself could block urgent control. Compare native features with the alternatives below from the start. Preserve resolution/aspect-ratio handling and coordinate mapping; small labels and controls are easily lost by aggressive shrinking.

## More efficient perception candidates

JEPA and ViT are different axes. [I-JEPA](https://arxiv.org/abs/2301.08243) learns image representations by predicting masked-region representations and itself uses vision transformers. [V-JEPA 2](https://arxiv.org/abs/2506.09985) extends predictive representation learning to video and action-conditioned robotic planning. Neither establishes that a particular GUI screenshot encoder is cheaper at inference. The encoder still runs; inference savings must come from its size, reuse, representation budget, downstream policy, or some combination.

| Candidate | Where savings could come from | Main question for this proposal |
|---|---|---|
| Small GUI-adapted JEPA encoder plus recurrent action policy | Compact features and direct action heads avoid putting a large autoregressive decoder on each action's critical path. | Do the features preserve small text, exact targets, and task distinctions well enough? |
| Change-aware recurrent vision | Reuse visual computation for stable regions and update changed tokens/features. | Do scrolls, layout shifts, tiny text changes, or accumulated approximation error erase the benefit? |
| Coarse global view plus selected detailed crops | Spend high-resolution computation only on relevant areas. | Can the selector find the important detail without first doing the expensive full-image computation? |
| Compact latent bottleneck | Limit how much visual information expensive reasoning repeatedly processes. | Is the compression adequate for precise grounding and exact text? |

[Eventful Transformers](https://arxiv.org/abs/2308.13494), ICCV 2023, identifies significantly changed tokens and reuses earlier computation for video recognition. That is a direct temporal-efficiency precedent, but applying it to GUI grounding is an experiment. Updating only raw pixel crops is not generally equivalent to updating a globally contextualized transformer: changes can affect other tokens through attention. Include refresh policies and actual timing, not just the count of changed pixels.

[Perceiver](https://arxiv.org/abs/2103.03206) uses a latent bottleneck to separate input size from the bulk of processing. [Recurrent Interface Networks](https://arxiv.org/abs/2212.11972) route information between data tokens and recurrent latent computation in iterative generation. These motivate alternative interfaces, not demonstrated GUI-agent gains.

[Apple's UI-JEPA](https://machinelearning.apple.com/research/ui-intent) learns UI embeddings and uses an LLM decoder to infer user intent from onscreen activity. It is relevant UI representation work, but its task is intent understanding rather than executing GUI workflows. GUI-JEPA below is the closer action-policy comparison.

**Recommended experiment:** compare the native VLM encoder baseline with a smaller GUI-adapted predictive encoder feeding the same recurrent controller. Compare representation training objectives at matched encoder architecture/resolution where practical; otherwise report the capacity difference. Add temporal reuse and selective high-resolution detail as separate increments. Their gains should not be attributed to the JEPA objective without controls. Align alternative features to the slow path through trained adapters; replacement features are not automatically compatible with a pretrained VLM.

## What visual-reuse literature supports

Three optimizations need separate accounting:

1. **Repeated-image feature caching:** reuse features of the same screenshot under the same encoder and preprocessing/context settings. This is useful when old images recur in context; it does not remove the work of encoding a genuinely new screen. Temporal encoders may also depend on surrounding frames.
2. **Selective updates for new screens:** [GUIFlow](https://arxiv.org/abs/2610.34959), an October 2026 research report, combines selective vision/prefill updates with history reuse and verified speculative action decoding. It reports up to 3.49x online OSWorld speedup for the combined pipeline, with broadly comparable task performance. That is evidence for investigating reuse, not a measured gain for visual encoding alone or for ComputerLM. The same-pixel region can acquire different contextual features when another region changes, so approximate reuse needs quality checks.
3. **Compressed visual history:** [GUI-KV](https://arxiv.org/abs/2510.00536) uses spatial saliency and temporal redundancy to compress the language-model KV cache without retraining. It addresses retained visual context and decoding cost, rather than proving that a new screenshot's visual encoding can be skipped. [Historical-screenshot pruning research](https://arxiv.org/abs/2603.26041) also finds that spatial layout and seemingly background regions can carry useful interface-state information.

Recommended first comparison: native perception with versus without repeated-image caching, then selective-update experiments with a full-recomputation control and refresh route. Evaluate changed labels, validation messages, scrolling, overlays, and layout shifts. Keep reaction time, grounding, task success, encoder time, and retained-state memory separate. Measure the refresh policy and cache overhead, not only the fraction of tokens reused.

## Two especially relevant GUI comparisons

[iSHIFT, CVPR 2026](https://openaccess.thecvf.com/content/CVPR2026/papers/Mehrotra_iSHIFT_Lightweight_Slow-Fast_GUI_Agent_with_Adaptive_Perception_CVPR_2026_paper.pdf) ([accessible method](https://arxiv.org/html/2512.22009v1)) extends Qwen2-VL-2B with latent thinking and optional DINOv2-L perception. It first deliberates latently, then emits an action or control tokens that request additional visual features, injected into the sequence before action generation. Training labels coordinate-dependent actions as slow and others as fast. This supplies routing supervision, not calibrated confidence labels. Its conditional sequential modes differ from ComputerLM's concurrent recurrent paths. It is a relevant comparison for adaptive perception and latent deliberation, not validation of the full architecture.

[GUI-JEPA](https://arxiv.org/abs/2610.36877), an October 2026 preprint, studies a decoder-free candidate-scoring policy with a screenshot-pretrained ViT-L/16 and action-conditioned latent computation. Its mobile setup uses accessibility candidates and restricted text handling. It reports faster per-step inference than a matched 7B VLM with lower accuracy, rather than establishing equal-success desktop task speedups. Importantly, it reports that pretraining the predictor on dynamics was not needed for its decision result. A useful action-scoring latent is therefore not sufficient evidence that a model predicts actual future state.

These papers make the literature more specific than robotics analogies alone. They also mean the proposal should not claim that fast/slow GUI inference or latent action policies are untouched areas. The experimental question is the value of this particular integration: continuously updated recurrent task state, asynchronous learned guidance, fast execution/prediction, and local resource constraints.

## Observation intake and feedback mean different things

Immediate observation delivery is a design requirement. A new screen should become available to both paths as soon as it is captured, without waiting for a scheduled slow cycle. Actual incorporation still requires encoding and a consistent state update. The runtime must make that update at the earliest supported boundary without clearing the living task state or letting an older update overwrite newer evidence. This is a latency requirement to measure, not permission to queue observations indefinitely.

The user proposes two concrete ways to incorporate that evidence. They can also be combined:

1. **Next-cycle intake:** each bounded slow recurrent cycle reads fresh encoded observations and accumulated issued actions while carrying forward its existing task state. Evidence arriving after a read point becomes available to the next cycle. Cycle duration determines incorporation delay; a cycle does not reset the task. [RMT](https://arxiv.org/abs/2207.06881) supplies a learned-state-between-segments precedent, but does not validate this continuous GUI update protocol.
2. **Learned internal intake:** an adapter supplies new evidence at selected points in a recurrent pass. Implement this as residual-state updates or cross-attention at block boundaries, rather than changing model weights or editing an executing kernel. [Flamingo](https://arxiv.org/abs/2204.14198) establishes trainable visual cross-attention between pretrained language-model layers; it does not establish arbitrary asynchronous injection into an ongoing computation.

Early insertion allows more subsequent processing, while later insertion offers a shorter route to output but cannot retroactively revise already computed layers. Treat those as hypotheses to measure. Compare front-only, fixed middle/late, and learned gated sites before adding a learned depth router. RIN's read/compute/write pattern is a useful additional structural analogy, with a different task and training setup.

Use the same persistent state, observation/action stream, controller, and training budget in these comparisons. Record evidence arrival, read point, and guidance publication so intake delay can be measured. Check both ordinary updates and contradictory evidence: error dialogs, failed actions, renamed targets, and user corrections. Neither strategy promises zero physical latency. A recurrent cycle plus learned intake adapter is a coherent combined design, not a choice between two incompatible models.

Feedback here means information about fast execution that might not be recoverable from screenshots: the last action issued, whether a request is pending or failed, and optionally the controller's latent interpretation. It is not another required reasoning module or an authorization for slow actuation.

An unchanged screen after Save can mean no action was issued, an action is pending, or it had no visible effect. Executor records distinguish some of these cases; screenshots establish visible outcomes. The existing four-condition experiment remains appropriate: observations alone, plus action/execution records, plus learned fast feedback, and plus both. Separate the value of added information from the value of how it is encoded. Keep the learned reverse edge optional.

Latest direction is tentative direct action feedback: when fast control issues an action, make that actual action available to slow reasoning. Whether its representation is discrete/structured or latent remains open. Represent dispatch, executor acknowledgement, and observed effect separately when available; a chosen action is not proof that the environment performed it. This does not require forwarding the fast controller's entire hidden state.

Latest refinement prefers action embeddings, with structured actions as a fallback if needed. An action embedding represents an operation and its parameters; persistent task state represents the environment. It need not encode every possible screen state. Exact arbitrary text, keys, coordinates, and acknowledgement information should remain recoverable as needed rather than relying on lossy compression alone.

## Guidance encoder and autonomy

The guidance encoder is a different component from the screen encoder. It is the trainable interface that makes slow-path state useful to fast control. A compact projection or learned-query encoder can produce guidance vectors; a fast input adapter can transform them again. Their placement, capacity, and fusion should be compared rather than hard-coded as a claim of architectural necessity.

The desired content is subgoal-level intent and dependencies, such as submitting an order or finding X to obtain Y. These phrases are explanatory glosses for a latent channel. Fast control learns how to ground this direction into concrete operations. They do not prescribe named latent dimensions or prose serialization at runtime.

Train this interface using downstream action performance. An action loss can propagate through the fast controller and guidance adapter to the slow representation producer when it is trainable. If slow features are cached or detached, only the downstream components learn from that loss. That is useful for an initial controlled stage, but is not end-to-end training of the slow model.

**Autonomy ablation:**

1. Immediate execution: select the highest-scoring permitted executable action whenever an action decision is ready. Retain ordinary UI-loading waits so the baseline is meaningful.
2. Learned deferral: additionally permit a learned gate to delay execution for further fast computation or a newer slow-guidance update. Compare these two deferral sources separately if both are implemented.

Both conditions retain the same continuously active slow path, perception, action interface, and prediction budget unless an explicitly labelled additional ablation changes one of them. This isolates the dispatch decision. Slow guidance never directly executes the action while fast control defers.

[PonderNet](https://arxiv.org/abs/2107.05407) provides a precedent for learning how much computation to use. [Calibration research](https://arxiv.org/abs/1706.04599) shows why a model's largest softmax value is not automatically a reliable correctness estimate. In this system, action likelihood also differs from the expected benefit of waiting. Learn or validate the gate against action outcomes and the actual time/compute cost of deferral. An entropy threshold can be a baseline, not a guaranteed confidence rule.

## Recommended training sequence

This is a proposed development order, not a selected hyperparameter recipe or an estimate of required training scale.

1. **Prepare chronological interaction data.** Record the goal, permitted screen/UI observations, action arguments, actual following observations, and execution status/timing where available. Include failures and recovery. Use official task-family splits and keep held-out evaluation outputs and corrections out of training. OpenCUA is a relevant source of demonstrator-to-training infrastructure; its published full-scale token budget is not a requirement for this prototype.
2. **Validate the adapted slow backbone separately.** Preserve a one-pass reference, then train recurrent feedback gates/adapters and verify retained capability before increasing latent depth. Keep the native processor and vision path intact initially. Carry state across observations during training and test task resets. Existing language-model recurrence does not by itself establish stable continuous multimodal intake.
3. **Teach basic fast execution.** Freeze the pretrained visual/slow weights initially. Train the custom recurrent controller, input adapters, action heads, text interface, and a small guidance encoder on demonstrated actions. Use action-type losses and suitable target/text losses. Train on contiguous sequence chunks; carrying state while truncating gradients is different from resetting state at every chunk.
4. **Learn cooperation.** Train the guidance producer and controller together. If a frozen slow model limits performance, add small slow-model adapters and unfreeze selectively. [LoRA](https://arxiv.org/abs/2106.09685) is a parameter-efficient adaptation option; [QLoRA](https://arxiv.org/abs/2305.14314) supports training adapters through a quantized frozen model. Neither guarantees that this recurrent multimodal architecture fits a particular device. Model activations, optimizer state, recurrent unrolling, and operator support still need profiling.
5. **Add fast prediction and the autonomy gate.** Supervise predictions against actual next-observation features and action-relevant changes. Keep future observations out of current inputs. Include guidance delay, missing guidance, loading screens, and contradictions. Train a useful action representation without treating low latent prediction loss as proof of calibrated future-state prediction. Introduce deferral with an explicit cost and validate against the immediate-execution condition.
6. **Collect learner failures and refine.** Use on-policy recovery examples, then consider RL with task outcomes and measured efficiency. [DAgger](https://arxiv.org/abs/1011.0686) motivates learning on states the controller actually visits. UI-TARS-2 offers a GUI precedent for iterative supervised and reinforcement training. Do not begin with an expensive RL run before the controller and interface have useful supervised behaviour.

The accessible starting point is to train the new small components and adapters, not the entire foundation model from scratch. Local inference and local full-model training are separate goals. A small backbone/controller diagnostic can validate the pipeline before a larger training run; it cannot establish that the final 27B system will fit or meet quality targets.

## One GPU: scheduling, partitioning, and sharding

| Approach | What it does | Role here |
|---|---|---|
| Cooperative scheduling and streams | Keeps both paths resident and submits short units of work, allowing urgent perception/control to run between slow units. | First portable candidate. Actual overlap and latency require measurement. |
| CUDA green contexts | Assigns selected GPU compute resources, including subsets of SMs, to workloads on supported NVIDIA setups. | A relevant spatial-partitioning experiment for local NVIDIA deployment. It does not eliminate shared-resource contention or guarantee concurrent progress. |
| NVIDIA MIG | Creates instances with dedicated compute/memory resources on supported GPUs. | Stronger separation, but hardware-dependent and potentially restrictive for memory fit and feature sharing. Not a default consumer-laptop assumption. |
| Model sharding | Splits weights/computation across multiple devices. | Addresses fit/scale, not fast/slow isolation inside a single GPU. Outside the initial one-GPU target. |

Sources: [CUDA asynchronous execution](https://docs.nvidia.com/cuda/cuda-programming-guide/02-basics/asynchronous-execution.html), [green-context guide](https://developer.nvidia.com/blog/control-how-your-gpu-shares-work-with-green-contexts/), [green-context concurrency limits](https://docs.nvidia.com/cuda/cuda-driver-api/cuda_driver_api/group__CUDA__GREEN__CONTEXTS.html), [MIG](https://docs.nvidia.com/datacenter/tesla/mig-user-guide/latest/).

CUDA stream priority does not preempt an already executing kernel. Keeping slow work interruptible at useful boundaries matters; launching two Python tasks is insufficient. For green contexts, disjoint compute partitions still do not guarantee concurrency because other resources can introduce dependencies. Hardware partitioning is a comparison to profile, not an assumed cure for contention.

On Apple silicon, [MLX unified memory](https://ml-explore.github.io/mlx/build/html/usage/unified_memory.html) and [streams](https://ml-explore.github.io/mlx/build/html/usage/using_streams.html) are the relevant starting tools. The CUDA mechanisms above are not Apple APIs. CPU/GPU share memory, so avoiding duplicated weights and large histories is valuable, but unified memory does not make computation free or guarantee latency isolation.

A read-only check during this review identified the current workspace machine as an Apple M4 with 24 GiB memory. That is not automatically the final deployment target. A 27B model's raw weights alone are approximately 54 GB at 16 bits or 13.5 GB at 4 bits, before quantization metadata, vision, activations, caches, runtime buffers, and the operating system. These are arithmetic lower bounds, not measured fit results. Start local runtime profiling with a smaller compatible model; consider quantized larger inference only after establishing fit and supported recurrent operations. Full 27B adaptation is not established as practical on this machine.

## What the first result needs to show

The priority is matched verified accuracy, then faster complete-task execution, then lower cost, relative to a declared baseline. Predeclare the operational accuracy tolerance before held-out evaluation. Report speed improvements as the primary result and cost changes independently; a joint faster-and-cheaper claim requires both. Include all attempts so failing quickly cannot count as efficiency.

For rented compute, report full billed allocation and actor time. For local inference, report latency, memory, and measured energy when available; give explicit assumptions for any monetary conversion. GPU time is a resource measure, not automatically a dollar saving. Count continuous slow reasoning and all perception/prediction/verification work. Keep training cost separate from inference cost.

Include an architecture-matched control for prediction and the autonomy gate, plus a standard synchronous agent. An intermittent-slow control tests whether continuous reasoning earns its computation. These comparisons can start on a bounded development suite; general browser/desktop claims require broader coverage. Qualitative evaluation, if run later, remains subject to the repository's ChatGPT-only evaluation contract.

## What still needs a design choice or experiment

- Specific pretrained checkpoint, image/token budget, and whether one visual pass can serve both paths quickly enough.
- Runtime implementation for immediate multimodal intake and persistent state, including ordering of concurrent updates.
- Whether execution records or learned fast-state feedback add value beyond direct observation.
- Guidance encoder capacity, fusion, training scope, publication, and compatibility checks.
- Immediate versus learned-defer control, and whether deferral uses additional fast computation, fresher slow guidance, or both.
- Fast predictor targets, horizon, and its measured contribution to task efficiency.
- Initial trainable components, data budget, sequence length, and adaptation curriculum.
- Local target hardware, memory fit, supported kernels, and shared versus partitioned scheduling.
- A declared baseline and operational definition of comparable success.

The overall objective is settled. These are experiments within it, not prerequisites that must all be answered intuitively before building a small prototype.
