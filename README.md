# cSS and neuroinflammation
For the paper entitled "Cortical Superficial Siderosis is Associated with Chronic Neuroinflammation in Cerebral Amyloid Angiopathy." 

Spatial analyses to compare the densities of reactive astrocytes (GFAP) and activated microglia (CD68) to that of iron and to examine where iron is located in tissue.

Takes NanoZoomer-digitized sections of 6um-thick formalin-fixed, paraffin-embedded cortical tissue and output from Aiforia models.

## For complete analysis:
1. **Heat map analysis:** generates a heat map of object quantities in 500um * 500 um pixels for each stained section
2. **Layer analysis:** compares the densities of Aiforia-identified objects between 1000um-thick artificial cortical layers for one stain at a time
3. **Inflammation vs. iron:** compares  to the number of inflammatory cells, as a continuous variable, to the number of iron deposits, as a categorical variable, within 500um * 500um pixels. The analysis is repeated for the outer edge (1000um thick) and the area everywhere else, using 250um * 250um and 500um * 500um pixels, respectively.
4. **Ring weight analysis:** assesses the spatial extent of iron's effect on inflammatory cells by comparing estimated inflammation heat maps based on different coefficients by which to multiply the iron density in rings around each pixel.
5. **Cortical thickness:** compares mean cortical thickness to the number of iron deposits within sections
6. **Lobe density comparison:** generates data on object density vs. cortical lobe, which can be tested for significant differences between lobes.

## Contact: 
Corinne Auger

Lab technician, Van Veluw lab (MGH Institute for Neurodegenerative Disease), 2020-2023

corinneauger7@gmail.com
