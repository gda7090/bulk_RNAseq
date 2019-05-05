#args <- c("out/7.NC.qstat.txt", "out/7.NC.qstat.pdf")
require(ggplot2); require(RColorBrewer)

args<-commandArgs(TRUE)

file_in    <- args[1]
file_out   <- args[2]

df <- read.table(file_in, header=T, comment="", sep = "\t")
df$value <- as.numeric(as.character(df$value))

# this routine prepares data for donut plot representation
makesub <- function(t) {
	tmp <- subset(df, type %in% t)
	tmp$vmax = cumsum(tmp$value)
	tmp$vmin = c(0, head(tmp$vmax, n=-1))	
	tmp
}

# select color for different arcs
makecol <- function(d, pal) {
    col <- character(nrow(d))
	p <- colorRampPalette(pal)(nrow(d))
	
	for (i in 1:nrow(d)) {
	   names(col)[i] <- as.character(d$name[i])
	   col[i] <- p[i]
	}
	
	col
}

# format three levels of data
# set - singletons, doubletons & high-order
# quantile - q1..q5
# top - top1 clonotype, top2 clonotype...
df.1 <- makesub("set")
df.2 <- makesub("quantile")
df.3 <- makesub("top")

col <- makecol(df.1, brewer.pal(3,"RdYlBu"))
col <- c(col, makecol(df.2, rev(brewer.pal(3,"Oranges"))))
col <- c(col, makecol(df.3, rev(brewer.pal(3,"OrRd"))))

if (grepl("\\.pdf$",file_out)){
   pdf(file_out)
} else if (grepl("\\.png$",file_out)) {
   png(file_out, width     = 3.25,
                 height    = 3.25,
                 units     = "in",
                 res       = 1200,
                 pointsize = 4)
} else {
   stop('Unknown plotting format')
}

ggplot() +
     geom_rect(data = df.1, colour="grey30", aes(fill=name, ymax=vmax, ymin=vmin, xmax=2,xmin=1)) +
     geom_rect(data = df.2, colour="grey30", aes(fill=name, ymax=vmax, ymin=vmin, xmax=4,xmin=2)) +
     geom_rect(data = df.3, colour="grey30", aes(fill=name, ymax=vmax, ymin=vmin, xmax=7,xmin=4)) +
     # here we also rotate text to point to right direction
     geom_text(data = df.1, aes(x=1.5, y = value/2 + c(0, cumsum(value)[-length(value)]), angle=180-..y..*360, label = name), size=4)+
     geom_text(data = df.2, aes(x=3.0, y = value/2 + c(0, cumsum(value)[-length(value)]), angle=90-..y..*360, label = name), size=4)+
     geom_text(data = df.3, aes(x=4, y = value/2 + c(0, cumsum(value)[-length(value)]), angle=90-..y..*360, label = name, size = log10(value)), hjust=0.0)+
     coord_polar(theta="y") +
     scale_x_continuous(expand=c(0,0),limits=c(0, 7)) +
     scale_fill_manual(values=col)+
     xlab("") + ylab("")+
     theme_bw() +
     theme(panel.grid=element_blank()) +
     theme(panel.border=element_blank()) +
     theme(axis.text=element_blank()) +
     theme(axis.ticks=element_blank()) + 
     theme(legend.position="none")

dev.off()
