rm(list=ls()) #removes all variables stored previously

#--------------------------------------------------------------------------------------------
#renamed to data for convenience

data <- read.csv("C:/Users/mjabb/OneDrive/Desktop/COVID_R/COVID19_line_list_data.csv")
View(data)

#--------------------------------------------------------------------------------------------
  
install.packages('Hmisc')
library(Hmisc) #import

describe (data) #Hmisc command

#--------------------------------------------------------------------------------------------
#clean up death column to make all 1 and 0

data$Death_Dummy <- as.integer(data$death != 0)

#--------------------------------------------------------------------------------------------
#Death Rate

sum(data$Death_Dummy) / nrow(data)

#AGE 
#verify that older individuals are more likely to die from Covid

dead = subset(data, Death_Dummy == 1)
alive = subset(data, Death_Dummy == 0)

mean(dead$age, na.rm = TRUE)
mean(alive$age, na.rm = TRUE)

#is this statistically significant?

t.test(alive$age, dead$age, alternative ="two.sided", conf.level = 0.95)
#95% chance that age difference between dead and alive is between 16-24 years
# p value is way below 0.05 so statistically significant
# this provides strong evidence that those that die from Covid are much older than survivors

#--------------------------------------------------------------------------------------------

#GENDER
#Are there any differences in survival between men and women?

men = subset(data, gender == "male")
women = subset(data, gender == "female")

#death rate men vs women

mean(men$Death_Dummy, na.rm = TRUE) #8.4%
mean(women$Death_Dummy, na.rm = TRUE) #3.7%

t.test(men$Death_Dummy, women$Death_Dummy, alternative ="two.sided", conf.level = 0.95)
# 95% confidence: men have from 1.7% to 7.8% higher chance of death
# p-value 0.002 < 0.05, so statistically significant
  
