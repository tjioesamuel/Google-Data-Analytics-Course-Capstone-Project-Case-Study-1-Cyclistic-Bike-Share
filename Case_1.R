# Install the necessary packages

install.packages("tidyverse")
install.packages("lubridate")
install.packages("skimr")
install.packages("janitor")
install.packages("dplyr")
install.packages("data.table")

# Load the installed packages

library(tidyverse)
library(lubridate)
library(skimr)
library(janitor)
library(dplyr)
library(data.table)

# Create the databases from CSV files

Trip_202106 <- read_csv("C:\\Users\\User\\Downloads\\Case_1\\Data\\202106-divvy-tripdata\\202106-divvy-tripdata.csv")
Trip_202107 <- read_csv("C:\\Users\\User\\Downloads\\Case_1\\Data\\202107-divvy-tripdata\\202107-divvy-tripdata.csv")
Trip_202108 <- read_csv("C:\\Users\\User\\Downloads\\Case_1\\Data\\202108-divvy-tripdata\\202108-divvy-tripdata.csv")
Trip_202109 <- read_csv("C:\\Users\\User\\Downloads\\Case_1\\Data\\202109-divvy-tripdata\\202109-divvy-tripdata.csv")
Trip_202110 <- read_csv("C:\\Users\\User\\Downloads\\Case_1\\Data\\202110-divvy-tripdata\\202110-divvy-tripdata.csv")
Trip_202111 <- read_csv("C:\\Users\\User\\Downloads\\Case_1\\Data\\202111-divvy-tripdata\\202111-divvy-tripdata.csv")
Trip_202112 <- read_csv("C:\\Users\\User\\Downloads\\Case_1\\Data\\202112-divvy-tripdata\\202112-divvy-tripdata.csv")
Trip_202201 <- read_csv("C:\\Users\\User\\Downloads\\Case_1\\Data\\202201-divvy-tripdata\\202201-divvy-tripdata.csv")
Trip_202202 <- read_csv("C:\\Users\\User\\Downloads\\Case_1\\Data\\202202-divvy-tripdata\\202202-divvy-tripdata.csv")
Trip_202203 <- read_csv("C:\\Users\\User\\Downloads\\Case_1\\Data\\202203-divvy-tripdata\\202203-divvy-tripdata.csv")
Trip_202204 <- read_csv("C:\\Users\\User\\Downloads\\Case_1\\Data\\202204-divvy-tripdata\\202204-divvy-tripdata.csv")
Trip_202205 <- read_csv("C:\\Users\\User\\Downloads\\Case_1\\Data\\202205-divvy-tripdata\\202205-divvy-tripdata.csv")

# Check if there is any mismatch in columns datatypes

compare_df_cols(Trip_202106, Trip_202107, Trip_202108, Trip_202109, Trip_202110,
                Trip_202111, Trip_202112, Trip_202201, Trip_202202, Trip_202203,
                Trip_202204, Trip_202205, return = "mismatch")


# Combine the databases into one database bike_data

bike_data <- rbind(Trip_202106, Trip_202107, Trip_202108, Trip_202109, Trip_202110,
                   Trip_202111, Trip_202112, Trip_202201, Trip_202202, Trip_202203,
                   Trip_202204, Trip_202205)

# Create a backup of the database bike_data

bike_data_backup <- bike_data

# Examine the database bike_data

colnames(bike_data)

dim(bike_data)

head(bike_data)

str(bike_data)

summary(bike_data)

skim(bike_data)

# Adding new columns to allow analysis

bike_data$date        <- as.Date(bike_data$started_at) # add a new date column. Default format is yyyy-mm-dd
bike_data$day_of_week <- format(as.Date(bike_data$date), "%A")
bike_data$day         <- format(as.Date(bike_data$date), "%d") # add a new day column
bike_data$month       <- format(as.Date(bike_data$date), "%b_%y") # add a new month column formatted as short month_year (e.g. mar_2022)
bike_data$year        <- format(as.Date(bike_data$date), "%Y")
bike_data$ride_length <- (as.double(difftime(bike_data$ended_at, bike_data$started_at))) / 60 # calculate ride_length in mins

# Convert ride_length column from Factor to numeric to allow calculations on the values

is.factor(bike_data$ride_length)
bike_data$ride_length <- as.numeric (as.character(bike_data$ride_length))
is.numeric(bike_data$ride_length)

summary(bike_data)

# Data Cleaning

bike_data <- distinct(bike_data) # remove any duplicates
bike_data <- bike_data [!(bike_data$ride_length<0),] # remove negative ride lengths

# Change a few column names for better clarification
bike_data <- rename(bike_data, bike_type = rideable_type)
bike_data <- rename(bike_data, customer_type = member_casual)

# remove missing values
bike_data <- drop_na(bike_data)
bike_data <- remove_empty(bike_data)

# Ordering values to keep the results of the analysis by day of week and by month
bike_data$day_of_week <- ordered(bike_data$day_of_week, levels = c("Monday", "Tuesday", "Wednesday", "Thursday",
                                                                   "Friday", "Saturday", "Sunday"))
bike_data$month       <- ordered(bike_data$month, levels = c("Jun_21", "Jul_21", "Aug_21", "Sep_21", "Oct_21", "Nov_21", "Dec_21",
                                                       "Jan_22", "Feb_22", "Mar_22", "Apr_22", "May_22"))

# Create a separate data for Tableau purposes with 1GB CSV file limit

bike_data1 <- bike_data %>% select (bike_type, customer_type, started_at, date, day_of_week, day, month, year, ride_length, 
                                    start_station_name, end_station_name, start_lat, start_lng, end_lat, end_lng)

# Exporting Data

fwrite(bike_data1, "bike_data1.csv")

write.csv(bike_data, "bike_data.csv")