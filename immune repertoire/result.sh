readme_dir="/NJPROJ2/RNA_S/project_Q4/P101SC17111985-01-B3-18_ren_TCR_20181208/readme"
result_dir="/NJPROJ2/RNA_S/personal_dir/lindan/SHOUHOU/P101SC17111985-01-JinShanHospital/P101SC17111985-01-18_results"

mkdir ${result_dir}/2.IMMU_repertoire_Analysis/
mkdir ${result_dir}/2.IMMU_repertoire_Analysis/CDR3/
mkdir ${result_dir}/2.IMMU_repertoire_Analysis/VJ_gene_paired/
mkdir ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/
mkdir ${result_dir}/3.IMMU_Diff_Analysis/
mkdir ${result_dir}/3.IMMU_Diff_Analysis/VJgene_cluster
for sample in HT NGD RGD TGD NC 
do
perl /NJPROJ3/RNA_S/projects_NJ1/P101SC17111985-01-B2-18_ren_TCR_20180807/script/mixcr.statistic.pl  02.mixcr/${sample}/${sample}.specifc.clones.txt
mkdir ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}
mv 03.result/*tab ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}/
mv 03.result/V_clone.png ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}/${sample}.V_clone.png
mv 03.result/V_gene.png ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}/${sample}.V_gene.png
cp 02.mixcr/${sample}/${sample}.specifc.clones.txt ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}

cp out/5.${sample}.fancyspectra.txt ${result_dir}/2.IMMU_repertoire_Analysis/CDR3/${sample}.cdr3len.txt
cp out/5.${sample}.fancyspectra.pdf ${result_dir}/2.IMMU_repertoire_Analysis/CDR3/${sample}.cdr3len.pdf
cp out/6.${sample}.spectraV.wt.txt ${result_dir}/2.IMMU_repertoire_Analysis/CDR3/${sample}.cdr3Vusage.txt
cp out/6.${sample}.spectraV.wt.pdf ${result_dir}/2.IMMU_repertoire_Analysis/CDR3/${sample}.cdr3Vusage.pdf
cp ${readme_dir}/CDR3.README.txt ${result_dir}/2.IMMU_repertoire_Analysis/CDR3/CDR3.README.txt

cp out/8.${sample}.fancyvj.wt.pdf ${result_dir}/2.IMMU_repertoire_Analysis/VJ_gene_paired/${sample}.VJpaired.circos.pdf
cp out/8.${sample}.fancyvj.wt.txt ${result_dir}/2.IMMU_repertoire_Analysis/VJ_gene_paired/${sample}.VJpaired.circos.txt
cp ${readme_dir}/VJpaired.README.txt ${result_dir}/2.IMMU_repertoire_Analysis/VJ_gene_paired/VJpaired.README.txt
done

cp out/2.segments.wt.V.pdf ${result_dir}/3.IMMU_Diff_Analysis/VJgene_cluster/Vgene_cluster.pdf
cp out/2.segments.wt.J.pdf ${result_dir}/3.IMMU_Diff_Analysis/VJgene_cluster/Jgene_cluster.pdf
cp out/2.segments.wt.V.txt ${result_dir}/3.IMMU_Diff_Analysis/VJgene_cluster/Vgene.txt
cp out/2.segments.wt.J.txt ${result_dir}/3.IMMU_Diff_Analysis/VJgene_cluster/Jgene.txt
cp ${readme_dir}/VJgene_cluster.README.txt ${result_dir}/3.IMMU_Diff_Analysis/VJgene_cluster/

for sample in GD7 NC6 NC1 HT3 HT4 GD9 GD2 HT1 NC4 NC2 NC5 NC3 GD5 GD11 HT2 GD6 GD8 GD12 HT6 GD10 GD4 HT5 GD3 GD1
do 
perl /NJPROJ3/RNA_S/projects_NJ1/P101SC17111985-01-B2-18_ren_TCR_20180807/script/mixcr.statistic.pl  02.mixcr/${sample}/${sample}.specifc.clones.txt
mkdir ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}
mv 03.result/*tab ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}/
mv 03.result/V_clone.png ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}/${sample}.V_clone.png
mv 03.result/V_gene.png ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}/${sample}.V_gene.png
cp 02.mixcr/${sample}/${sample}.specifc.clones.txt ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}
done

for sample in NC TGD RGD NGD HT 
do 
perl mixcr.statistic.pl  02.mixcr/${sample}/${sample}.specifc.clones.txt
mkdir ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}
mv 03.result/*tab ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}/
mv 03.result/V_clone.png ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}/${sample}.V_clone.png
mv 03.result/V_gene.png ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}/${sample}.V_gene.png
mv 03.result/V_clone.pdf ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}/${sample}.V_clone.pdf
mv 03.result/V_gene.pdf ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}/${sample}.V_gene.pdf
cp 02.mixcr/${sample}/${sample}.specifc.clones.txt ${result_dir}/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}
done
