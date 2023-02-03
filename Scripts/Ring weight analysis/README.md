# Ring weight analysis
Assesses the spatial extent of iron's effect on inflammatory cells by comparing estimated inflammation heat maps based on different coefficients by which to multiply the iron density in rings around each pixel. Only assesses sections with a positive slope for inflammation objects vs. iron objects.

## Input
- All variables files from heat map analysis
- Crucial variables files from heat map analysis
- Directories
	- All variables files from heat map analysis
	- Crucial variables files from heat map analysis
	- Scripts
	- Save 
		- For each stain:
			- Pixel only, 1 ring, 2 rings, 3 rings
				- Under each, separate "By section" and "Composite" folders
					- If using ring_weight_predicted _map_figures, make a folder called "Figures" under "By section"
			- Residual comparison
				- Normalized and non-normalized, if desired
					
## Output
- For each stain:
	- Variables from the analysis for each section with a positive slope for inflammation objects vs. iron objects
	- Matrix of mean best coefficient combination for each brain
	- Variables from composite coefficient analysis
	- Box plot of coefficient vs. ring
	- Matrix of mean lowest residual for each brain
	- Box plot of residual vs. ring

## For complete analysis
1. Run flexible_columns_ring_weight_analysis with inflammatory_marker = 'GFAP' and again with inflammatory_marker = 'CD68' (gets data for individual sections)
2. Run composite_flexible_columns_ring_weight_analysis (combines individual section data into composite coefficient data)
3. Run residual_analysis (composite residual data)
Optional: run ring_weight_predicted_map_figures.m, then look through the output to find good example heat maps for figures