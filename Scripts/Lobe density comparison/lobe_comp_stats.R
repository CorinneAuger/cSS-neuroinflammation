## Skillings-Mack test: lobe comparison

## Install packages (only have to do once ever)
install.packages("R.matlab")
install.packages("Skillings.Mack")
install.packages("dunn.test")

## Load packages (every time you restart R)
library(R.matlab)
library(Skillings.Mack)
library(dunn.test)

## Import data
data_list <- readMat('/Volumes/Corinne hard drive/cSS project/ALL EXCLUDED/Lobe comparison (E)/Iron_lobe_comparison.mat')

# Reformat
conover_data <- data_list[['object.density.by.lobe']]
## Remove columns with no observations for Skillings-Mack
# Set up parameters
dimensions <- dim(conover_data)
brains <- dimensions[1]
categories <- dimensions[2]
SM_data <- conover_data

# Remove in loop
for(i in brains:1) {
  boolean_sum <- sum(is.na(SM_data[i, ]))
  if (boolean_sum == 4 || boolean_sum == 3) {
    SM_data <- SM_data[-i,]
  }
}


## Skillings-Mack test
Ski.Mack(t(SM_data))


## Conover test
# Make group vector
col_names <- 1:dimensions[1]
row_names <- 1:dimensions[2]

iron_scores <- rep(row_names, each = dimensions[1])

# Conover test
conover.test(x = c(conover_data), g = iron_scores, method = "hochberg", altp = TRUE) 
