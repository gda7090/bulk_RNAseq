library(ggplot2)
library(alakazam)
#setwd('C:\\Users\\xgl\\NJ_project')
#png(file="myplot.png", bg="white")
for (sam in c("NC","TGD","RGD","NGD")) {
datain <- read.delim(paste('02.mixcr/',sam,'/',sam,'.abundance',sep=""), header = TRUE)
datain <- datain[1:100,]
sample_div <- rarefyDiversity(datain, "SAMPLE", min_q=0, max_q=32, step_q=0.05, ci=0.95, nboot=200)
#sample_main <- paste0("Sample diversity (n=", sample_div@n, ")")
sample_main <- "Sample diversity"
p<-plotDiversityCurve(sample_div, main_title=sample_main, 
                  legend_title="Sample", log_x=TRUE, log_y=TRUE)
ggsave(paste(sam,"diversity.pdf",sep="_"), plot=p, width=8, height=6)
ggsave(paste(sam,"diversity.png",sep="_"), plot=p, width=8, height=6, type="cairo-png")

}
