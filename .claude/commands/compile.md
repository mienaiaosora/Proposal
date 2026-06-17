Compile a LaTeX file in this project and report the result.

The user will specify which file to compile (e.g. "model" or "main"). If not specified, ask.

Steps:
1. Determine the target: resolve to `model.tex` or `main.tex` (or whichever .tex file the user names).
2. Run `latexmk -pdf -interaction=nonstopmode <target>` from the project root `/Volumes/ORICO/Proposal for SYP/Proposal/`. (Note: `-biber` is not a valid latexmk CLI flag; biber is invoked automatically from the preamble declaration.)
3. If it succeeds: report "Compiled successfully — no errors." and note the output PDF name.
4. If it fails: parse the log for ERROR lines and overfull hbox warnings. Report only actionable issues — file name, line number, error message. Do not dump the full log.
5. If there are fixable LaTeX errors (undefined references, missing packages, syntax errors), fix them and recompile. Only surface to the user if the fix requires a decision.
