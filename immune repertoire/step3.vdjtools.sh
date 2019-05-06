echo "#file.name	sample.id	tag1" >metadata.txt
for sample in HT NGD RGD TGD NC 
do
echo "${sample}.specifc.clones.txt	${sample}	${sample}" >>metadata.txt
done
#java/jre-1.8.0/bin/java -Xmx8G -jar VDJtools/vdjtools-1.1.4/vdjtools-1.1.4.jar CalcSegmentUsage -m metadata_TRB.txt -p -f tag1 -n out/2.TRB


#####SegmentUsage cluster for all samples#####
for sample in HT NGD RGD TGD NC 
do
#mv 02.mixcr/${sample}/specifc.clones.txt 02.mixcr/${sample}/${sample}.specifc.clones.txt
ln -s 02.mixcr/${sample}/${sample}.specifc.clones.txt ./${sample}.specifc.clones.txt
done

#####SegmentUsage cluster for all samples#####
java/jre-1.8.0/bin/java -Xmx8G -jar VDJtools/vdjtools-1.1.4/vdjtools-1.1.4.jar CalcSegmentUsage -m metadata.txt -p -f tag1 -n out/2
#####monitor diversity reconstitution#####
java/jre-1.8.0/bin/java -Xmx8G -jar VDJtools/vdjtools-1.1.4/vdjtools-1.1.4.jar CalcDiversityStats -m metadata.txt out/3
#####Cluster for sample with tag#####
java/jre-1.8.0/bin/java -Xmx8G -jar VDJtools/vdjtools-1.1.4/vdjtools-1.1.4.jar CalcPairwiseDistances -m metadata.txt out/4
java/jre-1.8.0/bin/java -Xmx8G -jar VDJtools/vdjtools-1.1.4/vdjtools-1.1.4.jar ClusterSamples -p -f tag1 -n -l sample.id out/4 out/4.tag1
#####CDR3 feature analysis AND V-J paired analysis #####
for sample in HT NGD RGD TGD NC 
do
java/jre-1.8.0/bin/java -Xmx8G -jar VDJtools/vdjtools-1.1.4/vdjtools-1.1.4.jar PlotFancySpectratype ${sample}.specifc.clones.txt out/5.${sample}
java/jre-1.8.0/bin/java -Xmx8G -jar VDJtools/vdjtools-1.1.4/vdjtools-1.1.4.jar PlotSpectratypeV ${sample}.specifc.clones.txt out/6.${sample}
java/jre-1.8.0/bin/java -Xmx8G -jar VDJtools/vdjtools-1.1.4/vdjtools-1.1.4.jar PlotQuantileStats  ${sample}.specifc.clones.txt out/7.${sample}
java/jre-1.8.0/bin/java -Xmx8G -jar VDJtools/vdjtools-1.1.4/vdjtools-1.1.4.jar PlotFancyVJUsage ${sample}.specifc.clones.txt out/8.${sample}
done
##### compare of sample cdr3 #####

