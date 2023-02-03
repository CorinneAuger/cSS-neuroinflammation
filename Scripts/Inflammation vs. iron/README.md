# Inflammation vs. iron
Compares  to the number of inflammatory cells, as a continuous variable, to the number of iron deposits, as a categorical variable, within 500um * 500um pixels. Repeated for the outer edge (1000um thick) and the area everywhere else, using 250um * 250um and 500um * 500um pixels, respectively.

## Input
- Full IA details output spreadsheet from Aiforia for each section. All stains can go in the same folder.
- Variables from cortical thickness analysis
- Crucial variables files from heat map analysis
- Variables from layer analysis
- Image sizes spreadsheets (ex. "Aiforia_image_sizes_CD68.xlsx")
	- Make this spreadsheet manually.
		- Column A: "Brain/block"/name of slide (ex. "CAA1_1")
		- Column E: "Excluded"
			- 0: included in the analysis
			- 1: excluded from the analysis because of problems with coregistration
			- 2: ICH
- Directories
	- IA details spreadsheets
	- Variables from cortical thickness analysis
	- Crucial variables files from heat map analysis
	- Variables from layer analysis
	- Image sizes spreadsheets
	- Scripts folders
		- For inflammation vs. iron analysis
		- For heat map analysis
	- Save
		- Non-ICH sections
			- Spreadsheet with LME data by section
			- Inflammation vs. iron composite data and figure
			- Individual slide figures
			- For the outer-edge analysis:
				- Composite data
				- Heat map figures for each slide
				- Interval figures for each slide
				- Variables for each slide
		- ICH sections
			- Inflammation vs. iron composite data and figure
			- Individual slide figures
			
## Output
- By section
	- Spreadsheet with non-ICH data by section (iron, GFAP, and CD68 object quantities; brain; lobe; sex; age at death) 
- General inflammation vs. iron (non-ICH). For each inflammatory marker…
	- Histograms for each brain, featuring each pixel as a point in one column 
	- Composite histogram with each brain as a point in each column 
	- Matrix of inflammation quantity at each iron interval for each brain
- ICH analysis. For each inflammatory marker…
	- Histograms for each brain, featuring each pixel as a point in one column 
	- Composite histogram with each brain as a point in each column 
	- Composite matrix of inflammation quantity at each iron interval for each section
- Outer-edge analysis. For each inflammatory marker…
	- For each section:
		- Histogram featuring each pixel as a point in one column. One histogram for 250um * 250um pixels in the outer 1000um; another for 500um * 500um pixels everywhere else.
		- Heat map figures showing the outer-edge pixels and all pixels except those in the outer edge, for iron and inflammation
	- For each brain:
		- Matrix of mean inflammation quantity at each iron interval
	- For all brains together:
		- Histogram with each brain as a point in each column 
		- Matrix of inflammation quantity at each iron interval in each brain

## For complete analysis
1. Run Inflammation_vs_iron_by_section (for non-ICH sections)
2. Run iron_intervals_composite.m for each inflammatory marker (for non-ICH sections)
3. Run outer_layer_iron_intervals.m for each inflammatory marker (for non-ICH sections; to make sure effect isn't only driven by outer edge)
4. Run ICH_iron_intervals.m for each inflammatory marker (for ICH sections)
