# This is the main cortical thickness LME model. 
# If you run everything it will give the model and a graph, but it makes more sense to test assumptions one by one.

#Install packages (only have to do once ever)
install.packages("lme4")
install.packages("jtools")
install.packages("lmerTest")
install.packages("car")
install.packages("influence.ME")
install.packages("ggplot2")

#Load packages (do every time you restart R)
library(car); library(ggplot2); library(nlme); library(reshape); library(ggeffects)
library(lme4); library(jtools); library(lmerTest); 
library(influence.ME);

#Clear environment
rm(list = ls())

#Define data (can change)
data_csv = read.csv('/Volumes/Corinne hard drive/cSS project/ALL EXCLUDED/By section table (E)/Iron_and_inflammation_quantities_by_section.csv')

#Model before testing assumptions
M1 = lmer(GFAP ~ Iron + Age_at_death + Sex_0_male_1_female + (1|Brain) + (1|Lobe), data=data_csv, na.action = na.exclude, REML = FALSE)
#error: some predictor variables are on very different scales: consider rescaling
summary(M1)

#Null model before testing assumptions
M0 = lmer(GFAP ~ Age_at_death + Sex_0_male_1_female + (1|Brain) + (1|Lobe), data=data_csv, na.action = na.exclude, REML = FALSE)
summary(M0)


#Test assumptions
#1. linearity: points should follow center line without obvious pattern going up or down--use graph for #2.
#2. homoskedasticity: points should form "blob" shape rather than triangle (in case of triangle, "consider log transform")
plot(fitted(M1),residuals(M1), ylim=c(-2, 2))^2  
abline(h = 0)

#3. normality of residuals: data should look normal on histogram/fall along line on Q-Q plot.
#If the middle has a shallower slope than the edges on a Q-Q plot, the distribution has fatter tails than normal distribution.
#This is the least important assumption; fairly robust against violation.
hist(residuals(M1))

qqnorm(residuals(M1))
qqline(residuals(M1))

#4. absence of influential data points: bad to have 1 point much farther to the right than the others
number_of_brains = 19
cut_off_value = 4/number_of_brains
estex.M1 = influence(M1, "Brain")
cook_values <- cooks.distance(estex.M1, sort=TRUE)

#remove influential data points and make a new model
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

#keep running new cook analyses on new models until there are no more overly influential points
while (is.na(influential_points[1]) == 0){
  estex.new_full_model = influence(new_full_model, "Brain")
  cook_values_new <- cooks.distance(estex.new_full_model, sort=TRUE)
  
  for (i in nrow(cook_values_new)){
    if(cook_values_new[i] > cut_off_value){
      brain_no = row_names[i]
      print(paste("CAA_", brain_no, "is too influential"))
      
      val = cook_values_new[i]
      influential_points = rbind(influential_points, c(brain_no, val))
      
      new_null_model = exclude.influence(new_null_model, "Brain", brain_no)
      new_full_model = exclude.influence(new_full_model, "Brain", brain_no)
    }
  }
}

#Get stats for each fixed effect
summary(new_null_model)       #estimates, p-values
summ(new_null_model)          #R^2
confint(new_null_model)       #confidence intervals for estimates

summary(new_full_model)
summ(new_full_model)
confint(new_full_model)


#Test significance of model
#AIC, BIC, and log likelihoods; model chi-sq and p-val
anova(new_null_model, new_full_model)    


#PLOT
#Extract the prediction data frame
pred.mm <- ggpredict(new_full_model, terms = c("Iron"))  # this gives overall predictions for the model

#Plot the predictions 
(ggplot(pred.mm) + 
    geom_line(aes(x = x, y = predicted)) +          # slope
    geom_ribbon(aes(x = x, ymin = predicted - std.error, ymax = predicted + std.error), 
                fill = "lightgrey", alpha = 0.5) +  # error band
    geom_point(data = no_NaN_data_csv, size = 2,                      # adding the raw data
               aes(x = Iron, y = GFAP, colour = factor(Lobe))) + 
    labs(x = "Iron deposits", y = "GFAP-positive cells") + 
    theme_classic()+
    theme(plot.title = element_text(hjust=0.5, face = "bold", size= 13)) + 
    theme(axis.text.x = element_text(size = 12, face="bold"), axis.title.x = element_text(size = 12, face="bold"), axis.text.y = element_text(size = 12, face="bold"), axis.title.y = element_text(size = 12, face="bold"))
)
