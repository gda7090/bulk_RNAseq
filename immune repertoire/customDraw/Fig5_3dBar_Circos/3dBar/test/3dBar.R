library(reshape2)
.libPaths("/NJPROJ2/RNA_S/personal_dir/lindan/R/Rlib")
library(epade)

dat<-read.table("TRBvjpairs_top30.xls",header=T)
par(las=2,cex=0.8)
tmp=dcast(dat,Vgene~Jgene)     #这里是把长形数据变成宽数据
data=as.matrix(tmp[,-1])
rownames(data)=tmp[,1]
bar3d.ade(t(data), wall=0,ylab = "Mean proportional gene usage",zw=0.5,xw=0.3,lcol=NULL,xticks=rownames(data),col=c("bisque","brown","coral","cornflowerblue","cornsilk","cadetblue","azure","aquamarine","burlywood"))
