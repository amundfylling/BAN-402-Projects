rm(list = ls())
setwd("~/Documents/Studier/7. semester/BAN402/ban402-project2/PartD/R")

library(readxl)
library(ggplot2)
library(magrittr)
library(tidyverse)
library(lubridate)

# D1: Minimization problem -------
d1_minimize <-
  read_excel("../Data/results1.xlsx") %>% 
  mutate(eur_kwh = eur_mwh/1000,
         weekday = wday(date, 
                        week_start=1, 
                        label = T))

# Double-checking that the total kwh charged are same as in AMPL
d1_minimize %>% 
  summarize(total_kwh = sum(kwh_charged))

weight_d1 <- 800 # Stores as variable to make sure the price is weighted properly

plot_weekday_min <-
  d1_minimize %>% 
  group_by(weekday) %>% 
  filter(!(weekday %in% NA)) %>% # Remove NA-values from day zero
  summarize(avg_price = mean(eur_kwh),
            kwh_weekday = sum(kwh_charged)) %>% 
  ggplot(na.rm = TRUE) +
  geom_col(aes(x = weekday,
               y = kwh_weekday)) +
  geom_line(aes(x = weekday,
                y = avg_price*weight_d1,
                group=1)) +
  geom_point(aes(x = weekday,
                y = avg_price*weight_d1,
                group=1)) +
  scale_y_continuous(name = 'Total kWh charged', sec.axis = sec_axis(~./weight_d1, name = 'EUR/kWh')) +
  theme_classic() +
  ggtitle("Charging pattern based on weekday",
          subtitle = "Bar chart = total kWh charged on each weekday in the period \nLine chart = average price each weekday in the period") +
  xlab("Weekday")

plot_weekday_min

# D1: Maximization problem -------
d1_maximize <-
  read_excel("../Data/results1_maximize.xlsx") %>% 
  mutate(eur_kwh = eur_mwh/1000,
         weekday = wday(date, 
                        week_start=1, 
                        label = T))

# Double-checking that the total kwh charged are same as in AMPL
d1_maximize %>% 
  summarize(total_kwh = sum(kwh_charged))

weight_d1_max <- 800 # Stores as variable to make sure the price is weighted properly

plot_weekday_max <-
  d1_maximize %>% 
  group_by(weekday) %>% 
  filter(!(weekday %in% NA)) %>% # Remove NA-values from day zero
  summarize(avg_price = mean(eur_kwh),
            kwh_weekday = sum(kwh_charged)) %>% 
  ggplot(na.rm = TRUE) +
  geom_col(aes(x = weekday,
               y = kwh_weekday)) +
  geom_line(aes(x = weekday,
                y = avg_price*weight_d1,
                group=1)) +
  geom_point(aes(x = weekday,
                 y = avg_price*weight_d1,
                 group=1)) +
  scale_y_continuous(name = 'Total kWh charged', sec.axis = sec_axis(~./weight_d1_max, name = 'EUR/kWh')) +
  theme_classic() +
  ggtitle("Charging pattern based on weekday",
          subtitle = "Bar chart = total kWh charged on each weekday in the period \nLine chart = average price each weekday in the period") +
  xlab("Weekday")

plot_weekday_max


# D2: --------

d2 <-
  read_excel("../Data/results2.xlsx") %>% 
  mutate(eur_kwh = eur_mwh/1000) %>% 
  mutate(time = seq(1:2232))

# Plot with price and kwh charged every hour
weight <- 10 # Stores as variable to make sure the price is weighted properly

plot <-
  d2 %>%
  ggplot() +
  geom_point(aes(x = time,
               y = kwh_charged),
            color = "black",
            alpha = 0.2) +
  geom_line(aes(x = time,
            y = eur_kwh*weight),
            color = "#4c7ea4", alpha = 0.5) +
  theme_classic() +
  scale_y_continuous(name = 'kWh charged', sec.axis = sec_axis(~./weight, name = 'EUR/kWh'), limits = c(0.01,8.5)) +
  ggtitle("kWh charged and electricity price in the period July-September",
          subtitle = "kWh charged in hour = black dots \nEUR/kWh = blue line\nHours with price below €0.05 = Red dashed line") +
  xlab("Hour in period") +
  geom_vline(xintercept = d2$time[d2$eur_kwh < 0.05], 
             color = "red",
             linetype = "dashed",
             alpha = 0.1)

plot


# D3 -------
d3 <-
  read_excel("../Data/results3.xlsx") %>% 
  mutate(eur_kwh = eur_mwh/1000,
         weekday = wday(date, 
                        week_start=1, 
                        label = T),
         eur_kwh = eur_mwh/1000,
         time = seq(1:2232))




# Double-checking that the total kwh charged are same as in AMPL
d3 %>% 
  summarize(total_kwh = sum(kwh_charged))


# D4 ------
d4 <-
  read_excel("../Data/results4.xlsx") %>% 
  mutate(eur_kwh = eur_mwh/1000,
         weekday = wday(date, 
                        week_start=1, 
                        label = T),
         eur_kwh = eur_mwh/1000,
         time = seq(1:1344))


# Double-checking that the total kwh charged are same as in AMPL
d4 %>% 
  summarize(total_kwh = sum(kwh_charged))


d4weight <- 10 # Stores as variable to make sure the price is weighted properly

d4plot <-
  d4 %>%
  ggplot() +
  geom_point(aes(x = time,
                 y = kwh_charged),
             color = "black",
             alpha = 0.2) +
  geom_line(aes(x = time,
                y = eur_kwh*d4weight),
            color = "#4c7ea4", alpha = 0.5) +
  theme_classic() +
  scale_y_continuous(name = 'kWh charged', sec.axis = sec_axis(~./d4weight, name = 'EUR/kWh'), limits = c(0.01,8.5)) +
  ggtitle("kWh charged and electricity price in the period August-September",
          subtitle = "kWh charged in hour = black dots \nEUR/kWh = blue line\nHours with price below €0.05 = Red dashed line") +
  xlab("Hour in period") +
  geom_vline(xintercept = d4$time[d4$eur_kwh < 0.05], 
             color = "red",
             linetype = "dashed",
             alpha = 0.1)

d4plot

d4weight2 <- 100

d4plot2 <-
  d4 %>%
  ggplot() +
  geom_line(aes(x = time,
                y = SOC),
            color = "black") +
  geom_line(aes(x = time,
                y = eur_kwh*d4weight2),
            color = "#4c7ea4",
            alpha = 0.5) +
  theme_classic() +
  scale_y_continuous(name = 'State-of-charge (kWh)', sec.axis = sec_axis(~./d4weight2, name = 'EUR/kWh')) +
  ggtitle("State-of-charge and electricity price in the period August-September",
          subtitle = "Red line indicates where SOC is 50% and 80% of full capacity\nState of charge = black line \nElectricity price = blue line") +
  xlab("Hour") +
  geom_hline(yintercept = c(32, 51.2),
             color = "red",
             alpha = 0.3)

d4plot2


