# About
This project analyzes FitBit smartwatch data using R, exploring activity patterns, sleep trends, and calorie expenditure. 
The goal was to identify interesting patterns and insights into users' health, which can serve various purposes, including the marketing of smartwatches and other FitBit smart products. 

# Process Overview
*Cleaning:*
Standardization of column names, dropping unnecessary columns, formatting dates, removing duplicates, and deleting inconsistent users and rows with unrealistic entries.

*Analysis:*
The granularity of the data differs between the .csv files, so each file was analyzed independently and later combined. There were a few obstacles, such as the lack of data on physical features, age, and health of users. Therefore, most conclusions were assumed for an average adult.

At the beginning of each table, we plotted a boxplot to show the distribution of each attribute. From this, we concluded, for example:
* The majority of users do not have physically demanding jobs.
* They walk, on average, 5 km a day.
* Approximately one-third of users wake up between 5–6 AM, and the other two-thirds wake up between 6–7 AM and 7–8 AM, and so on.

We categorized users based on their lifestyle (sedentary to highly active) and plotted the results. We found that 21.9% of users are sedentary, while only 9.4% are highly active. Additionally, we grouped entries by weekday and performed a Chi-square test to determine that there is a significant difference in the number of steps taken on Sundays compared to those taken on Tuesdays or Saturdays, which are considered the most active days, on average. This led to the recommendation of incorporating the distinct step goals feature, where users could insert the different threshold for each weekday and not lose motivation throughout the week.

We also categorized users based on their average sleep hours per night. It turns out that 18% of people sleep less than 5 hours a night, which is considered unhealthy, and 5% of people sleep more than 10 hours, which can also be concerning. This sparked the recommendation of alarming the users with a pop-up if their week's sleep score was bad and showing them where to look for help. We ran a t-test to check whether more sleep leads to better sleep quality, but it showed that these two factors are not necessarily connected. Later, in an independent analysis of this dataset was shown that 5.8-7.2 hours of sleep gives the best quality sleep.

Next, we tried to find a connection between activity and sleep. We concluded that the number of steps doesn’t have much impact on a good night’s sleep (according to the t-test), but it has been proven that 45 minutes of higher physical activity improves sleep by 13.5 fewer minutes of wake time (based on Fisher's Exact Test).

Finally, we created a linear model to explore the relationship between steps and calorie expenditure. We concluded that one calorie could be burned by taking approx. 11.2 steps, and on average, during a sedentary hour, a person will burn 68.66 calories.

# Used for analysis
R, with packages `tidyverse`, `ggplot2`, `lubridate`, `dplyr`

## Note: 
This project was part of a university exam, so some comments or files may be in Serbian.
