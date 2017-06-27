#!/usr/bin/env Rscript
#
# R - Ternary Diagram
#

cat('\nLoading functions..\n')
done <- function() { Sys.sleep(2); q() }
ok <- function() { cat('\nOk.\n'); done() }
lib_err <- function(e) { cat('\nMissing library.\n'); done() }
open_err <- function(e) { cat('\nCancelled. \n'); done() }
csv_err <- function(e) { cat('\nInvalid CSV format.\n'); done() }
plot_err <- function(e) { cat('\nPlot error.\n'); done() }

cat('\nLoading ggtern library..\n')
suppressMessages(tryCatch(library(ggtern), error = lib_err))
cat('\nLoading tcltk library..\n')
suppressMessages(tryCatch(library(tcltk), error = lib_err))
cat('\nLoading hash library..\n')
suppressMessages(tryCatch(library(hash), error = lib_err))
cat('\nLoading CSV file..\n')
#tryCatch(csv <- file.choose(), error = open_err)
tryCatch(csv <- tk_choose.files(), error = open_err)
tryCatch(data <- read.csv(csv, header = TRUE, sep = ";"), error = csv_err)

#-------------------

std <- unique(data[c("Std")])

clr <- hash()

.set(clr,
	'Grey beige'='blue',
	'slate grey'='red',
	'moss grey'='forestgreen',
	'olive yelow'='yellow2',
	'yelow olive'='chocolate1',
	'khaki grey'='darkred',
	'brown beige'='deeppink'
)

p <- ggtern(data, aes(Mg,Al,Fe)) +				# data
	theme_showarrows() +					# arrow
	theme_mesh(10) +					# mesh
#	labs(title = 'Tablet Tenary Diagram') +			# title
#	theme(plot.title = element_text(hjust = 0.5)) +		# center the title
	labs(x = 'Mg [%]', y = 'Al [%]', z = 'Fe [%]')		# label

#----------

for (c in std[[1]])  {
#	p <- ggtern(data, aes(Mg,Al,Fe)) +				# data
#		theme_showarrows() +					# arrow
#		theme_mesh(10) +					# mesh
#		labs(x = 'Mg [%]', y = 'Al [%]', z = 'Fe [%]')		# label
	s <- subset(data, Std == c, select=c("Mg","Al","Fe"))
	p <- p + geom_density_tern(
			data=s,
			bins=2,
			colour=clr[[c]]
		)
	p <- p + geom_point(
			data=s,
			size=0.5,
			colour=clr[[c]],
			fill=clr[[c]]
		)
#	fn = paste('diagram_',c,'_',sep = '', format(Sys.time(), "%d_%m_%y_%H_%M"), '.png')
#	ggsave(file = fn, p, width = 5, height = 5)
}

fn = paste('diagram_', sep = '', format(Sys.time(), "%d_%m_%y_%H_%M"), '.png')

tryCatch(ggsave(file = fn, p, width = 5, height = 5), warning = plot_err, error = plot_err)

ok()

