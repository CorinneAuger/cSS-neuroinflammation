# Cortical thickness

Compares mean cortical thickness to the number of iron deposits within sections

## Input
- Full IA details output spreadsheet for each section (download from Aiforia). All stains can go in the same folder.
- Image sizes spreadsheet (ex. "Aiforia_image_sizes_CD68.xlsx")
	- Make this spreadsheet manually.
		- Column A: "Brain/block"/name of slide (ex. "CAA1_1")
		- Column B: "Width"
			- Info is in "Images" folder for the stain on Aiforia, in list view. Unit: px.
		- Column C: "Height"
			- Info is in "Images" folder for the stain on Aiforia, in list view. Unit: px.
		- Column D: "Rotation" to match iron slide
			- 0: none
			- 1: 180° 
			- 2: 90° counterclockwise
		- Column E: "Excluded"
			- 0: included in analysis
			- 1: excluded from analysis because of problems with coregistration
			- 2: ICH
- Directories
	- Scripts folders
	- IA details spreadsheets
	- Image sizes spreadsheet
	- Save 

## Output
- Non-LME graph of cortical thickness vs. iron deposits
- Variables from the non-LME analysis, including a matrix with iron deposit quantity in column A and cortical thickness in column B
- CSV with case info 
- Statistics and plot from LME model
		
## For complete analysis:
1. Run cortical_thickness_vs_iron.m (assemble data on cortical thickness and iron deposit quantity per section)
2. Run cortical_thickness_csv.m (put iron and cortical thickness data and other fixed effects into a .csv file for a linear mixed effects model) 
3. Run cortical_thickness_LMM_excluding_NaN_PMIs.R (get LME model)
