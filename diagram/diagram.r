#!/usr/bin/env Rscript
#
# R - Ternary Diagram
#

cat('\nLoading functions..\n')

done <- function() { Sys.sleep(5); q() }

ok <- function() { cat('\nOk.\n'); done() }

lib_err <- function(e) { cat('\nMissing ggtern library.\n'); done() }

open_err <- function(e) { cat('\nCancelled. \n'); done() }

csv_err <- function(e) { cat('\nInvalid CSV format.\n'); done() }

plot_err <- function(e) { cat('\nPlot error.\n'); done() }

cat('\nLoading ggtern library..\n')

suppressMessages(tryCatch(library(ggtern), error = lib_err))

cat('\nLoading CSV file..\n')

tryCatch(csv <- file.choose(), error = open_err)

tryCatch( data <- read.csv(csv, header = TRUE, sep = ";"), error = csv_err)

p <- ggtern(data, aes(Ca,K,Fe)) +				# data

#	geom_density_tern() +					# density

	stat_density_tern(					# density polygon
		geom = 'polygon',
		aes(fill = ..level..),
		show.legend = FALSE
	) +

	geom_point() +						# point

	theme_showarrows() +					# arrow

	theme_mesh(10) +					# mesh

#	labs(title = 'Tablet Tenary Diagram') +			# title

#	theme(plot.title = element_text(hjust = 0.5)) +		# center the title

	labs(x = 'Ca [%]', y = 'K [%]', z = 'Fe [%]')		# label

fn = paste('diagram_', sep = '', format(Sys.time(),"%d_%m_%y_%H_%M"), '.png')

tryCatch(ggsave(file = fn, p, width = 5, height = 5), warning = plot_err, error = plot_err)

ok()

