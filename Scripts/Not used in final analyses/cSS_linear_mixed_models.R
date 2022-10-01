#Install packages
install.packages("lme4")
install.packages("jtools")
install.packages("lmerTest")
install.packages("car")
install.packages("influence.ME")

#Load packages 
library(car); library(ggplot2); library(nlme); library(reshape); library(ggeffects)
library(lme4); library(jtools); library(lmerTest); 
library(influence.ME)

#Use MATLAB to write matrix data into csv (csvwrite(filename, M)). Make NaNs into Nas.

#Define data
data_csv = read.csv(file = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/CSV files for stats/cortical_thickness_data.csv')

#Null model
M0 = lmer(Cortical_thickness ~ 1 + (1|Brain) + (1|Lobe), data=data_csv, na.action = na.exclude, REML = FALSE)
summary(M0)
summ(M0)
ranova(M0)
confint(M0)

#Model for ring weights
M1 = lmer(Cortical_thickness ~ Iron + Age_at_death + Sex_0_male_1_female + PMI + (1|Brain) + (1|Lobe), data=weight_coeffs, na.action = na.exclude, REML = FALSE)
summary(M1)
summ(M1)
ranova(M1)
confint(M1)

#Test ring weight model against null model
anova(M0, M1)

plot(fitted(M1_ring_weights),residuals(M1_ring_weights))
qqnorm(residuals(M1_ring_weights))
hist(residuals(M1_ring_weights))