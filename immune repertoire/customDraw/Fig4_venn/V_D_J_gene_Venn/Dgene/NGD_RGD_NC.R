library("VennDiagram")
setwd("/NJPROJ2/MICRO/PROJ/yangfenglong/yanfa/dandan/bar_errbar/vdjData/venngroup/Dgene")
pdf('/NJPROJ2/MICRO/PROJ/yangfenglong/yanfa/dandan/bar_errbar/vdjData/venngroup/Dgene/NGD_RGD_NC.pdf',width=4,height=4)
draw.triple.venn(category = c("NGD","RGD","NC"), 
fill=c("lightblue","cadetblue","yellowgreen"),
cat.col=c("lightblue","cadetblue","yellowgreen"),
alpha=rep(0.5,3),lwd=rep(1,3),lty=rep("solid",3),ind = TRUE,col=rep("grey",3),cat.cex=rep(1,3),
area1=2,area2=2,area3=2,n13=2,n12=2,n123=2,n23=2,)
dev.off()