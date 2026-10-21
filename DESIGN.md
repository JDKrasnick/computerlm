---
name: ComputerLM research brief
description: A scientific teaching plate for a proposed computer-use architecture.
colors:
  paper: "#f5f7f5"
  white: "#fff"
  ink: "#183c32"
  text: "#293c35"
  muted: "#52675c"
  rule: "#cbd6cd"
  sage: "#e5ede5"
  lime: "#d6eb9a"
  accent: "#315d42"
  hero-secondary: "#62816a"
  scrollbar: "#94aa99"
  diagram-divider: "#a7bbaa"
  inverse-copy: "#e4eee6"
  brand-mark: "#9db965"
typography:
  display:
    fontFamily: "Manrope, Arial, sans-serif"
    fontSize: "clamp(2.8rem, 5.8vw, 4.75rem)"
    fontWeight: 650
    lineHeight: 1.06
    letterSpacing: "-0.04em"
  headline:
    fontFamily: "Manrope, Arial, sans-serif"
    fontSize: "clamp(1.65rem, 3vw, 2.25rem)"
    fontWeight: 650
    lineHeight: 1.22
    letterSpacing: "-0.03em"
  title:
    fontFamily: "Manrope, Arial, sans-serif"
    fontSize: "1.06rem"
    fontWeight: 750
    lineHeight: 1.4
  body:
    fontFamily: "Manrope, Arial, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.7
  intro:
    fontFamily: "Manrope, Arial, sans-serif"
    fontSize: "18px"
    lineHeight: 1.65
  label:
    fontFamily: "Manrope, Arial, sans-serif"
    fontSize: "13px"
    fontWeight: 700
    lineHeight: 1.7
  micro:
    fontFamily: "Manrope, Arial, sans-serif"
    fontSize: "12px"
    lineHeight: 1.65
rounded:
  radius: "14px"
  node: "12px"
spacing:
  paragraph: "12px"
  column: "46px"
  section-column: "54px"
  section-block: "48px"
  hero-column: "76px"
components:
  print-button:
    textColor: "{colors.ink}"
    padding: "8px 0"
  disclosure-summary:
    textColor: "{colors.ink}"
    typography: "{typography.label}"
    padding: "4px 0"
  comparison-table-cell:
    padding: "16px 20px"
  contents:
    textColor: "{colors.accent}"
    padding: "17px 0"
  example:
    backgroundColor: "{colors.sage}"
    rounded: "{rounded.radius}"
    padding: "26px 30px"
  diagram:
    backgroundColor: "{colors.sage}"
    rounded: "{rounded.radius}"
    padding: "28px"
  node:
    backgroundColor: "{colors.white}"
    rounded: "{rounded.node}"
    padding: "17px 20px"
  node-backbone:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.white}"
  node-prediction:
    backgroundColor: "{colors.lime}"
  evaluation:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.white}"
    rounded: "{rounded.radius}"
    padding: "27px 30px"
---

# Design System: ComputerLM

This document describes the earlier HTML research briefs. Current model decisions live in [V1 architecture](docs/architecture-v1.md).

## Overview

**Creative North Star: "Scientific teaching plate"**

A daylight research brief uses cool paper, forest ink, generous headings, and flat dividers. Two static diagrams compare internal network changes and runtime model calls, with alternatives shown side by side. Short explanations and comparison tables support the diagrams.

This is the visual system implemented in `index.html`, extracted after a SHIP finish review with no material findings. It presents a research proposal with clearly stated hypotheses and no measured results.

**Key Characteristics:**
- Manrope typography with compact, heavy headings.
- Sage diagram fields, white nodes, and forest emphasis.
- Flat section rules and restrained rounded surfaces.
- Responsive reading layout with separate network and runtime comparisons.

## Colors

The normative palette is in the frontmatter; the first nine names mirror CSS custom properties in `index.html`.

- **Ink** carries headings, the shared backbone, and evaluation panel; **text** carries body copy.
- **Paper**, **white**, and **sage** separate the page, diagram nodes, and supporting fields. **Rule** divides sections and table rows.
- **Muted** carries supporting copy. **Accent** carries links, focus outlines, diagram arrows, and the prediction node's dashed border.
- **Lime** marks the future-state head, inverse-panel links, and text selection. The brand has its own green square.
- Remaining literal colors identify the secondary hero line, scrollbar, diagram dividers, and inverse body copy. No tonal ramps are defined.

## Typography

Manrope is embedded in the HTML as a variable font, with Arial and sans-serif fallbacks. Its copyright and SIL Open Font License 1.1 are included in the same file. There are no external font requests.

Display headings use the fluid scale above, a `12ch` maximum width, and balanced wrapping. Section headings use the headline role. Body paragraphs are limited to `70ch`; the introduction uses `53ch`. Supporting explanations and tables use 14–15px, captions and microcopy use 12px, and diagram input labels use 11px. Strong text uses weight 750; the brand uses 800. Training discussion remains conceptual, without a loss formula.

## Layout

The centered wrapper is `min(1120px, calc(100% - 96px))`. The hero uses `1.4fr 1fr` columns, a 76px gap, and `65px 0 44px` padding. Sections have 48px vertical padding. Section introductions use `1fr 1.3fr`; explanatory pairs use equal columns. The network comparison has two equal columns with a 48px gap; the runtime comparison has three equal columns with a 24px gap. Nodes connect vertically; the proposed network forks into two output branches.

At 900px and below, wrapper gutters become 32px, major gaps shrink, and diagram padding becomes 23px. At 700px and below, gutters become 20px, body text becomes 15px, the hero and supporting grids stack, and sections use 34px vertical padding. The hero becomes `clamp(2.7rem, 11vw, 3.7rem)` with a `13ch` limit. Network and runtime alternatives stack with ruled separation; the proposed network's two output branches remain side by side. Tables become stacked rows; cells with `data-label` prepend their label, including “Mechanism” and “Limit” in evaluation. Contents links wrap.

Print uses white paper and 15mm page margins. Navigation, print controls, and footer return link are hidden. Both static diagrams remain visible, with two network columns and three runtime columns. Figures, evaluation panels, and table rows avoid page breaks where possible.

## Elevation & Depth

There are no shadows or gradients. Depth comes from paper, sage, white, and forest fills, plus 1px section rules. The prediction node has a dashed accent border. Keyboard focus uses a 3px accent outline with a 5px offset. Anchor scrolling is smooth, with a 28px scroll offset; reduced-motion preference disables smooth scrolling. The native disclosure has no custom animation.

## Shapes

Supporting panels use the 14px `--radius`; diagram nodes use 12px corners. Tables and section boundaries remain flat. The brand, downward arrows, and fork connectors are inline SVG geometry. No photographic or raster assets ship.

## Components

- **Masthead and contents:** inline brand, date label, Print / PDF action, and wrapping anchor navigation. Links darken on hover; underlined links increase underline thickness. The skip link becomes visible on keyboard focus.
- **Print button:** text and 17px printer SVG, 44px minimum height, no filled container; invokes `window.print()`.
- **Network comparison:** static baseline and proposed-network columns share the same visual grammar. A fork exposes the action and auxiliary prediction branches; captions explain which additions can be removed for deployment.
- **Runtime comparison:** three static columns compare a standard GUI agent, an external world model, and the lean proposal. A shared-loop note spans the panel below the columns.
- **Architecture nodes:** white default nodes have 15px strong labels and 12px descriptions. The backbone is forest with white text; the future-state head is lime with forest text and a dashed border. Output branches use 14px labels, 16px padding, and 133px minimum height. Runtime nodes use a 76px minimum height, removed on mobile.
- **Example panel:** sage field with a heading and three label/value rows; labels occupy 72px. Mobile padding becomes 23px.
- **Speculative-decoding disclosure:** native `details`/`summary` explains the Medusa analogy, separated by a rule, with the browser's disclosure marker and keyboard behavior. Summary minimum height is 36px.
- **Comparison tables:** common styling for model/infrastructure, literature, and expected-gain comparisons. Open rows have bottom rules, strong leading labels, and a muted final column. Literature uses 28% / 34% / 38% column widths; mobile presents rows as blocks.
- **Evaluation panel:** forest surface, white heading, pale copy, and lime source link.

## Do's and Don'ts

- Do use the extracted palette and Manrope hierarchy.
- Do preserve the separate static network and runtime comparisons and their explanatory captions.
- Do retain visible keyboard focus, reduced-motion behavior, and print readability.
- Do keep hypotheses and expected benefits distinct from measured results.
- Don't add shadows, gradients, or illustrative stock imagery to this brief.
- Don't remove the embedded font's copyright or OFL license.
- Don't introduce performance figures or novelty claims unsupported by evidence.
