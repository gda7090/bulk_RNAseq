#perl FA_GTF_GO_check.pl -fa Mus_musculus/Ensemble_GRCm38.82/WGBS/Mus_musculus.GRCm38.dna.chr_only.fa -gtf Mus_musculus/Ensemble_GRCm38.82/WGBS/Mus_musculus.GRCm38.82.chr_only.gtf -go Mus_musculus/Ensemble_GRCm38.82/WGBS/gene.Mus_musculus.GRCm38.82.chr_only.go


#check=`grep "Error" Mus_musculus/Ensemble_GRCm38.82/WGBS/0.log/ref_prepare_o*.txt`
#if [ "$check" != "" ];then
#	echo "Sorry, there is something wrong in the ref files!! You should check it." 
#	echo "Exit now"
#	exit
#fi

## build index for reference genome
bismark/bismark_v0.14.3/bismark_genome_preparation --bowtie2  Homo_sapiens/hg19/WGBS
<<EOF
## extract various genomic features from a gtf/gff annotation file
python Extract_Genomic_regions.py \
	--fa Mus_musculus/Ensemble_GRCm38.82/WGBS_new/Mus_musculus.GRCm38.dna.chr_only.fa \
	--gtf Mus_musculus/Ensemble_GRCm38.82/WGBS/Mus_musculus.GRCm38.82.chr_only.gtf \
	--outdir Mus_musculus/Ensemble_GRCm38.82/WGBS_new/Genome_Reg \
	--format gtf 
EOF
