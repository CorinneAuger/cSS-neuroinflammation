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
no_NaN_data_csv = read.csv(file = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/CSV files for stats/No PMI NaNs/cortical_thickness_data_without_PMI_NaNs.csv')
all_data_csv = read.csv(file = '/Users/corinneauger/Documents/Aiforia heatmap coregistration/Saved data/CSV files for stats/cortical_thickness_data.csv')



#Full model without PMI NaNs
M1_no_NaNs = lmer(Cortical_thickness ~ Iron + Age_at_death + Sex_0_male_1_female + PMI + (1|Brain) + (1|Lobe), data=no_NaN_data_csv, na.action = na.exclude, REML = FALSE)
#error: some predictor variables are on very different scales: consider rescaling
summary(M1_no_NaNs)

#Test if PMI matters: not significant (bottom right corner) -> leave it out of final model?
M_sans_PMI = lmer(Cortical_thickness ~ Iron + Age_at_death + Sex_0_male_1_female + (1|Brain) + (1|Lobe), data=no_NaN_data_csv, na.action = na.exclude, REML = FALSE)
anova(M_sans_PMI, M1_no_NaNs) #would use ranova for ring weights and anything else where the same sections show up in multiple groups

#Test other fixed effects (out of curiosity): neither is significant
M_sans_age = lmer(Cortical_thickness ~ Iron + PMI + Sex_0_male_1_female + (1|Brain) + (1|Lobe), data=no_NaN_data_csv, na.action = na.exclude, REML = FALSE)
anova(M_sans_age, M1_no_NaNs)

M_sans_sex = lmer(Cortical_thickness ~ Iron + Age_at_death + PMI + (1|Brain) + (1|Lobe), data=no_NaN_data_csv, na.action = na.exclude, REML = FALSE)
anova(M_sans_sex, M1_no_NaNs)



#Test all effects vs. none (is it ever significant? nope!)
M0_no_NaNs = lmer(Cortical_thickness ~ 1 + (1|Brain) + (1|Lobe), data=no_NaN_data_csv, na.action = na.exclude, REML = FALSE)
anova(M0_no_NaNs, M1_no_NaNs)



#Final model before testing assumptions
M1 = lmer(Cortical_thickness ~ Iron + (1|Brain) + (1|Lobe), data=all_data_csv, na.action = na.exclude, REML = FALSE)
#error: some predictor variables are on very different scales: consider rescaling
summary(M1)

#Final null model before testing assumptions
M0 = lmer(Cortical_thickness ~ 1 + (1|Brain) + (1|Lobe), data=all_data_csv, na.action = na.exclude, REML = FALSE)
summary(M0)

#Significance testing on final model before testing assumptions
anova(M0, M1)



#Test assumptions
#1. linearity: points should follow center line without obvious pattern--use graph for #2.
#2. homoskedasticity: points should form "blob" shape rather than triangle (in case of triangle, "consider log transform")
plot(fitted(M1),residuals(M1), ylim=c(-2, 2))^2  
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
