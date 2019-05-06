
mkdir "customDraw/Fig7_filtedCluster/HT";
cd "customDraw/Fig7_filtedCluster/HT";
echo "#file.name	sample.id	tag1" >metadata.txt
for sample in HT1 HT2 HT3 HT4 HT5 HT6
do
echo "${sample}.specifc.clones.txt	${sample}	${sample}" >>metadata.txt
done
for sample in HT1 HT2 HT3 HT4 HT5 HT6
do 
ln -s 02.mixcr/${sample}/${sample}.specifc.clones.txt ./${sample}.specifc.clones.txt
done
java/jre-1.8.0/bin/java -Xmx8G -jar vdjtools-1.1.4/vdjtools-1.1.4.jar CalcSegmentUsage -m metadata.txt -p -f tag1 -n out/2

mkdir "customDraw/Fig7_filtedCluster/NGD";
cd "customDraw/Fig7_filtedCluster/NGD";
echo "#file.name	sample.id	tag1" >metadata.txt
for sample in GD1 GD2 GD3 GD4 GD5 GD6
do
echo "${sample}.specifc.clones.txt	${sample}	${sample}" >>metadata.txt
done
for sample in GD1 GD2 GD3 GD4 GD5 GD6
do 
ln -s 02.mixcr/${sample}/${sample}.specifc.clones.txt ./${sample}.specifc.clones.txt
done
java/jre-1.8.0/bin/java -Xmx8G -jar vdjtools-1.1.4/vdjtools-1.1.4.jar CalcSegmentUsage -m metadata.txt -p -f tag1 -n out/2

mkdir "customDraw/Fig7_filtedCluster/RGD";
cd "customDraw/Fig7_filtedCluster/RGD";
echo "#file.name	sample.id	tag1" >metadata.txt
for sample in GD7 GD8 GD9 GD10 GD11 GD12
do
echo "${sample}.specifc.clones.txt	${sample}	${sample}" >>metadata.txt
done
for sample in GD7 GD8 GD9 GD10 GD11 GD12
do 
ln -s 02.mixcr/${sample}/${sample}.specifc.clones.txt ./${sample}.specifc.clones.txt
done
java/jre-1.8.0/bin/java -Xmx8G -jar vdjtools-1.1.4/vdjtools-1.1.4.jar CalcSegmentUsage -m metadata.txt -p -f tag1 -n out/2

mkdir "customDraw/Fig7_filtedCluster/TGD";
cd "customDraw/Fig7_filtedCluster/TGD";
echo "#file.name	sample.id	tag1" >metadata.txt
for sample in GD1 GD2 GD3 GD4 GD5 GD6 GD7 GD8 GD9 GD10 GD11 GD12
do
echo "${sample}.specifc.clones.txt	${sample}	${sample}" >>metadata.txt
done
for sample in GD1 GD2 GD3 GD4 GD5 GD6 GD7 GD8 GD9 GD10 GD11 GD12
do 
ln -s 02.mixcr/${sample}/${sample}.specifc.clones.txt ./${sample}.specifc.clones.txt
done
java/jre-1.8.0/bin/java -Xmx8G -jar vdjtools-1.1.4/vdjtools-1.1.4.jar CalcSegmentUsage -m metadata.txt -p -f tag1 -n out/2

mkdir "customDraw/Fig7_filtedCluster/NC"
cd "customDraw/Fig7_filtedCluster/NC";
echo "#file.name	sample.id	tag1" >metadata.txt
for sample in NC1 NC2 NC3 NC4 NC5 NC6
do
echo "${sample}.specifc.clones.txt	${sample}	${sample}" >>metadata.txt
done
for sample in NC1 NC2 NC3 NC4 NC5 NC6
do 
ln -s 02.mixcr/${sample}/${sample}.specifc.clones.txt ./${sample}.specifc.clones.txt
done
java/jre-1.8.0/bin/java -Xmx8G -jar vdjtools-1.1.4/vdjtools-1.1.4.jar CalcSegmentUsage -m metadata.txt -p -f tag1 -n out/2

