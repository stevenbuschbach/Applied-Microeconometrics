#Note: run this code after 1.run_stata.do

if (!require("groundhog")) install.packages("groundhog")
library(groundhog)
if (!require("groundhog")) install.packages("generics")
library(generics)
groundhog.library("here", "2021-12-08", ignore.deps='generics')


source(here::here('Do/setup_R.R')) #Installs all needed packages.
source(here::here('Do/FigureA12.R')) #Creates figure A12.
source(here::here('Do/MLHet.R'))  #Generates data needed for figure A13. Note it takes a long time to run
source(here::here('Do/FigureA13.R'))  #Creates figure A13.

