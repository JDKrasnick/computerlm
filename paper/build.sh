#!/bin/sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
mkdir -p "$repo_dir/output/pdf"
tectonic --outdir "$repo_dir/output/pdf" "$repo_dir/paper/proposal.tex"
