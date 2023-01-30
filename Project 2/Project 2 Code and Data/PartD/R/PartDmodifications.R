# Clear environment
rm(list = ls())
# Load libraries
library(readxl)
library(tidyverse)

# Load data
df <- read_excel("../Excel/Proj2D.xlsx")

# Finding weekdays for each day and 
df$month_number <- match(df$Month, month.name)
df$date <- paste0(df$Day,"/",df$month_number,"/",2022)
df$date1 <- as.Date(df$date, format = "%d/%m/%Y")
df$weekday <- weekdays.Date(df$date1)

# Finding the number of days:

ndays <- df %>% 
  count(date) %>% 
  summarise(n = n())
ndays <- ndays$n
nhours <- 24

# Adjusting our datafram and selecting the columns we need:
final <- df %>% 
  mutate(KwhPrice = `Price (EUR/MWh)`/1000) %>% 
  select(1,2,8,9,3)

# Creating a price matrix
price_matrix <- matrix(0, nrow = nhours, ncol = ndays)
price_indices <- 1:nrow(final)
price_matrix[price_indices] <- final$KwhPrice
price_matrix <- as.data.frame(t(price_matrix))
colnames(price_matrix) <- 1:nhours

# write.csv(price_matrix,"price_matrix.csv", row.names = FALSE)











