r = getOption("repos")
r["CRAN"] = "http://cran.us.r-project.org"
options(repos = r)

packages = c("dplyr", "xtable", "lfe", "ggplot2","ggthemes","gridExtra",
             "corrplot", "tidyr", "plyr", "readxl", "remotes","caret","MASS","glmnet")

groundhog.library(packages, "2021-12-08", ignore.deps='generics')

#Requires Rtools.
groundhog.library("car", "2021-12-08", ignore.deps='generics')
