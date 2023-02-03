# Lobe density comparison
Generates data on object density vs. cortical lobe, which can be tested for significant differences between lobes.

## Input
- Full IA details output spreadsheet for each section (download from Aiforia). All stains can go in the same folder.
- Inflammation vs. iron by section spreadsheet (from inflammation vs. iron analysis)
- Directories
	- IA details spreadsheets
	- Inflammation vs. iron by section spreadsheet
	- Save

## Output
- Excel file with object densities. Each row represents a brain, and each column represents a cortical region. Each stain is on its own sheet.
- For each stain…
	- Box plot with each section represented as a dot. Each column represents a cortical region.
	- Matrix with object densities. Each row represents a brain, and each column represents a cortical region.

## For complete analysis
Run lobe_density_comparison.m