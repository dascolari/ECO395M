library(here)
path_data <- here(file.path("data"))
path_code <- here(file.path("code"))
path_out <- here(file.path("output"))

# source code for each question
source(file.path(path_code, "ex1_lib.R"))
source(file.path(path_code, "ex1_1_abia.R"))
source(file.path(path_code, "ex1_2_billboard.R"))
source(file.path(path_code, "ex1_3_olympics_top20.R"))
source(file.path(path_code, "ex1_4_sclass.R"))