# Import packages
import scikit_posthocs 
import scipy
import numpy as np

workspace = scipy.io.loadmat('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel interval analysis/GFAP/Composite/All_brains_GFAP_iron_intervals.mat')
data = workspace['all_means']
data = np.nan_to_num(data, nan=1)

result = scikit_posthocs.posthoc_conover(data.T)

print(result)