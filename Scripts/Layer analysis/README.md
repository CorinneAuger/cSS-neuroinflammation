# Layer analysis
Compares the densities of Aiforia-identified objects between 1000um-thick artificial cortical layers for one stain at a time.

## Input
- All variables files from heat map analysis
- Directories
	- All variables files from heat map analysis
	- Layer analysis scripts folder
	- Save
		- For each stain:
			- Composite
			- Heat map figures
			- Interval figures
			- Object density vs. layer matrices

## Output
- For each section with each stain…
	- Figure displaying cortical layer masks in different colors
	- Variables from edge_analysis.m
- Plots of object density vs. cortical layer, with the 25th, 50th, and 75th percentiles indicated and the mean object density in each brain represented as a point for each artifical cortical layer
- Matrices of the object density at each artificial cortical layer with each stain

## For complete analysis
1. For each stain, run edge_analysis.m on each non-ICH slide. Because it requires manual inputs, it probably won't all get done in one session, so it makes more sense to change the brain and block numbers than to use a loop. Follow prompts for manual inputs.
	- Fill in the edge of a slide where there is not tissue but where the tissue was cut (not a true cortical edge) as if there were tissue there.
2. Optional: run color_darken.py to get darkened colors for point borders on plots if you want to change them. They're hard-coded into the section of layer_analysis_composite.m called "Set up color palettes."
3. Run layer_analysis_composite.m for each stain.
4. Run layer_analysis_check.m for each stain.
