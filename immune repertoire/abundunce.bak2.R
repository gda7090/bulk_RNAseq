library(ggplot2)
library(alakazam)
library(dplyr)
#setwd('C:\\Users\\xgl\\NJ_project')
#png(file="myplot.png", bg="white")
datain <- read.delim('02.mixcr/all_sample.abundance', header = TRUE)
clones <- estimateAbundance(datain, group="SAMPLE", copy="DUPCOUNT", ci=0.95, nboot=200)
#sample_colors <- c("A_1"="seagreen", "A_2"="steelblue")
#, "IgM_3"="red")
p<-plotAbundanceCurve(clones, legend_title="Sample")
ggsave("abundance.pdf", plot=p, width=8, height=6)
ggsave("abundance.png", plot=p, width=8, height=6, type="cairo-png")

#isotype_div <- rarefyDiversity(datain, "SAMPLE", min_q=0, max_q=32, step_q=0.05, ci=0.95, nboot=200)
#isotype_main <- paste0("Isotype diversity (n=", isotype_div@n, ")")
#p<-plotDiversityCurve(isotype_div, main_title=isotype_main, legend_title="Sample", log_q=TRUE, log_d=TRUE)
#ggsave("isotype_div.pdf", plot=p, width=8, height=6)
#ggsave("isotype_div.png", plot=p, width=8, height=6, type="cairo-png")

sample_div <- rarefyDiversity(datain, "SAMPLE", min_q=0, max_q=32, step_q=0.05, ci=0.95, nboot=200)
sample_main <- paste0("Sample diversity (n=", sample_div@n, ")")
p<-plotDiversityCurve(sample_div, main_title=sample_main, 
                  legend_title="Sample", log_x=TRUE, log_y=TRUE)
ggsave("diversity.pdf", plot=p, width=8, height=6)
ggsave("diversity.png", plot=p, width=8, height=6, type="cairo-png")
