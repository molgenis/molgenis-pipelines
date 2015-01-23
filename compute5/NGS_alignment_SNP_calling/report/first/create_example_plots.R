base.name = 'example_coverage_plot'
for (i in 1:6) {
	pdf(paste('data/', base.name, i, '.pdf', sep=''))
		plot(1,t='n')
		text(1,1,"EXAMPLE PLOT",col=i)
	dev.off()
}