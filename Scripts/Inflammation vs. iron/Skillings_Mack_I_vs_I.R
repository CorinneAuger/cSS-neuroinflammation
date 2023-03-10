## Skillings-Mack test

## Install packages (only have to do once ever)
install.packages("R.matlab")
install.packages("Skillings.Mack")

# For Conover test option 1
install.packages("conover.test")

# For Conover test option 2
install.packages("DescTools")

# For Conover test option 3
install.packages('PMCMRplus')

## Load packages (every time you restart R)
library(R.matlab)
library(Skillings.Mack)

# For Conover test option 1
library(conover.test)

# For Conover test option 2
library(DescTools)

# For Conover test option 3
library(PMCMRplus)

## Import data
# For old data
data_list <- readMat('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel interval analysis/CD68/Composite/All_brains_CD68_iron_intervals.mat')

# For new data
#data_list <- readMat('/Volumes/Corinne hard drive/cSS project/ALL EXCLUDED/Inflammation vs. Iron (E)/All_brains_CD68_iron_intervals.mat')

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
  if (boolean_sum == 4 | boolean_sum == 3) {
    data <- data[, -i]
    }
}

# Change brain count and transposed data
brains <- dim(data)[2]
rm(dimensions)

transposed_data <- t(data)

## Skillings-Mack test
Ski.Mack(data)

## Conover's test of multiple comparisons
# Reformat data
conover_data <- as.list(as.data.frame(transposed_data))

# Conover test option 1
conover.test(x = conover_data, method = 'hochberg')

# Conover test option 2
ConoverTest(conover_data, method = "BH")

# Conover test option 3
kwAllPairsConoverTest(conover_data, p.adjust.method = 'BH')
