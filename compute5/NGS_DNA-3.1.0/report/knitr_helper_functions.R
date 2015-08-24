#library(stringr)

stringToVector = function(s)
{
	vec = strsplit(s,";")[[1]]
	vec[-length(vec)]
}

showFigure = function(file.name, caption)
{
	cat(paste("<figure><figcaption>", caption, "</figcaption>![", caption, "](", file.name, ")</figure>\n", sep=''))
}

csv.to.markdown.table.CUSTOM.qc = function(f)
{
	mat = read.csv(f, header = F, stringsAsFactors = FALSE)
	
	mat = mat[-2,] # remove bait set
	
	matrix.to.markdown.table(mat)
}

csv.to.markdown.table = function(f)
{
	mat = read.csv(f, header = F, stringsAsFactors = FALSE)
	matrix.to.markdown.table(mat)
}

matrix.to.markdown.table = function(mat)
{
	# create header
		markdown.table = paste(mat[1,], collapse='|') # put | between columns
		markdown.table = c(markdown.table, paste(rep("---", ncol(mat)), collapse='|')) # separate header, body

	# cut header from body
		mat = mat[-1, ]
	
	# create body
		mat[,1] = sapply(mat[,1], function(v) paste("**", v, "**", sep=""))# make first column bold
		markdown.table = c(markdown.table, apply(mat, 1, function(vec) paste(vec, collapse='|'))) # put \ between columns

	# return
	sapply(markdown.table, function(v) paste(v, '\n'))
}
