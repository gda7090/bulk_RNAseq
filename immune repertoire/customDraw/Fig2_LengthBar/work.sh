mkdir output
for sample in GD7 NC6 NC1 HT3 HT4 GD9 GD2 HT1 NC4 NC2 NC5 NC3 GD5 GD11 HT2 GD6 GD8 GD12 HT6 GD10 GD4 HT5 GD3 GD1 NGD RGD TGD NC HT
do
perl LenBar_stat.pl /NJPROJ2/RNA_S/personal_dir/lindan/SHOUHOU/P101SC17111985-01-JinShanHospital/P101SC17111985-01-18_results/2.IMMU_repertoire_Analysis/IMMUE_Clonotype/${sample}/Vgene.tab >output/${sample}_Vgene.tab
done

