# Data cleaning script
# This script processes raw data into analysis-ready format

library(tidyverse) 
library(here)

# Set up project path
here::i_am("R/00_clean_data.R")

# Load raw data
raw_data <- read_csv(here("raw_data", "data.csv"))

# Clean data
# Add your cleaning steps here

# Save processed data
# write_csv(clean_data, here("data", "clean_data.csv")) 