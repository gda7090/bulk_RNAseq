library(ggplot2)
library(alakazam)
#setwd('C:\\Users\\xgl\\NJ_project')
#png(file="myplot.png", bg="white")
for (sam in c("GD7","NC6","NC1","HT3","HT4","GD9","GD2","HT1","NC4","NC2","NC5","NC3","GD5","GD11","HT2","GD6","GD8","GD12","HT6","GD10","GD4","HT5","GD3","GD1","NGD","RGD","TGD","NC","HT")) {
datain <- read.delim(paste('02.mixcr/',sam,'/',sam,'.abundance',sep=""), header = TRUE)
datain <- datain[1:100,]
sample_div <- rarefyDiversity(datain, "SAMPLE", min_q=0, max_q=32, step_q=0.05, ci=0.95, nboot=200)
out<-data.frame(q=sample_div@data$Q,D=sample_div@data$D,D_SD=sample_div@data$D_SD,D_LOWER=sample_div@data$D_LOWER,D_UPPER=sample_div@data$D_UPPER)
#out$q<-sample_div@data$Q
#out$D<-sample_div@data$D
#out$D_SD<-sample_div@data$D_SD
#out$D_LOWER<-sample_div@data$D_LOWER
#out$D_UPPER<-sample_div@data$D_UPPER
#names(out)<-c("q","D","D_SD","D_LOWER","D_UPPER")
write.table(out, paste0(sam,"_diversity.xls"), sep="\t",quote=F,row.names = FALSE)
#sample_main <- "Sample diversity"
#p<-plotDiversityCurve(sample_div, main_title=sample_main, 
 #                 legend_title="Sample", log_x=TRUE, log_y=TRUE)
#ggsave(paste(sam,"diversity.pdf",sep="_"), plot=p, width=8, height=6)
#ggsave(paste(sam,"diversity.png",sep="_"), plot=p, width=8, height=6, type="cairo-png")
}
