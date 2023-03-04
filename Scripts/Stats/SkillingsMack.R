## Skillings-Mack test

## Install packages (only have to do once ever)
install.packages("R.matlab")
install.packages("Skillings.Mack")

## Load packages (every time you restart R)
library(R.matlab)
library(Skillings.Mack)

## Import data
data_list <- readMat('/Volumes/Corinne hard drive/cSS project/Saved data/One-pixel interval analysis/GFAP/Composite/All_brains_GFAP_iron_intervals.mat')
transposed_data <- data_list[['all.means']]
data <- t(transposed_data)
rm(data_list, transposed_data)

## Remove columns with no observations
dimensions <- dim(data)
brains <- dimensions[2]
categories <- dimensions[1]

for(i in brains:1) {
  if (is.na(data[1, i]) & is.na(data[2, i]) & is.na(data[3, i]) & is.na(data[4, i])) {data <- data[, -i]}
}

## Run test
Ski.Mack(data)
