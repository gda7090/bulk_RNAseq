for sample in NGD RGD NC HT TGD
do
mkdir 02.mixcr_TRBfilt/${sample}
perl TRB_filt.pl /NJPROJ2/RNA_S/personal_dir/lindan/SHOUHOU/P101SC17111985-01-JinShanHospital/02.mixcr/${sample}/${sample}.specifc.clones.txt >02.mixcr_TRBfilt/${sample}/${sample}.specifc.clones.txt
done

mkdir "/NJPROJ2/RNA_S/personal_dir/lindan/SHOUHOU/P101SC17111985-01-JinShanHospital/customDraw/Fig4_venn/NGDvsRGDvsNC";
cd "/NJPROJ2/RNA_S/personal_dir/lindan/SHOUHOU/P101SC17111985-01-JinShanHospital/customDraw/Fig4_venn/NGDvsRGDvsNC";
echo "#file.name	sample.id	tag1" >metadata.txt
for sample in NGD RGD NC
do
echo "${sample}.specifc.clones.txt	${sample}	${sample}" >>metadata.txt
done
for sample in NGD RGD NC
do 
ln -s /NJPROJ2/RNA_S/personal_dir/lindan/SHOUHOU/P101SC17111985-01-JinShanHospital/customDraw/Fig4_venn/02.mixcr_TRBfilt/${sample}/${sample}.specifc.clones.txt ./${sample}.specifc.clones.txt
done
/NJPROJ1/RNA/software/java/jre-1.8.0/bin/java -Xmx8G -jar /NJPROJ2/RNA_S/software/VDJtools/vdjtools-1.1.4/vdjtools-1.1.4.jar JoinSamples -m metadata.txt -p NGDvsRGDvsNC 

mkdir "/NJPROJ2/RNA_S/personal_dir/lindan/SHOUHOU/P101SC17111985-01-JinShanHospital/customDraw/Fig4_venn/TGDvsHTvsNC";
cd "/NJPROJ2/RNA_S/personal_dir/lindan/SHOUHOU/P101SC17111985-01-JinShanHospital/customDraw/Fig4_venn/TGDvsHTvsNC";
echo "#file.name	sample.id	tag1" >metadata.txt
for sample in TGD HT NC
do
echo "${sample}.specifc.clones.txt	${sample}	${sample}" >>metadata.txt
done
for sample in TGD HT NC
do 
ln -s /NJPROJ2/RNA_S/personal_dir/lindan/SHOUHOU/P101SC17111985-01-JinShanHospital/customDraw/Fig4_venn/02.mixcr_TRBfilt/${sample}/${sample}.specifc.clones.txt ./${sample}.specifc.clones.txt
done
/NJPROJ1/RNA/software/java/jre-1.8.0/bin/java -Xmx8G -jar /NJPROJ2/RNA_S/software/VDJtools/vdjtools-1.1.4/vdjtools-1.1.4.jar JoinSamples -m metadata.txt -p TGDvsHTvsNC 
