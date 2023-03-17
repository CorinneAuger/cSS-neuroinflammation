## Skillings-Mack test

## Install packages (only have to do once ever)
install.packages("R.matlab")
install.packages("Skillings.Mack")
install.packages("dunn.test")

## Load packages (every time you restart R)
library(R.matlab)
library(Skillings.Mack)
library(dunn.test)

## Import data
# For old data
#data_list <- readMat('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel interval analysis/GFAP/Composite/All_brains_GFAP_iron_intervals.mat')

# For new data
data_list <- readMat('/Volumes/Corinne hard drive/cSS project/ALL EXCLUDED/Inflammation vs. Iron (E)/All_brains_GFAP_iron_intervals.mat')

# Reformat
transposed_data <- data_list[['all.means']]
data <- t(transposed_data)
rm(data_list)

## Remove columns with no observations
# Set up parameters
dimensions <- dim(data)
brains <- dimensions[2]
categories <- dimensions[1]

# Remove in loop
for(i in brains:1) {
  boolean_sum <- sum(is.na(data[, i]))
  if (boolean_sum == 4) {
    data <- data[, -i]
    }
}

# Change brain count and transposed data
brains <- dim(data)[2]
rm(dimensions)

transposed_data <- t(data)

## Skillings-Mack test
Ski.Mack(data)

## Dunn test of multiple comparisons
dunn.test(data, method = 'bh')

# Reformat data
conover_data <- as.list(as.data.frame(transposed_data))

