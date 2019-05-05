die "perl $0 02.mixcr/specifc.clones.txt" unless @ARGV==1;
$clone_file=shift;
open IN, "$clone_file";
while (<IN>) {
	next unless ($_=~/^\d+/);
	@aa=split /\t/;
	($count,$nCDR3,$V,$D,$J)=($aa[1],$aa[2],$aa[4],$aa[5],$aa[6]);
	unless (($V eq '') ||  ($J eq '')) {
		$countVJ{$V}{$J}+=$count;
		$sumcVJ+=$count;
	}	
	unless ($V eq '') {
		$countV{$V}+=$count;
		$sumcV+=$count;
		$sumgV++;
		$uniqV{$V}++;
	}
	unless ($D eq '') {
		$countD{$D}+=$count;
		$sumcD+=$count;
		$sumgD++;
		$uniqD{$D}++;
	}
	unless ($J eq '') {
		$countJ{$J}+=$count;
		$sumcJ+=$count;
		$sumgJ++;
		$uniqJ{$J}++;
	}
	
	$len=length($nCDR3);
	$countlen{$len}+=$count;
	$sumclen+=$count;
	$sumglen++;
	$uniqlen{$len}++;
}
mkdir "03.result" if (!-d  "03.result");
#mkdir ="03.result";
open OUTV, ">03.result/Vgene.tab";
@V=sort { $countV{$b} <=> $countV{$a} } keys %countV; 
foreach (@V) {
	$c_fraction = $countV{$_}/$sumcV;
	$g_fraction = $uniqV{$_}/$sumgV;
	print OUTV "$_\t$countV{$_}\t$c_fraction\t$uniqV{$_}\t$g_fraction\n";
}

open OUTD, ">03.result/Dgene.tab";
@D=sort { $countD{$b} <=> $countD{$a} } keys %countD;
foreach (@D) {
	$c_fraction = $countD{$_}/$sumcD;
	$g_fraction = $uniqD{$_}/$sumgD;
	print OUTD "$_\t$countD{$_}\t$c_fraction\t$uniqD{$_}\t$g_fraction\n";
}

open OUTJ, ">03.result/Jgene.tab";
@J=sort { $countJ{$b} <=> $countJ{$a} } keys %countJ;
foreach (@J) {
	$c_fraction = $countJ{$_}/$sumcJ;
	$g_fraction = $uniqJ{$_}/$sumgJ;
	print OUTJ "$_\t$countJ{$_}\t$c_fraction\t$uniqJ{$_}\t$g_fraction\n";
}

open OUTV_J, ">03.result/V_J.tab";
print OUTV_J join "\t", @V,"\n";
foreach $key2(@J) {
	print OUTV_J "$key2";
	foreach $key1(@V){
		$countVJ{$key1}{$key2}=1 unless (exists $countVJ{$key1}{$key2});
		#$fraction=$countVJ{$key1}{$key2}/$sumcVJ;
		#print OUTV_J "\t$fraction";
		print OUTV_J "\t$countVJ{$key1}{$key2}";
	}
	print OUTV_J"\n";
}

open OUTlen, ">03.result/CDR3_len.tab";
@CDR3=sort keys %countlen;
foreach (@CDR3) {
	$c_fraction = $countlen{$_}/$sumclen;
	$g_fraction = $uniqlen{$_}/$sumglen;
	print OUTlen "$_\t$countlen{$_}\t$c_fraction\t$uniqlen{$_}\t$g_fraction\n";
}

open ROUT, ">03.result/Vgene.R";
print ROUT '
bitmap("03.result/V_clone.png","png16m",res=300)
data<-read.table("03.result/Vgene.tab",header=F)
y<-data$V3
x<-data$V1
barplot(y, ylim = c(0, max(y) * 1.1), offset = 0, axis.lty = 0, names.arg = x, col = rep("LightCoral",length(x)), las=2, cex.axis=1, cex.names=0.6, xlab = "V genes",ylab = "Frequency", main = "V clone abundance distribution in lib") 
box()
dev.off()
pdf("03.result/V_clone.pdf")
data<-read.table("03.result/Vgene.tab",header=F)
y<-data$V3
x<-data$V1
barplot(y, ylim = c(0, max(y) * 1.1), offset = 0, axis.lty = 0, names.arg = x, col = rep("LightCoral",length(x)), las=2, cex.axis=1, cex.names=0.6, xlab = "V genes",ylab = "Frequency", main = "V clone abundance distribution in lib")
box()
dev.off()
bitmap("03.result/V_gene.png","png16m",res=200)
data<-read.table("03.result/Vgene.tab",header=F)
y<-data$V5
x<-data$V1
barplot(y, ylim = c(0, max(y) * 1.1), offset = 0, axis.lty = 0, names.arg = x, col = rep("LightCoral",length(x)), las=2, cex.axis=1, cex.names=0.6, xlab = "V genes",ylab = "Frequency", main = "V gene abundance distribution in lib") 
box()
dev.off()
pdf("03.result/V_gene.pdf")
data<-read.table("03.result/Vgene.tab",header=F)
y<-data$V5
x<-data$V1
barplot(y, ylim = c(0, max(y) * 1.1), offset = 0, axis.lty = 0, names.arg = x, col = rep("LightCoral",length(x)), las=2, cex.axis=1, cex.names=0.6, xlab = "V genes",ylab = "Frequency", main = "V gene abundance distribution in lib") 
box()
dev.off()

library(pheatmap)
bitmap("03.result/pheatmap.png","png16m")
data<-read.table("03.result/V_J.tab",header=T,sep="\t")
pheatmap(data,cluster_row = FALSE,cluster_col = FALSE,main="The heatmap of V_J use frequency")
dev.off()
bitmap("03.result/len_clone.png","png16m")
data<-read.table("03.result/CDR3_len.tab",header=F)
y<-data$V3
x<-data$V1
barplot(y, ylim = c(0, max(y) * 1.1), offset = 0, axis.lty = 0, names.arg = x, col = terrain.colors(length(x)), las=2, cex.axis=1, cex.names=0.6, xlab = "CDR3 length",ylab = "Frequency", main = "CDR3 length clone abundance distribution in lib") 
box()
dev.off()
bitmap("03.result/len_gene.png","png16m")
data<-read.table("03.result/CDR3_len.tab",header=F)
y<-data$V3
x<-data$V1
barplot(y, ylim = c(0, max(y) * 1.1), offset = 0, axis.lty = 0, names.arg = x, col = terrain.colors(length(x)), las=2, cex.axis=1, cex.names=0.6, xlab = "V genes",ylab = "Frequency", main = "CDR3 length gene abundance distribution in lib") 
box()
dev.off()
bitmap("03.result/abundance.png","png16m")
data<-read.table(file="abundance.tab",header=TRUE)
clones <- estimateAbundance(data, group="SAMPLE",copy="DUPCOUNT", ci=0.95, nboot=200)
sample_colors <- c("IGHG"="steelblue")
plotAbundance(clones, colors=sample_colors, legend_title="Sample")
sample_div <- rarefyDiversity(data, "SAMPLE", copy="DUPCOUNT", min_q=0, max_q=32, step_q=0.05, ci=0.95, nboot=200)
dev.off()
bitmap("03.result/diversity.png","png16m")
data<-read.table(file="abundance.tab",header=TRUE)
sample_main <- paste0("Sample diversity (n=", sample_div@n, ")")
sample_colors <- c("IGHG"="seagreen")
plotDiversityCurve(sample_div, colors=sample_colors, main_title=sample_main, legend_title="Sample", log_q=TRUE, log_d=TRUE)
sample_div <- rarefyDiversity(data, "SAMPLE", copy="DUPCOUNT", min_q=0, max_q=32, step_q=0.05, ci=0.95, nboot=200)
sample_main <- paste0("Sample diversity (n=", sample_div@n, ")")
sample_colors <- c("IGHG"="seagreen")
plotDiversityCurve(sample_div, colors=sample_colors, main_title=sample_main, legend_title="Sample", log_q=TRUE, log_d=TRUE)
dev.off()
';
system("R <03.result/Vgene.R --vanilla")
