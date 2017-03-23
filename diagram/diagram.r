#!/usr/bin/env Rscript
#
# R - Ternary Diagram
#

done <- function() {
	cat('\nTermining...\n')
	Sys.sleep(5)
	q()
}

lib_err <- function(e) {
	cat('\nMissing "ggtern" library.\n')
	done()
}

csv_err <- function(e) {
	cat('\nInvalid CSV format.\n')
	done()
}

plot_err <- function(e) {
	cat('\nPlot error.\n')
	done()
}

tryCatch(library(ggtern), error = lib_err)

cat('--\n')

csv <- file.choose()

tryCatch(
	data <- read.csv(csv, header = TRUE, sep = ";"),
	warning = csv_err, error = csv_err
)

p <- ggtern(data, aes(Fe,Si,Ca)) +				# data

	geom_point() +						# bod

	geom_density_tern() +					# density

	theme_showarrows() +					# arrow

#	labs(title = 'Tablet Tenary Diagram') +			# title

#	theme(plot.title = element_text(hjust = 0.5)) +		# center the title

	labs(x = 'Fe [%]', y = 'Si [%]', z = 'Ca [%]')		# label

filename = paste('diagram_',sep='',format(Sys.time(),"%d_%m_%y_%H_%M"),'.png')

tryCatch(
	ggsave(file=filename, width=7, height=7),
	warning = plot_err, error = plot_err
)
