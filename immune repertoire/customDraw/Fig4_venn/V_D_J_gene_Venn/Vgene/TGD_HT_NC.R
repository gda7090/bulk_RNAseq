library("VennDiagram")
setwd("/NJPROJ2/MICRO/PROJ/yangfenglong/yanfa/dandan/bar_errbar/vdjData/venngroup/Vgene")
pdf('/NJPROJ2/MICRO/PROJ/yangfenglong/yanfa/dandan/bar_errbar/vdjData/venngroup/Vgene/TGD_HT_NC.pdf',width=4,height=4)
draw.triple.venn(category = c("TGD","HT","NC"), 
fill=c("lightblue", "cadetblue","yellowgreen"),
cat.col=c("lightblue","cadetblue","yellowgreen"),
alpha=rep(0.5,3),lwd=rep(1,3),lty=rep("solid",3),ind = TRUE,col=rep("grey",3),cat.cex=rep(1,3),
area1=62,area2=61,area3=59,n23=58,n12=60,n123=58,n13=59,)
dev.off()