#!/usr/bin/env Rscript
#
# R - Diagram
#
# TODO:
#
# -readFiles
# -CSV format test(header,col)
# -plot
#

tryCatch(
	library(ggtern),
	error = function(e) { cat('\nMissing "ggtern" library.\n'); quit(); }
)

csv <- file.choose()

tryCatch(
	data <- read.csv(csv, header = TRUE, sep = ";"),
	warning = function(w) { cat('\nInvalid CSV format.\n'); quit(); },
	error = function(e) { cat('\nInvalid CSV format.\n'); quit(); }
}

