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
data_list <- readMat('/Volumes/Corinne hard drive/cSS project/ALL EXCLUDED/Lobe comparison (E)/GFAP_lobe_comparison.mat')

# Reformat
transposed_data <- data_list[['object.density.by.lobe']]
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

## Remove incomplete brains
transposed_dunn_data <- data

for(i in brains:1) {
  boolean_sum <- sum(is.na(transposed_dunn_data[, i]))
  if (boolean_sum != 0) {
    transposed_dunn_data <- transposed_dunn_data[, -i]
  }
}

dunn_data = t(transposed_dunn_data)

# Make group vector for Dunn test
size <- dim(dunn_data)
col_names <- 1:size[1]
row_names <- 1:size[2]

categories <- rep(row_names, each = size[1])

## Dunn test
dunn.test(x = c(dunn_data), g = categories, method = "bh", altp = TRUE) 

