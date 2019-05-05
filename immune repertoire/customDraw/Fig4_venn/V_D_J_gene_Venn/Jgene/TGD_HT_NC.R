library("VennDiagram")
setwd("/NJPROJ2/MICRO/PROJ/yangfenglong/yanfa/dandan/bar_errbar/vdjData/venngroup/Jgene")
pdf('/NJPROJ2/MICRO/PROJ/yangfenglong/yanfa/dandan/bar_errbar/vdjData/venngroup/Jgene/TGD_HT_NC.pdf',width=4,height=4)
draw.triple.venn(category = c("TGD","HT","NC"), 
fill=c("lightblue","cadetblue","yellowgreen"),
cat.col=c("lightblue","cadetblue","yellowgreen"),
alpha=rep(0.5,3),lwd=rep(1,3),lty=rep("solid",3),ind = TRUE,col=rep("grey",3),cat.cex=rep(1,3),
area1=13,area2=13,area3=13,n23=13,n12=13,n123=13,n13=13,)
dev.off()