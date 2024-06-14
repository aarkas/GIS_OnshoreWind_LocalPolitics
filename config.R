library(here)
library(dotenv)
library(dplyr)

# Get password from.env
# TODO: insert important info & change password in .env
dotenv::load_dot_env()
password = Sys.getenv("my_password")

