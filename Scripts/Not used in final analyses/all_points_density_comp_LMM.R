#Install packages
install.packages("lme4")
install.packages("jtools")
install.packages("lmerTest")
install.packages("car")
install.packages("influence.ME")
install.packages("ggplot2")

#Load packages 
library(car); library(ggplot2); library(nlme); library(reshape); library(ggeffects)
library(lme4); library(jtools); library(lmerTest); 
library(influence.ME)

#Clear environment
rm(list = ls())

#Define data
all_data_csv = read.csv(file = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/CSV files for stats/all_points_GFAP_density_comparison.csv')


#Model before testing assumptions
M1 = lmer(Inflammation_density ~ Iron_density + Age_at_death + Sex_0_male_1_female + (1|Brain) + (1|Lobe), data=all_data_csv, na.action = na.exclude, REML = FALSE)
#error: boundary (singular) fit
summary(M1)

#Null model before testing assumptions
M0 = lmer(Inflammation_density ~ 1 + Age_at_death + Sex_0_male_1_female + (1|Brain) + (1|Lobe), data=all_data_csv, na.action = na.exclude, REML = FALSE)
summary(M0)

#Sanity check pre-assumption anova
anova(M0, M1)



#Test assumptions
#1. linearity: points should follow center line without obvious pattern going up or down--use graph for #2.
#2. homoskedasticity: points should form "blob" shape rather than triangle (in case of triangle, "consider log transform")
plot(fitted(M1),residuals(M1), ylim=c(-15, 15), pch = '.')^2  
abline(h = 0)

#3. normality of residuals: data should look normal on histogram/fall along line on Q-Q plot.
#If the middle has a shallower slope than the edges on a Q-Q plot, the distribution has fatter tails than normal distribution.
#This is the least important assumption; fairly robust against violation.
hist(residuals(M1))

qqnorm(residuals(M1))
qqline(residuals(M1))

#4. absence of influential data points: bad to have 1 point much further to the right than the others
number_of_brains = 19 
cut_off_value = 4/number_of_brains
estex.M1 = influence(M1, "Brain")
cook_values <- cooks.distance(estex.M1, sort=TRUE)

influential_points = matrix(nrow = 1, ncol = 2)
row_names = row.names(cook_values)
new_null_model = M0
new_full_model = M1

for (i in nrow(cook_values)){
  if(cook_values[i] > cut_off_value){
    brain_no = row_names[i]
    print(paste("CAA_", brain_no, "is too influential"))
    
    val = cook_values[i]
    influential_points = rbind(influential_points, c(brain_no, val))
    
    new_null_model = exclude.influence(new_null_model, "Brain", brain_no)
    new_full_model = exclude.influence(new_full_model, "Brain", brain_no)
  }
}



summary(new_null_model)
summary(new_full_model)


#Testing significance for real
anova(new_null_model, new_full_model)
